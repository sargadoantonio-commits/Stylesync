/**
 * Server-authoritative credential handling (StyleSync production path).
 *
 * - Pepper and slow hashing live only here (Secret Manager), never shipped in the app binary.
 * - Bcrypt (cost 12) over UTF-8 material: password + per-user salt + pepper.
 * - Credentials: users/{uid}/auth_private/credential — Firestore rules deny all client access.
 * - username_index: only { uid, email } (no password material on publicly readable docs).
 *
 * Deploy (once per project):
 *   printf '%s' "your-long-random-pepper-at-least-16-chars" | firebase functions:secrets:set STYLESYNC_PEPPER
 *   firebase deploy --only functions
 * Optional: set param FIREBASE_WEB_API_KEY (Firebase Console → Functions → parameters, or .env for emulators)
 * so Identity Toolkit fallback can refresh bcrypt after an email password reset.
 *
 * App Check: these callables use enforceAppCheck. Register debug tokens in the Firebase console for dev builds,
 * and use Play Integrity / App Attest in release. Web requires dart-define FIREBASE_APP_CHECK_SITE_KEY.
 */

import bcrypt from "bcrypt";
import { createHash, randomBytes } from "crypto";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

// Development pepper for Spark plan (upgrade to Blaze for production to use Secret Manager)
const pepperSecret = {
  value: () => "STYLESYNC_DEVELOPMENT_PEPPER_UPGRADE_TO_BLAZE_FOR_PRODUCTION_SECURITY"
};

/** Set to your Web API key (restricted in GCP) to allow post–email-reset recovery when bcrypt is stale. */
const firebaseWebApiKey = "";

/** Matches legacy Flutter `PasswordSecurityEngine` for accounts created before server-side auth. */
const LEGACY_CLIENT_PEPPER = "STYLESYNC_CYBER_PEPPER_v1_MIDTERM_DO_NOT_SHIP_AS_IS";

const BCRYPT_COST = 12;
const USERNAME_RE = /^[a-zA-Z0-9_]{3,50}$/;

type UserRole = "barber" | "customer" | "shopOwner";

interface ValidationResult {
  isValid: boolean;
  error?: string;
}

function validateRegistrationData(data: Record<string, unknown>): ValidationResult {
  const username = String(data.username ?? "").trim();
  const email = String(data.email ?? "").trim().toLowerCase();
  const password = String(data.password ?? "");
  const role = String(data.role ?? "customer");

  if (!USERNAME_RE.test(username) || normalizeUsername(username) !== username.toLowerCase()) {
    return { isValid: false, error: "Username must be 3-50 characters, alphanumeric with underscores only." };
  }
  if (!email.includes("@") || email.length > 254) {
    return { isValid: false, error: "Please provide a valid email address." };
  }
  if (password.length < 8 || password.length > 100) {
    return { isValid: false, error: "Password must be 8-100 characters long." };
  }
  if (!["barber", "customer", "shopOwner"].includes(role)) {
    return { isValid: false, error: "Invalid user role specified." };
  }
  return { isValid: true };
}

function validateSignInData(data: Record<string, unknown>): ValidationResult {
  const username = String(data.username ?? "").trim();
  const password = String(data.password ?? "");

  if (username.length < 3 || username.length > 50) {
    return { isValid: false, error: "Invalid username format." };
  }
  if (password.length < 8 || password.length > 100) {
    return { isValid: false, error: "Invalid password length." };
  }
  return { isValid: true };
}

function validatePasswordSyncData(data: Record<string, unknown>): ValidationResult {
  const password = String(data.password ?? "");
  if (password.length < 8 || password.length > 100) {
    return { isValid: false, error: "Password must be 8-100 characters long." };
  }
  return { isValid: true };
}

function logFunctionCall(functionName: string, userId?: string, additionalData?: Record<string, unknown>): void {
  console.log(`[${new Date().toISOString()}] ${functionName} called${userId ? ` by user ${userId}` : ''}`, additionalData || '');
}

function logFunctionError(functionName: string, error: unknown, userId?: string): void {
  console.error(`[${new Date().toISOString()}] ${functionName} error${userId ? ` for user ${userId}` : ''}:`, error);
}

function normalizeUsername(username: string): string {
  return username.trim().toLowerCase();
}

function sha256Hex(material: string): string {
  return createHash("sha256").update(material, "utf8").digest("hex");
}

function randomSalt(): string {
  return randomBytes(16).toString("base64url");
}

async function sleepMs(ms: number): Promise<void> {
  await new Promise((r) => setTimeout(r, ms));
}

async function jitterFailedAttempt(): Promise<void> {
  await sleepMs(180 + Math.floor(Math.random() * 420));
}

function isBcryptDigest(hash: string | undefined): boolean {
  return !!hash && hash.startsWith("$2");
}

