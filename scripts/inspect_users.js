const admin = require('firebase-admin');

// Connect to Firestore emulator
process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';

// Initialize admin with projectId only to avoid needing credentials
admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT || 'style-sync-84923' });
const db = admin.firestore();

async function findByEmail(email) {
  const q = db.collection('users').where('email', '==', email.toLowerCase()).limit(5);
  const snap = await q.get();
  console.log(`\nResults for email: ${email} (found ${snap.size})`);
  snap.forEach(doc => {
    console.log('--- doc id:', doc.id);
    console.log(JSON.stringify(doc.data(), null, 2));
  });
}

async function findWithStripeFields() {
  const q = db.collection('users').where('stripeCustomerId', '!=', null).limit(50);
  const snap = await q.get();
  console.log(`\nUsers with stripeCustomerId (found ${snap.size})`);
  snap.forEach(doc => {
    console.log('--- doc id:', doc.id);
    console.log(JSON.stringify(doc.data(), null, 2));
  });
}

(async () => {
  try {
    const emails = ['sargado.antonio@dnsc.edu.ph', 'everst231@gmail.com', 'sargado.antonio@dnsc.edu.ph'];
    for (const e of emails) {
      await findByEmail(e);
    }
    await findWithStripeFields();
  } catch (err) {
    console.error('Error:', err);
    process.exitCode = 1;
  }
})();