const admin = require('firebase-admin');

async function main() {
  admin.initializeApp({ projectId: process.env.FIREBASE_PROJECT || 'stylesync' });
  const auth = admin.auth();

  const email = process.env.TEST_USER_EMAIL || 'tester@local.test';
  const password = process.env.TEST_USER_PW || 'TestPass123!';

  try {
    const user = await auth.getUserByEmail(email);
    console.log('User already exists:', user.uid);
    return;
  } catch (e) {
    // create user
  }

  const userRecord = await auth.createUser({
    email,
    password,
    displayName: 'EmuTester',
  });
  console.log('Created auth user:', userRecord.uid, email);
}

main().catch(err => { console.error(err); process.exitCode = 1; });
