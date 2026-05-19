const admin = require('firebase-admin');

const projectId = process.env.GCLOUD_PROJECT || 'style-sync-84923';
const email = process.argv[2];
if (!email) {
  console.error('Usage: node query_user.js <email>');
  process.exit(1);
}

process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';

admin.initializeApp({ projectId });
const db = admin.firestore();

(async () => {
  try {
    const q = await db.collection('users').where('email', '==', email.toLowerCase()).limit(10).get();
    if (q.empty) {
      console.log('No users found for email:', email);
      // Also print any users with similar email casing
      const all = await db.collection('users').limit(50).get();
      console.log('Sample user docs:');
      all.forEach(doc => console.log(doc.id, JSON.stringify(doc.data())));
      process.exit(0);
    }
    q.forEach(doc => console.log('Found user:', doc.id, JSON.stringify(doc.data())));
  } catch (err) {
    console.error('Error querying Firestore:', err);
    process.exit(2);
  }
})();