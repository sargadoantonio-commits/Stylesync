const admin = require('firebase-admin');

async function main() {
  admin.initializeApp({ projectId: process.env.FIREBASE_PROJECT || 'stylesync' });
  const db = admin.firestore();

  const shopRef = db.collection('shops').doc('elcorte');
  const ticketRef = shopRef.collection('queue').doc();

  await ticketRef.set({
    userId: 'test_user_admin',
    username: 'AdminTest',
    isPremium: false,
    joinedAt: admin.firestore.FieldValue.serverTimestamp(),
    status: 'queued'
  });

  console.log('Created ticket:', ticketRef.id);
}

main().catch(err => { console.error(err); process.exitCode = 1; });
