"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onPaymentConfirmed = exports.syncServerPasswordCredential = exports.signInWithUsernameSecure = exports.registerWithUsernameSecure = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const app_1 = require("firebase-admin/app");
const firestore_2 = require("firebase-admin/firestore");
(0, app_1.initializeApp)();
var auth_secure_js_1 = require("./auth_secure.js");
Object.defineProperty(exports, "registerWithUsernameSecure", { enumerable: true, get: function () { return auth_secure_js_1.registerWithUsernameSecure; } });
Object.defineProperty(exports, "signInWithUsernameSecure", { enumerable: true, get: function () { return auth_secure_js_1.signInWithUsernameSecure; } });
Object.defineProperty(exports, "syncServerPasswordCredential", { enumerable: true, get: function () { return auth_secure_js_1.syncServerPasswordCredential; } });
function logFunctionCall(functionName, userId, additionalData) {
    console.log(`[${new Date().toISOString()}] ${functionName} called${userId ? ` for user ${userId}` : ''}`, additionalData || '');
}
function logFunctionError(functionName, error, userId) {
    console.error(`[${new Date().toISOString()}] ${functionName} error${userId ? ` for user ${userId}` : ''}:`, error);
}
function computeRank(xp) {
    if (xp >= 5000)
        return "legend";
    if (xp >= 2000)
        return "elite";
    if (xp >= 600)
        return "regular";
    return "rookie";
}
function computeXpDelta(amountPeso) {
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
exports.onPaymentConfirmed = (0, firestore_1.onDocumentUpdated)("shops/{shopId}/services/{serviceId}", async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) {
        logFunctionError('onPaymentConfirmed', 'Missing event data');
        return;
    }
    const beforeConfirmed = before["paymentConfirmedAt"];
    const afterConfirmed = after["paymentConfirmedAt"];
    // Only run once: null -> timestamp transition.
    if (beforeConfirmed != null || afterConfirmed == null)
        return;
    const customerId = String(after["customerId"] ?? "");
    const barberId = String(after["barberId"] ?? "");
    const amount = Number(after["amount"] ?? 0);
    logFunctionCall('onPaymentConfirmed', customerId, { barberId, amount });
    if (!customerId || !barberId || !Number.isFinite(amount) || amount <= 0) {
        logFunctionError('onPaymentConfirmed', 'Invalid service data', customerId);
        return;
    }
    const db = (0, firestore_2.getFirestore)();
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
                updatedAt: firestore_2.FieldValue.serverTimestamp(),
            });
            const now = firestore_2.Timestamp.now();
            const sukiSnap = await tx.get(sukiRef);
            if (!sukiSnap.exists) {
                tx.set(sukiRef, {
                    visitCount: 1,
                    lastVisitDate: now,
                });
            }
            else {
                tx.update(sukiRef, {
                    visitCount: firestore_2.FieldValue.increment(1),
                    lastVisitDate: now,
                });
            }
        });
        logFunctionCall('onPaymentConfirmed', customerId, { result: 'success' });
    }
    catch (e) {
        logFunctionError('onPaymentConfirmed', e, customerId);
    }
});
