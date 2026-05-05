import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";

initializeApp();

export {
  registerWithUsernameSecure,
  signInWithUsernameSecure,
  syncServerPasswordCredential,
} from "./auth_secure.js";

function logFunctionCall(functionName: string, userId?: string, additionalData?: Record<string, unknown>): void {
  console.log(`[${new Date().toISOString()}] ${functionName} called${userId ? ` for user ${userId}` : ''}`, additionalData || '');
}

function logFunctionError(functionName: string, error: unknown, userId?: string): void {
  console.error(`[${new Date().toISOString()}] ${functionName} error${userId ? ` for user ${userId}` : ''}:`, error);
}

type LoyaltyRank = "rookie" | "regular" | "elite" | "legend";

function computeRank(xp: number): LoyaltyRank {
  if (xp >= 5000) return "legend";
  if (xp >= 2000) return "elite";
  if (xp >= 600) return "regular";
  return "rookie";
}

function computeXpDelta(amountPeso: number): number {
  // PH-friendly, not too grindy: 1 XP per ± 10, minimum 10 XP, cap 250 XP.
  const delta = Math.floor(amountPeso / 10);
  return Math.max(10, Math.min(250, delta));
}

/**
 * When a barber confirms payment, update:
 * - users/{customerId}.xp and loyaltyRank
 * - users/{customerId}/suki_stats/{barberId}.visitCount and lastVisitDate
 *
 * Expected service doc (shops/{shopId}/services/{serviceId}):
 * { shopId, barberId, customerId, amount, paymentConfirmedAt, ... }
 */
export const onPaymentConfirmed = onDocumentUpdated(
  "shops/{shopId}/services/{serviceId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) {
      logFunctionError('onPaymentConfirmed', 'Missing event data');
      return;
    }

    const beforeConfirmed = before["paymentConfirmedAt"];
    const afterConfirmed = after["paymentConfirmedAt"];

    // Only run once: null -> timestamp transition.
    if (beforeConfirmed != null || afterConfirmed == null) return;

    const customerId = String(after["customerId"] ?? "");
    const barberId = String(after["barberId"] ?? "");
    const amount = Number(after["amount"] ?? 0);

    logFunctionCall('onPaymentConfirmed', customerId, { barberId, amount });

    if (!customerId || !barberId || !Number.isFinite(amount) || amount <= 0) {
      logFunctionError('onPaymentConfirmed', 'Invalid service data', customerId);
      return;
    }

    const db = getFirestore();
    const userRef = db.collection("users").doc(customerId);
    const sukiRef = userRef.collection("suki_stats").doc(barberId);

    try {
      await db.runTransaction(async (tx) => {
        const userSnap = await tx.get(userRef);
        if (!userSnap.exists) {
          logFunctionError('onPaymentConfirmed', 'User not found', customerId);
          return;
        }

        const currentXp = Number(userSnap.get("xp") ?? 0);
        const delta = computeXpDelta(amount);
        const nextXp = currentXp + delta;
        const nextRank = computeRank(nextXp);

        logFunctionCall('onPaymentConfirmed', customerId, {
          currentXp,
          delta,
          nextXp,
          nextRank,
          barberId
        });

        tx.update(userRef, {
          xp: nextXp,
          loyaltyRank: nextRank,
          updatedAt: FieldValue.serverTimestamp(),
        });

        const now = Timestamp.now();
        const sukiSnap = await tx.get(sukiRef);
        if (!sukiSnap.exists) {
          tx.set(sukiRef, {
            visitCount: 1,
            lastVisitDate: now,
          });
        } else {
          tx.update(sukiRef, {
            visitCount: FieldValue.increment(1),
            lastVisitDate: now,
          });
        }
      });
      logFunctionCall('onPaymentConfirmed', customerId, { result: 'success' });
    } catch (e) {
      logFunctionError('onPaymentConfirmed', e, customerId);
    }
  },
);