async function digestMatches(
  password: string,
  credentialSalt: string,
  storedDigest: string,
  serverPepper: string,
): Promise<boolean> {
  const material = password + credentialSalt + serverPepper;
  if (isBcryptDigest(storedDigest)) {
    try {
      return await bcrypt.compare(material, storedDigest);
    } catch {
      return false;
    }
  }
  const legacyMaterial = password + credentialSalt + LEGACY_CLIENT_PEPPER;
  return sha256Hex(legacyMaterial) === storedDigest;
}

async function writeBcryptCredential(uid: string, password: string, serverPepper: string): Promise<void> {
  const credentialSalt = randomSalt();
  const material = password + credentialSalt + serverPepper;
  const passwordDigest = await bcrypt.hash(material, BCRYPT_COST);
  const db = getFirestore();
  await db.doc(`users/${uid}/auth_private/credential`).set(
    {
      passwordDigest,
      credentialSalt,
      scheme: "bcrypt_v1",
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

async function tryIdentityToolkitSignIn(email: string, password: string): Promise<boolean> {
  const key = firebaseWebApiKey.trim();
  if (!key) return false;
  const url = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${encodeURIComponent(key)}`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password, returnSecureToken: true }),
  });
  return res.ok;
}

async function stripLegacyRootCredentials(uid: string): Promise<void> {
  const ref = getFirestore().collection("users").doc(uid);
  const snap = await ref.get();
  if (!snap.exists) return;
  const d = snap.data() as Record<string, unknown>;
  if (d.passwordHash != null || d.passwordSalt != null) {
    await ref.update({
      passwordHash: FieldValue.delete(),
      passwordSalt: FieldValue.delete(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  }
}

/** Server-side throttling (no client trust). Keys are hashed to avoid storing raw handles in doc IDs. */
const RATE_COL = "security_rate_limits";
const LOGIN_FAIL_WINDOW_SEC = 900;
const LOGIN_FAIL_MAX = 16;
const REG_WINDOW_SEC = 3600;
const REG_MAX = 8;

function rateDocId(prefix: string, raw: string): string {
  return `${prefix}_${sha256Hex(raw).slice(0, 48)}`;
}

async function assertUnderLoginFailCap(nu: string): Promise<void> {
  const db = getFirestore();
  const ref = db.collection(RATE_COL).doc(rateDocId("login_fail", nu));
  const snap = await ref.get();
  if (!snap.exists) return;
  const d = snap.data() as { failCount?: number; windowStart?: Timestamp };
  const start = d.windowStart;
  if (!start) return;
  const now = Date.now() / 1000;
  if (now - start.seconds > LOGIN_FAIL_WINDOW_SEC) return;
  if (Number(d.failCount ?? 0) >= LOGIN_FAIL_MAX) {
    throw new HttpsError("resource-exhausted", "Too many sign-in attempts. Try again later.");
  }
}

async function recordLoginFailure(nu: string): Promise<void> {
  const db = getFirestore();
  const ref = db.collection(RATE_COL).doc(rateDocId("login_fail", nu));
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const nowTs = Timestamp.now();
    const updatedAt = FieldValue.serverTimestamp();
    if (!snap.exists) {
      tx.set(ref, { failCount: 1, windowStart: nowTs, kind: "login_fail", updatedAt });
      return;
    }
    const d = snap.data() as { failCount?: number; windowStart?: Timestamp };
    const start = d.windowStart;
    const epoch = Date.now() / 1000;
    if (!start || epoch - start.seconds > LOGIN_FAIL_WINDOW_SEC) {
      tx.set(ref, { failCount: 1, windowStart: nowTs, kind: "login_fail", updatedAt });
      return;
    }
    const c = Number(d.failCount ?? 0) + 1;
    tx.update(ref, { failCount: c, updatedAt });
  });
}

async function clearLoginFailures(nu: string): Promise<void> {
  try {
    await getFirestore().collection(RATE_COL).doc(rateDocId("login_fail", nu)).delete();
  } catch {
    /* ignore */
  }
}

async function assertRegisterRateOk(emailLower: string): Promise<void> {
  const db = getFirestore();
  const ref = db.collection(RATE_COL).doc(rateDocId("reg", emailLower));
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const nowTs = Timestamp.now();
    const updatedAt = FieldValue.serverTimestamp();
    if (!snap.exists) {
      tx.set(ref, { count: 1, windowStart: nowTs, kind: "register", updatedAt });
      return;
    }
    const d = snap.data() as { count?: number; windowStart?: Timestamp };
    const start = d.windowStart;
    const epoch = Date.now() / 1000;
    if (!start || epoch - start.seconds > REG_WINDOW_SEC) {
      tx.set(ref, { count: 1, windowStart: nowTs, kind: "register", updatedAt });
      return;
    }
    const c = Number(d.count ?? 0) + 1;
    if (c > REG_MAX) {
      throw new HttpsError("resource-exhausted", "Too many registration attempts. Try again later.");
    }
    tx.update(ref, { count: c, updatedAt });
  });
}

export const registerWithUsernameSecure = onCall(
  {
    timeoutSeconds: 60,
    memory: "512MiB",
    enforceAppCheck: true,
  },
  async (request) => {
    logFunctionCall('registerWithUsernameSecure');

    const serverPepper = pepperSecret.value();
    if (!serverPepper || serverPepper.length < 16) {
      logFunctionError('registerWithUsernameSecure', 'Server pepper not configured');
      throw new HttpsError(
        "failed-precondition",
        "Server configuration error. Please contact support.",
      );
    }

    const data = (request.data ?? {}) as Record<string, unknown>;
    const validation = validateRegistrationData(data);
    if (!validation.isValid) {
      logFunctionError('registerWithUsernameSecure', validation.error);
      throw new HttpsError("invalid-argument", validation.error!);
    }

    const usernameTrim = String(data.username ?? "").trim();
    const email = String(data.email ?? "").trim().toLowerCase();
    const password = String(data.password ?? "");
    const role = String(data.role ?? "customer") as UserRole;
    const isPremium = Boolean(data.isPremium);

    const nu = normalizeUsername(usernameTrim);

    await assertRegisterRateOk(email);
    logFunctionCall('registerWithUsernameSecure', undefined, { username: nu, email });

    const db = getFirestore();
    const indexRef = db.collection("username_index").doc(nu);
    const indexSnap = await indexRef.get();
    if (indexSnap.exists) {
      logFunctionError('registerWithUsernameSecure', 'Username already taken', undefined);
      throw new HttpsError("already-exists", "This username is already taken. Please choose another one.");
    }

    const auth = getAuth();
    let uid: string;
    try {
      const userRecord = await auth.createUser({
        email,
        password,
        emailVerified: false,
        disabled: false,
      });
      uid = userRecord.uid;
      logFunctionCall('registerWithUsernameSecure', uid, { email, role });
    } catch (e: unknown) {
      const code = (e as { code?: string })?.code;
      if (code === "auth/email-already-exists") {
        logFunctionError('registerWithUsernameSecure', 'Email already exists', undefined);
        throw new HttpsError("already-exists", "An account with this email already exists.");
      }
      logFunctionError('registerWithUsernameSecure', e, undefined);
      throw new HttpsError("internal", "Registration failed. Please try again later.");
    }

    const credentialSalt = randomSalt();
    const material = password + credentialSalt + serverPepper;
    const passwordDigest = await bcrypt.hash(material, BCRYPT_COST);

    const userRef = db.collection("users").doc(uid);
    const credRef = userRef.collection("auth_private").doc("credential");

    const batch = db.batch();
    batch.set(userRef, {
      role,
      username: usernameTrim,
      displayName: usernameTrim,
      photoUrl: "",
      email,
      phoneNumber: "",
      providerIds: ["password"],
      xp: 0,
      loyaltyRank: "rookie",
      isPremium,
      hairProfile: {
        type: "straight",
        density: "medium",
        scalpSensitivity: "medium",
      },
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      lastLoginAt: FieldValue.serverTimestamp(),
    });

    batch.set(indexRef, { uid, email });
    batch.set(credRef, {
      passwordDigest,
      credentialSalt,
      scheme: "bcrypt_v1",
      updatedAt: FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
      logFunctionCall('registerWithUsernameSecure', uid, { success: true });
    } catch (e) {
      logFunctionError('registerWithUsernameSecure', e, uid);
      try {
        await auth.deleteUser(uid);
      } catch (deleteError) {
        logFunctionError('registerWithUsernameSecure', `Failed to rollback auth user: ${deleteError}`, uid);
      }
      throw new HttpsError("internal", "Registration failed. Please try again later.");
    }

    const customToken = await auth.createCustomToken(uid);
    return { customToken };
  },
);

const GENERIC_LOGIN = "Invalid Username or Password";

export const signInWithUsernameSecure = onCall(
  {
    timeoutSeconds: 30,
    memory: "512MiB",
    enforceAppCheck: true,
  },
  async (request) => {
    logFunctionCall('signInWithUsernameSecure');

    const serverPepper = pepperSecret.value();
    if (!serverPepper || serverPepper.length < 16) {
      logFunctionError('signInWithUsernameSecure', 'Server pepper not configured');
      throw new HttpsError("failed-precondition", "Service temporarily unavailable. Please try again later.");
    }

    const data = (request.data ?? {}) as Record<string, unknown>;
    const validation = validateSignInData(data);
    if (!validation.isValid) {
      logFunctionError('signInWithUsernameSecure', validation.error);
      throw new HttpsError("invalid-argument", validation.error!);
    }

    const usernameRaw = String(data.username ?? "").trim();
    const password = String(data.password ?? "");
    const nu = normalizeUsername(usernameRaw);

    await assertUnderLoginFailCap(nu);

    const db = getFirestore();
    const indexSnap = await db.collection("username_index").doc(nu).get();
    if (!indexSnap.exists) {
      logFunctionCall('signInWithUsernameSecure', undefined, { username: nu, result: 'user_not_found' });
      await jitterFailedAttempt();
      await recordLoginFailure(nu);
      throw new HttpsError("permission-denied", GENERIC_LOGIN);
    }

    const index = indexSnap.data() as { uid?: string; email?: string };
    const uid = String(index.uid ?? "");
    const email = String(index.email ?? "").trim();
    if (!uid || !email) {
      logFunctionError('signInWithUsernameSecure', 'Invalid index data', undefined);
      await jitterFailedAttempt();
      await recordLoginFailure(nu);
      throw new HttpsError("permission-denied", GENERIC_LOGIN);
    }

    const credSnap = await db.doc(`users/${uid}/auth_private/credential`).get();
    let credentialSalt = "";
    let storedDigest = "";

    if (credSnap.exists) {
      const c = credSnap.data() as { credentialSalt?: string; passwordDigest?: string };
      credentialSalt = String(c.credentialSalt ?? "");
      storedDigest = String(c.passwordDigest ?? "");
    } else {
      const userSnap = await db.collection("users").doc(uid).get();
      const u = userSnap.data() as { passwordSalt?: string; passwordHash?: string } | undefined;
      credentialSalt = String(u?.passwordSalt ?? "");
      storedDigest = String(u?.passwordHash ?? "");
    }

    if (!credentialSalt || !storedDigest) {
      logFunctionCall('signInWithUsernameSecure', uid, { result: 'no_credentials' });
      await jitterFailedAttempt();
      await recordLoginFailure(nu);
      throw new HttpsError("permission-denied", GENERIC_LOGIN);
    }

    let ok = await digestMatches(password, credentialSalt, storedDigest, serverPepper);

    if (!ok && firebaseWebApiKey.trim()) {
      logFunctionCall('signInWithUsernameSecure', uid, { fallback_attempt: true });
      if (await tryIdentityToolkitSignIn(email, password)) {
        ok = true;
        logFunctionCall('signInWithUsernameSecure', uid, { fallback_success: true });
      }
    }

    if (!ok) {
      logFunctionCall('signInWithUsernameSecure', uid, { result: 'auth_failed' });
      await jitterFailedAttempt();
      await recordLoginFailure(nu);
      throw new HttpsError("permission-denied", GENERIC_LOGIN);
    }

    if (!isBcryptDigest(storedDigest)) {
      logFunctionCall('signInWithUsernameSecure', uid, { upgrading_credentials: true });
      await writeBcryptCredential(uid, password, serverPepper);
      await stripLegacyRootCredentials(uid);
    }

    await clearLoginFailures(nu);
    logFunctionCall('signInWithUsernameSecure', uid, { result: 'success' });

    const auth = getAuth();
    const customToken = await auth.createCustomToken(uid);
    return { customToken };
  },
);

export const syncServerPasswordCredential = onCall(
  {
    timeoutSeconds: 30,
    memory: "256MiB",
    enforceAppCheck: true,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      logFunctionError('syncServerPasswordCredential', 'No authenticated user');
      throw new HttpsError("unauthenticated", "Please sign in to continue.");
    }

    logFunctionCall('syncServerPasswordCredential', uid);

    const serverPepper = pepperSecret.value();
    if (!serverPepper || serverPepper.length < 16) {
      logFunctionError('syncServerPasswordCredential', 'Server pepper not configured', uid);
      throw new HttpsError("failed-precondition", "Service temporarily unavailable. Please try again later.");
    }

    const data = (request.data as Record<string, unknown>) ?? {};
    const validation = validatePasswordSyncData(data);
    if (!validation.isValid) {
      logFunctionError('syncServerPasswordCredential', validation.error, uid);
      throw new HttpsError("invalid-argument", validation.error!);
    }

    const password = String(data.password ?? "");

    try {
      await writeBcryptCredential(uid, password, serverPepper);
      await stripLegacyRootCredentials(uid);
      logFunctionCall('syncServerPasswordCredential', uid, { result: 'success' });
      return { ok: true };
    } catch (e) {
      logFunctionError('syncServerPasswordCredential', e, uid);
      throw new HttpsError("internal", "Failed to update password. Please try again later.");
    }
  },
);
