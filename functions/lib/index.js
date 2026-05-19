"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.stripeWebhook = exports.onPaymentConfirmed = exports.createBasicTestPayment = exports.refreshPremiumSubscription = exports.createPremiumSubscription = exports.syncServerPasswordCredential = exports.signInWithUsernameSecure = exports.registerWithUsernameSecure = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const app_1 = require("firebase-admin/app");
const firestore_2 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const stripe_1 = __importDefault(require("stripe"));
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
async function getStripePlanPayload(db, tier) {
    const envPriceName = tier === 'yearly' ? 'STRIPE_YEARLY_PRICE_ID' : 'STRIPE_MONTHLY_PRICE_ID';
    const priceId = process.env[envPriceName]?.trim();
    if (priceId)
        return { price_id: priceId };
    try {
        const doc = await db.collection('plans').doc(tier).get();
        if (doc.exists) {
            const data = doc.data();
            if (data.stripe_price_id)
                return { price_id: String(data.stripe_price_id) };
            if (data.price_id)
                return { price_id: String(data.price_id) };
        }
    }
    catch (e) {
        // ignore
    }
    return {};
}
function requireStripeSecret() {
    const secret = process.env.STRIPE_SECRET_KEY?.trim();
    if (!secret) {
        throw new https_1.HttpsError('failed-precondition', 'Stripe is not configured. Set STRIPE_SECRET_KEY in Functions environment variables.');
    }
    return secret;
}
async function createStripeCheckoutSession(uid, tier) {
    const db = (0, firestore_2.getFirestore)();
    const userRef = db.collection('users').doc(uid);
    const userSnap = await userRef.get();
    if (!userSnap.exists) {
        throw new https_1.HttpsError('not-found', 'User profile not found.');
    }
    const email = String(userSnap.get('email') ?? '').trim().toLowerCase();
    const displayName = String(userSnap.get('displayName') ?? userSnap.get('username') ?? 'StyleSync User').trim();
    if (!email) {
        throw new https_1.HttpsError('failed-precondition', 'A profile email is required before creating a Stripe subscription.');
    }
    const stripeSecret = requireStripeSecret();
    const stripe = new stripe_1.default(stripeSecret, { apiVersion: '2022-11-15' });
    const planPayload = await getStripePlanPayload(db, tier);
    if (!planPayload.price_id) {
        throw new https_1.HttpsError('failed-precondition', 'No Stripe price ID configured for this tier.');
    }
    // Create a Checkout Session for subscription
    const successUrl = process.env.STRIPE_SUCCESS_URL ?? 'https://example.com/success?session_id={CHECKOUT_SESSION_ID}';
    const cancelUrl = process.env.STRIPE_CANCEL_URL ?? 'https://example.com/cancel';
    const session = await stripe.checkout.sessions.create({
        mode: 'subscription',
        payment_method_types: ['card'],
        customer_email: email,
        line_items: [
            { price: planPayload.price_id, quantity: 1 },
        ],
        success_url: successUrl,
        cancel_url: cancelUrl,
        metadata: {
            stylesync_uid: uid,
            subscription_tier: tier,
        },
    });
    // Persist minimal session info so client can check status later
    await userRef.set({
        stripeCheckoutSessionId: session.id,
        stripeCheckoutUrl: session.url ?? null,
        premiumTier: tier,
        updatedAt: firestore_2.FieldValue.serverTimestamp(),
    }, { merge: true });
    return { sessionId: session.id, url: session.url ?? undefined, status: 'pending' };
}
async function fetchAndSyncStripeSubscription(uid) {
    const db = (0, firestore_2.getFirestore)();
    const userRef = db.collection('users').doc(uid);
    const userSnap = await userRef.get();
    if (!userSnap.exists) {
        throw new https_1.HttpsError('not-found', 'User profile not found.');
    }
    const subscriptionId = String(userSnap.get('stripeSubscriptionId') ?? '').trim();
    if (!subscriptionId) {
        throw new https_1.HttpsError('failed-precondition', 'No Stripe subscription is linked to this account.');
    }
    const stripeSecret = requireStripeSecret();
    const stripe = new stripe_1.default(stripeSecret, { apiVersion: '2022-11-15' });
    const subscription = await stripe.subscriptions.retrieve(subscriptionId);
    const status = subscription.status ?? 'unknown';
    await userRef.set({
        stripeSubscriptionStatus: status,
        isPremium: status === 'active' || status === 'trialing',
        premiumActivatedAt: status === 'active' ? firestore_2.FieldValue.serverTimestamp() : userSnap.get('premiumActivatedAt') ?? null,
        updatedAt: firestore_2.FieldValue.serverTimestamp(),
    }, { merge: true });
    return { subscriptionId, status };
}
exports.createPremiumSubscription = (0, https_1.onCall)({
    timeoutSeconds: 60,
    memory: "512MiB",
    enforceAppCheck: true,
    secrets: ["STRIPE_SECRET_KEY"],
}, async (request) => {
    if (!request.auth?.uid) {
        throw new https_1.HttpsError("unauthenticated", "Please sign in before subscribing.");
    }
    const data = (request.data ?? {});
    const tier = String(data.tier ?? "monthly");
    if (tier !== "monthly" && tier !== "yearly") {
        throw new https_1.HttpsError("invalid-argument", "Tier must be either monthly or yearly.");
    }
    try {
        // Return the static Payment Link for the tier
        const linkEnvVar = tier === 'yearly' ? 'STRIPE_YEARLY_PAYMENT_LINK' : 'STRIPE_MONTHLY_PAYMENT_LINK';
        let paymentLink = process.env[linkEnvVar]?.trim();
        if (!paymentLink) {
            throw new https_1.HttpsError('failed-precondition', `No Payment Link configured for ${tier} tier.`);
        }
        // If we have the user's email, append it to the payment link to prefill checkout email
        const userEmail = String(request.auth.token?.email ?? "").trim().toLowerCase();
        if (userEmail) {
            const separator = paymentLink.includes('?') ? '&' : '?';
            const encoded = encodeURIComponent(userEmail);
            paymentLink = `${paymentLink}${separator}prefilled_email=${encoded}`;
        }
        // Log the subscription request
        logFunctionCall('createPremiumSubscription', request.auth.uid, { tier, paymentLink, userEmail });
        return {
            tier,
            success: true,
            redirectUrl: paymentLink,
            status: 'pending',
            provider: 'stripe',
        };
    }
    catch (err) {
        logFunctionError('createPremiumSubscription', err, request.auth.uid);
        if (err instanceof https_1.HttpsError)
            throw err;
        throw new https_1.HttpsError("internal", "Failed to create subscription link.");
    }
});
exports.refreshPremiumSubscription = (0, https_1.onCall)({
    timeoutSeconds: 60,
    memory: "512MiB",
    enforceAppCheck: true,
    secrets: ["STRIPE_SECRET_KEY"],
}, async (request) => {
    if (!request.auth?.uid) {
        throw new https_1.HttpsError("unauthenticated", "Please sign in before checking your subscription.");
    }
    // Only support Stripe for subscription status refresh.
    if (!process.env.STRIPE_SECRET_KEY) {
        throw new https_1.HttpsError('failed-precondition', 'Stripe is not configured. Set STRIPE_SECRET_KEY in Functions environment variables.');
    }
    const result = await fetchAndSyncStripeSubscription(request.auth.uid);
    return result;
});
exports.createBasicTestPayment = (0, https_1.onCall)({
    timeoutSeconds: 30,
    memory: "256MiB",
    enforceAppCheck: false,
}, async (request) => {
    if (!request.auth?.uid) {
        throw new https_1.HttpsError("unauthenticated", "Please sign in before testing a payment.");
    }
    const data = (request.data ?? {});
    const phone = String(data.phone ?? "").trim();
    const method = String(data.method ?? "gcash").toLowerCase();
    const tier = String(data.tier ?? "monthly");
    if (!phone) {
        throw new https_1.HttpsError("invalid-argument", "A phone number is required for test payments.");
    }
    const uid = request.auth.uid;
    const db = (0, firestore_2.getFirestore)();
    const userRef = db.collection("users").doc(uid);
    // Create a lightweight test payment record and mark user premium for testing.
    const paymentRef = db.collection("test_payments").doc();
    await paymentRef.set({
        uid,
        phone,
        method,
        tier,
        createdAt: firestore_2.FieldValue.serverTimestamp(),
        simulated: true,
    });
    await userRef.set({
        isPremium: true,
        premiumActivatedAt: firestore_2.FieldValue.serverTimestamp(),
        premiumTier: tier,
        testPaymentMethod: method,
        testPaymentPhone: phone,
        updatedAt: firestore_2.FieldValue.serverTimestamp(),
    }, { merge: true });
    return { success: true, message: "Test payment recorded and premium enabled." };
});
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
/**
 * Stripe Webhook handler
 * Listens for checkout.session.completed and customer.subscription.updated events
 * Updates user premium status in Firestore when payment is confirmed
 */
