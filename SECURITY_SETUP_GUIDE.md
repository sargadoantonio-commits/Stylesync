# StyleSync Security Setup Guide

## 1. Firebase Secret Manager Setup (HIGH PRIORITY)

### Step 1: Upgrade Firebase Project to Blaze Plan
- Go to Firebase Console → Billing → Switch to Blaze (pay-as-you-go)
- Secret Manager is free for most use cases

### Step 2: Create Pepper Secret
```bash
# Generate secure random pepper (at least 32 characters)
openssl rand -base64 32

# Example output: (copy this)
# abc123XYZ+/abc123XYZ+/abc123XYZ+/abc123XYZ=

# Set the secret in Firebase
firebase functions:secrets:set STYLESYNC_PEPPER
# Paste the generated pepper value when prompted

# Verify it was set
firebase functions:secrets:get STYLESYNC_PEPPER
```

### Step 3: Update Cloud Functions to Use Secret
In `functions/src/auth_secure.ts`, replace:
```typescript
const pepperSecret = {
  value: () => "STYLESYNC_DEVELOPMENT_PEPPER_UPGRADE_TO_BLAZE_FOR_PRODUCTION_SECURITY"
};
```

With:
```typescript
import { defineSecret } from 'firebase-functions/params';

const STYLESYNC_PEPPER = defineSecret('STYLESYNC_PEPPER');

// In your function:
export const registerSecure = onCall(
  { secrets: [STYLESYNC_PEPPER] },
  async (request) => {
    const pepper = STYLESYNC_PEPPER.value();
    // Use pepper for hashing...
  }
);
```

### Step 4: Deploy
```bash
firebase deploy --only functions
```

---

## 2. Session Timeout (HIGH PRIORITY)

Implement automatic logout after inactivity (15-30 minutes).

**File: `lib/features/auth/presentation/providers/session_timeout_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

final sessionTimeoutProvider = StateNotifierProvider<SessionTimeoutNotifier, bool>((ref) {
  return SessionTimeoutNotifier(ref, FirebaseAuth.instance);
});

class SessionTimeoutNotifier extends StateNotifier<bool> {
  SessionTimeoutNotifier(this.ref, this._auth) : super(false) {
    _startSessionTimer();
  }

  final Ref ref;
  final FirebaseAuth _auth;
  Timer? _sessionTimer;
  Timer? _warningTimer;
  
  static const sessionTimeout = Duration(minutes: 30);
  static const warningBefore = Duration(minutes: 29);

  void _startSessionTimer() {
    _resetSessionTimer();
  }

  void _resetSessionTimer() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();

    // Warn user after 29 minutes
    _warningTimer = Timer(warningBefore, () {
      state = true; // Show warning
    });

    // Auto logout after 30 minutes
    _sessionTimer = Timer(sessionTimeout, () {
      _logoutUser();
    });
  }

  void _logoutUser() async {
    await _auth.signOut();
    state = false;
  }

  void resetInactivityTimer() {
    if (_auth.currentUser != null) {
      _resetSessionTimer();
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    super.dispose();
  }
}
```

---

## 3. Password Breach Detection (HIGH PRIORITY)

Check passwords against Have I Been Pwned API.

**File: `functions/src/breach_detection.ts`**

```typescript
import axios from 'axios';
import { createHash } from 'crypto';

const HIBP_API = 'https://api.pwnedpasswords.com/range';

export async function checkPasswordBreach(password: string): Promise<{ breached: boolean; count?: number }> {
  try {
    const sha1 = createHash('sha1').update(password).digest('hex').toUpperCase();
    const prefix = sha1.substring(0, 5);
    const suffix = sha1.substring(5);

    const response = await axios.get(`${HIBP_API}/${prefix}`, {
      timeout: 5000,
    });

    const lines = response.data.split('\r\n');
    for (const line of lines) {
      const [hash, count] = line.split(':');
      if (hash === suffix) {
        return { breached: true, count: parseInt(count) };
      }
    }

    return { breached: false };
  } catch (error) {
    // If API fails, allow login (don't block user)
    console.warn('HIBP check failed:', error);
    return { breached: false };
  }
}

// In registerSecure:
export const registerSecure = onCall(
  { secrets: [STYLESYNC_PEPPER] },
  async (request) => {
    const password = request.data.password;
    
    const breach = await checkPasswordBreach(password);
    if (breach.breached) {
      throw new HttpsError('invalid-argument', 
        `This password has been compromised in ${breach.count} data breaches. Please use a stronger, unique password.`);
    }
    // Continue with registration...
  }
);
```

