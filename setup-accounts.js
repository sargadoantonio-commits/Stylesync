#!/usr/bin/env node

const admin = require('firebase-admin');
const serviceAccount = require('./google-services.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: serviceAccount.project_id,
});

const auth = admin.auth();
const firestore = admin.firestore().useEmulator('localhost', 8080);

const testAccounts = [
  {
    email: 'roniandave@gmail.com',
    password: 'TestPassword123!@#',
    displayName: 'Roni Dave',
    isPremium: false,
  },
  {
    email: 'tolentino.roniandave@dnsc.edu.ph',
    password: 'PremiumPass456!@#',
    displayName: 'Roni Tolentino',
    isPremium: true,
  },
];

async function deleteExistingAccounts() {
  console.log('🔍 Checking for existing accounts in Firebase...\n');

  for (const account of testAccounts) {
    const email = account.email;
    try {
      // Check if user exists
      try {
        const user = await auth.getUserByEmail(email);
        console.log(`  ⚠️  Found existing account: ${email}`);
        
        // Delete from Firestore
        const usersQuery = await firestore
          .collection('users')
          .where('email', '==', email)
          .get();

        for (const doc of usersQuery.docs) {
          await doc.ref.delete();
          console.log('     ✅ Deleted user document from Firestore');
        }

        // Delete from username index
        const username = email.split('@')[0];
        await firestore.collection('username_index').doc(username).delete();
        console.log(`     ✅ Deleted username index for "${username}"`);

        // Delete from Auth
        await auth.deleteUser(user.uid);
        console.log('     ✅ Deleted auth user\n');
      } catch (err) {
        if (err.code === 'auth/user-not-found') {
          console.log(`  ℹ️  Account not found in Firebase: ${email}\n`);
        } else {
          throw err;
        }
      }
    } catch (error) {
      console.error(`  ❌ Error checking account: ${error.message}\n`);
    }
  }
}

async function createTestAccounts() {
  console.log('🚀 Creating test accounts...\n');

  for (const account of testAccounts) {
    try {
      const { email, password, displayName, isPremium } = account;
      console.log(`📝 Creating: ${email}`);

      // Create Auth user
      const userRecord = await auth.createUser({
        email: email,
        password: password,
        displayName: displayName,
      });

      console.log(`   ✅ Auth user created (UID: ${userRecord.uid})`);

      // Create Firestore document
      const username = email.split('@')[0];
      
      await firestore.collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        email: email,
        displayName: displayName,
        username: username,
        role: 'customer',
        isPremium: isPremium,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        profileImageUrl: '',
        bio: '',
        phone: '',
        address: '',
        city: '',
        state: '',
        country: '',
        zipCode: '',
      });

      console.log(`   ✅ Firestore user document created`);

      // Create username index
      await firestore.collection('username_index').doc(username).set({
        uid: userRecord.uid,
        email: email,
      });

      console.log(`   ✅ Username index created\n`);
    } catch (error) {
      console.error(`   ❌ Error: ${error.message}\n`);
    }
  }
}

async function verifyAccounts() {
  console.log('✅ Verifying created accounts...\n');

  for (const account of testAccounts) {
    try {
      const user = await auth.getUserByEmail(account.email);
      const userDoc = await firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        const data = userDoc.data();
        console.log(`✓ ${account.email}`);
        console.log(`  - UID: ${user.uid}`);
        console.log(`  - Role: ${data.role}`);
        console.log(`  - Premium: ${data.isPremium}`);
        console.log(`  - Created: ${data.createdAt}\n`);
      }
    } catch (error) {
      console.error(`✗ ${account.email}: ${error.message}\n`);
    }
  }
}

async function main() {
  try {
    console.log('═══════════════════════════════════════════════════\n');
    console.log('  📱 STYLESYNC TEST ACCOUNT SETUP\n');
    console.log('═══════════════════════════════════════════════════\n');

    await deleteExistingAccounts();
    await createTestAccounts();
    await verifyAccounts();

    console.log('═══════════════════════════════════════════════════');
    console.log('  ✅ Setup Complete!\n');
    console.log('  Login with:');
    console.log('  - Email: roniandave@gmail.com (Free)');
    console.log('  - Password: TestPassword123!@#\n');
    console.log('  - Email: tolentino.roniandave@dnsc.edu.ph (Premium)');
    console.log('  - Password: PremiumPass456!@#');
    console.log('═══════════════════════════════════════════════════\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Fatal error:', error);
    process.exit(1);
  }
}

main();
