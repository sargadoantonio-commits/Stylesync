const admin = require('firebase-admin');

const projectId = process.env.GCLOUD_PROJECT || 'style-sync-84923';
const uid = process.argv[2];
const subscriptionId = process.argv[3];
if (!uid || !subscriptionId) {
  console.error('Usage: node set_subscription_id.js <uid> <subscriptionId>');
  process.exit(1);
}

process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';

admin.initializeApp({ projectId });
const db = admin.firestore();

(async () => {
  try {
    const userRef = db.collection('users').doc(uid);
    await userRef.set({ stripeSubscriptionId: subscriptionId, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    console.log('Set subscription', subscriptionId, 'on user', uid);
  } catch (err) {
    console.error('Error updating user:', err);
    process.exit(2);
  }
})();