const admin = require('firebase-admin');

async function main() {
  // Initialize using project id so emulator env vars route to emulator
  admin.initializeApp({ projectId: process.env.FIREBASE_PROJECT || 'stylesync' });
  const db = admin.firestore();

  const shopId = 'e2e_test_shop';
  const shopRef = db.collection('shops').doc(shopId);

  console.log('Creating shop...');
  await shopRef.set({ ownerId: 'owner1', name: 'Elcorte E2E', address: '1 Elcorte Plaza', ticketCount: 0 });

  console.log('Adding two tickets (Alice premium, Bob standard)...');
  const t1 = await shopRef.collection('queue').doc();
  await t1.set({ userId: 'user_alice', username: 'Alice', isPremium: true, joinedAt: admin.firestore.FieldValue.serverTimestamp() });
  const t2 = await shopRef.collection('queue').doc();
  await t2.set({ userId: 'user_bob', username: 'Bob', isPremium: false, joinedAt: admin.firestore.FieldValue.serverTimestamp() });

  // update ticketCount
  await shopRef.update({ ticketCount: 2 });

  console.log('Current queue (ordered premium-first):');
  const listSnap = await shopRef.collection('queue')
    .orderBy('isPremium', 'desc')
    .orderBy('joinedAt', 'asc')
    .get();
  listSnap.docs.forEach((d, i) => {
    console.log(i+1, d.id, JSON.stringify(d.data()));
  });

  // Call next
  console.log('\nCalling next...');
  const nextSnap = await shopRef.collection('queue')
    .orderBy('isPremium', 'desc')
    .orderBy('joinedAt', 'asc')
    .limit(1)
    .get();
  if (nextSnap.empty) {
    console.log('No next ticket');
  } else {
    const nextDoc = nextSnap.docs[0];
    await nextDoc.ref.update({ status: 'called', calledAt: admin.firestore.FieldValue.serverTimestamp() });
    await shopRef.update({ currentServingTicketId: nextDoc.id });
    console.log('Called ticket:', nextDoc.id);
  }

  // Show shop and called ticket
  const shop = (await shopRef.get()).data();
  console.log('\nShop doc after call:', JSON.stringify(shop));

  const calledId = shop.currentServingTicketId;
  if (calledId) {
    const calledDoc = (await shopRef.collection('queue').doc(calledId).get());
    console.log('Called ticket doc:', calledDoc.id, JSON.stringify(calledDoc.data()));
  }

  // Mark served: delete called ticket and clear currentServingTicketId
  console.log('\nMarking served (deleting called ticket)...');
  if (calledId) {
    await shopRef.collection('queue').doc(calledId).delete();
    await shopRef.update({ currentServingTicketId: admin.firestore.FieldValue.delete(), ticketCount: admin.firestore.FieldValue.increment(-1) });
    console.log('Deleted ticket', calledId);
  }

  console.log('\nFinal queue:');
  const finalSnap = await shopRef.collection('queue').orderBy('isPremium', 'desc').orderBy('joinedAt', 'asc').get();
  finalSnap.docs.forEach((d, i) => console.log(i+1, d.id, JSON.stringify(d.data())));

  const finalShop = (await shopRef.get()).data();
  console.log('Final shop doc:', JSON.stringify(finalShop));

  console.log('\nE2E test complete.');
}

main().catch(err => { console.error(err); process.exitCode = 1; });