exports.stripeWebhook = (0, https_1.onRequest)({ cors: true }, async (request, response) => {
    if (request.method !== 'POST') {
        response.status(405).send('Method not allowed');
        return;
    }
    const stripe = new stripe_1.default(process.env.STRIPE_SECRET_KEY ?? '', { apiVersion: '2022-11-15' });
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET?.trim();
    if (!webhookSecret) {
        logFunctionError('stripeWebhook', 'STRIPE_WEBHOOK_SECRET not configured');
        response.status(400).send('Webhook secret not configured');
        return;
    }
    let event;
    try {
        const sig = request.headers['stripe-signature'];
        event = stripe.webhooks.constructEvent(request.rawBody || request.body, sig, webhookSecret);
    }
    catch (err) {
        logFunctionError('stripeWebhook', `Signature verification failed: ${err}`);
        response.status(400).send(`Webhook Error: ${err}`);
        return;
    }
    logFunctionCall('stripeWebhook', undefined, { eventType: event.type });
    const db = (0, firestore_2.getFirestore)();
    try {
        // Handle checkout.session.completed event
        if (event.type === 'checkout.session.completed') {
            const session = event.data.object;
            const uid = session.metadata?.stylesync_uid;
            const tier = session.metadata?.subscription_tier;
            // subscription id can be present on the session (for subscriptions)
            const subscriptionId = session.subscription || undefined;
            if (uid) {
                const userRef = db.collection('users').doc(uid);
                await userRef.set({
                    stripeCustomerId: session.customer,
                    stripeCheckoutSessionId: session.id,
                    stripeSubscriptionId: subscriptionId || null,
                    stripeSubscriptionStatus: subscriptionId ? 'active' : 'pending',
                    isPremium: subscriptionId ? true : false,
                    premiumActivatedAt: subscriptionId ? firestore_2.FieldValue.serverTimestamp() : null,
                    premiumTier: tier || 'monthly',
                    updatedAt: firestore_2.FieldValue.serverTimestamp(),
                }, { merge: true });
                logFunctionCall('stripeWebhook', uid, { event: 'checkout_completed', tier, subscriptionId });
            }
            else {
                // Try to match by customer email if metadata wasn't provided
                const email = session.customer_details?.email || session.customer_email || '';
                if (email) {
                    const usersRef = db.collection('users');
                    const querySnap = await usersRef.where('email', '==', String(email).toLowerCase()).limit(1).get();
                    if (!querySnap.empty) {
                        const userRef = querySnap.docs[0].ref;
                        const uidFound = userRef.id;
                        await userRef.set({
                            stripeCustomerId: session.customer,
                            stripeCheckoutSessionId: session.id,
                            stripeSubscriptionId: subscriptionId || null,
                            stripeSubscriptionStatus: subscriptionId ? 'active' : 'pending',
                            isPremium: subscriptionId ? true : false,
                            premiumActivatedAt: subscriptionId ? firestore_2.FieldValue.serverTimestamp() : null,
                            premiumTier: tier || 'monthly',
                            updatedAt: firestore_2.FieldValue.serverTimestamp(),
                        }, { merge: true });
                        logFunctionCall('stripeWebhook', uidFound, { event: 'checkout_completed_by_email', email, subscriptionId });
                    }
                    else {
                        logFunctionCall('stripeWebhook', undefined, { event: 'checkout_completed_no_user', email });
                    }
                }
                else {
                    logFunctionCall('stripeWebhook', undefined, { event: 'checkout_completed_no_metadata_or_email' });
                }
            }
        }
        // Handle customer.subscription.updated event
        if (event.type === 'customer.subscription.updated' || event.type === 'customer.subscription.created') {
            const subscription = event.data.object;
            const customerId = subscription.customer;
            // Find user by Stripe customer ID
            const usersRef = db.collection('users');
            const querySnap = await usersRef.where('stripeCustomerId', '==', customerId).limit(1).get();
            if (!querySnap.empty) {
                const userRef = querySnap.docs[0].ref;
                const uid = userRef.id;
                const status = subscription.status ?? 'unknown';
                await userRef.set({
                    stripeSubscriptionId: subscription.id,
                    stripeSubscriptionStatus: status,
                    isPremium: status === 'active' || status === 'trialing',
                    updatedAt: firestore_2.FieldValue.serverTimestamp(),
                }, { merge: true });
                logFunctionCall('stripeWebhook', uid, { event: 'subscription_updated_or_created', status });
            }
        }
        response.status(200).json({ received: true });
    }
    catch (err) {
        logFunctionError('stripeWebhook', err);
        response.status(500).send(`Webhook processing error: ${err}`);
    }
});