---

## 4. 2FA (MFA) Support (MEDIUM PRIORITY)

Enable email-based OTP verification.

**File: `lib/features/auth/presentation/providers/mfa_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

final mfaProvider = FutureProvider.family<String, String>((ref, email) async {
  final functions = FirebaseFunctions.instance;
  
  final result = await functions
      .httpsCallable('sendMfaOtp')
      .call({'email': email});
  
  return result.data['sessionId']; // Return session ID for verification
});

final verifyMfaProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  final functions = FirebaseFunctions.instance;
  
  final result = await functions
      .httpsCallable('verifyMfaOtp')
      .call({
        'sessionId': params['sessionId'],
        'otp': params['otp'],
      });
  
  return result.data['verified'] as bool;
});
```

**File: `functions/src/mfa.ts`**

```typescript
import { sendEmail } from './email_service';

interface MfaSession {
  email: string;
  otp: string;
  expiresAt: number;
  attempts: number;
}

const mfaSessions: Map<string, MfaSession> = new Map();

export const sendMfaOtp = onCall({ enforceAppCheck: true }, async (request) => {
  const email = String(request.data.email).toLowerCase().trim();
  
  if (!email.includes('@')) {
    throw new HttpsError('invalid-argument', 'Invalid email');
  }

  // Generate 6-digit OTP
  const otp = String(Math.floor(100000 + Math.random() * 900000));
  const sessionId = randomBytes(32).toString('hex');
  
  // Store session (expires in 10 minutes)
  mfaSessions.set(sessionId, {
    email,
    otp,
    expiresAt: Date.now() + 10 * 60 * 1000,
    attempts: 0,
  });

  // Send OTP via email
  await sendEmail(email, {
    subject: 'StyleSync Login Verification Code',
    template: 'mfa_otp',
    data: { otp, expiresIn: '10 minutes' },
  });

  return { sessionId };
});

export const verifyMfaOtp = onCall({ enforceAppCheck: true }, async (request) => {
  const { sessionId, otp } = request.data;
  
  const session = mfaSessions.get(sessionId);
  if (!session) {
    throw new HttpsError('not-found', 'MFA session expired');
  }

  if (Date.now() > session.expiresAt) {
    mfaSessions.delete(sessionId);
    throw new HttpsError('deadline-exceeded', 'OTP expired');
  }

  if (session.attempts >= 3) {
    mfaSessions.delete(sessionId);
    throw new HttpsError('permission-denied', 'Too many attempts');
  }

  session.attempts++;

  if (otp === session.otp) {
    mfaSessions.delete(sessionId);
    return { verified: true };
  }

  throw new HttpsError('permission-denied', 'Invalid OTP');
});
```

---

## 5. Audit Logging (MEDIUM PRIORITY)

Track all authentication events for compliance.

**File: `functions/src/audit_log.ts`**

```typescript
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

export interface AuditLogEntry {
  userId?: string;
  email?: string;
  action: string; // 'login', 'registration', 'password_change', 'mfa_enabled', etc.
  status: 'success' | 'failure';
  reason?: string;
  ipAddress?: string;
  userAgent?: string;
  timestamp: FieldValue;
}

export async function logAuditEvent(entry: AuditLogEntry): Promise<void> {
  const firestore = getFirestore();
  
  try {
    await firestore.collection('audit_logs').add({
      ...entry,
      timestamp: FieldValue.serverTimestamp(),
    });

    // Log sensitive actions to console for monitoring
    if (['password_change', 'mfa_enabled', 'suspicious_activity'].includes(entry.action)) {
      console.log(`[SECURITY] ${entry.action}: ${entry.email || entry.userId}`, {
        status: entry.status,
        reason: entry.reason,
      });
    }
  } catch (error) {
    console.error('Failed to log audit event:', error);
  }
}

// Usage in Cloud Functions:
export const signInSecure = onCall(async (request) => {
  try {
    // ... authentication logic ...
    
    await logAuditEvent({
      email: userEmail,
      action: 'login',
      status: 'success',
      ipAddress: request.rawRequest?.ip,
      userAgent: request.rawRequest?.headers['user-agent'],
    });
  } catch (error) {
    await logAuditEvent({
      email: userEmail,
      action: 'login',
      status: 'failure',
      reason: error.message,
      ipAddress: request.rawRequest?.ip,
    });
    throw error;
  }
});
```

