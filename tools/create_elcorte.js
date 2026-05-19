const admin = require('firebase-admin');

async function main() {
  admin.initializeApp({ projectId: process.env.FIREBASE_PROJECT || 'stylesync' });
  const db = admin.firestore();

  const shopId = 'elcorte';
  const shopRef = db.collection('shops').doc(shopId);

  console.log('Creating shop elcorte...');
  await shopRef.set({ ownerId: 'owner1', name: 'Elcorte', address: '1 Elcorte Plaza', ticketCount: 0 });
  console.log('Shop created:', shopId);
}

main().catch(err => { console.error(err); process.exitCode = 1; });
