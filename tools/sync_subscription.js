const admin = require('firebase-admin');
const Stripe = require('stripe');

const projectId = process.env.GCLOUD_PROJECT || 'style-sync-84923';
process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';

admin.initializeApp({ projectId });
const db = admin.firestore();

(async () => {
  try {
    const uid = process.argv[2];
    if (!uid) throw new Error('Usage: node sync_subscription.js <uid>');
    const userRef = db.collection('users').doc(uid);
    const snap = await userRef.get();
    if (!snap.exists) throw new Error('User not found');
    const subscriptionId = snap.get('stripeSubscriptionId');
    if (!subscriptionId) throw new Error('No stripeSubscriptionId on user');

    const stripeKey = process.env.STRIPE_SECRET_KEY;
    if (!stripeKey) throw new Error('STRIPE_SECRET_KEY not set in environment');
    const stripe = new Stripe(stripeKey, { apiVersion: '2022-11-15' });

    const sub = await stripe.subscriptions.retrieve(subscriptionId);
    const status = sub.status || 'unknown';
    await userRef.set({ stripeSubscriptionStatus: status, isPremium: status === 'active' || status === 'trialing', updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    console.log('Synced subscription', subscriptionId, 'status', status);
  } catch (err) {
    console.error(err);
    process.exit(2);
  }
})();