---

## 6. Suspicious Activity Detection (MEDIUM PRIORITY)

Detect and flag unusual login patterns.

**File: `functions/src/anomaly_detection.ts`**

```typescript
interface LoginAttempt {
  timestamp: number;
  ipAddress: string;
  country?: string;
}

const loginAttempts: Map<string, LoginAttempt[]> = new Map();

export async function detectSuspiciousActivity(userId: string, ipAddress: string): Promise<{
  suspicious: boolean;
  reason?: string;
}> {
  if (!loginAttempts.has(userId)) {
    loginAttempts.set(userId, []);
  }

  const now = Date.now();
  const attempts = loginAttempts.get(userId)!;
  
  // Remove attempts older than 24 hours
  const recentAttempts = attempts.filter(a => now - a.timestamp < 24 * 60 * 60 * 1000);
  recentAttempts.push({ timestamp: now, ipAddress });
  loginAttempts.set(userId, recentAttempts);

  // Check for brute force: >5 failed logins in 15 minutes
  const last15Min = recentAttempts.filter(a => now - a.timestamp < 15 * 60 * 1000);
  if (last15Min.length > 5) {
    return { suspicious: true, reason: 'Brute force detected' };
  }

  // Check for geographic impossibility: login from 2 countries in <1 hour
  const uniqueCountries = new Set(recentAttempts.map(a => a.country));
  if (uniqueCountries.size > 1) {
    return { suspicious: true, reason: 'Geographic anomaly detected' };
  }

  return { suspicious: false };
}
```

---

## 7. Biometric Authentication (LOW PRIORITY)

Add fingerprint/face recognition.

**File: `lib/features/auth/presentation/providers/biometric_provider.dart`**

```dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final biometricProvider = FutureProvider<bool>((ref) async {
  final localAuth = LocalAuthentication();
  return await localAuth.canCheckBiometrics;
});

final authenticateWithBiometricProvider = FutureProvider((ref) async {
  final localAuth = LocalAuthentication();
  
  try {
    return await localAuth.authenticate(
      localizedReason: 'Sign in to StyleSync',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
  } catch (e) {
    return false;
  }
});
```

Add to `pubspec.yaml`:
```yaml
dependencies:
  local_auth: ^2.1.0
```

---

## Deployment Checklist

- [ ] Upgrade Firebase to Blaze plan
- [ ] Create STYLESYNC_PEPPER secret in Firebase Secret Manager
- [ ] Update `auth_secure.ts` to use secrets
- [ ] Deploy Cloud Functions: `firebase deploy --only functions`
- [ ] Add session timeout provider to Flutter app
- [ ] Add breach detection to registration
- [ ] Enable 2FA in Firestore security rules
- [ ] Set up audit logging collection
- [ ] Implement anomaly detection
- [ ] Add biometric authentication option
- [ ] Update auth UI screens to show MFA/biometric options
- [ ] Test all security flows in staging
- [ ] Deploy to production

---

## Production Security Best Practices

1. **Never log passwords** (even in errors)
2. **Use HTTPS only** (Firebase handles this)
3. **Rotate pepper quarterly** (update Secret Manager)
4. **Monitor audit logs** for suspicious patterns
5. **Review security rules monthly**
6. **Keep dependencies updated**: `flutter pub upgrade --major-versions`
7. **Use Dart Frog or Cloud Functions v2** (more secure than v1)
8. **Enable DDoS protection** (Google Cloud Armor)

---

## References

- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Bcrypt Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [Have I Been Pwned API](https://haveibeenpwned.com/API/v3)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
