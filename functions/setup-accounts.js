#!/usr/bin/env node

/**
 * StyleSync Test Account Creation Script
 * Creates test accounts directly in Firebase emulator
 */

const admin = require('firebase-admin');
const path = require('path');

// Use environment variables for emulator
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';

// Initialize Firebase Admin SDK
const serviceAccountPath = path.join(__dirname, '..', 'google-services.json');

try {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id || 'stylesync-app',
  });
} catch (err) {
  console.log('📡 Connecting to Firebase emulator...');
  admin.initializeApp({
    projectId: 'stylesync-app',
  });
}

const auth = admin.auth();
const db = admin.firestore();

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

async function createAccounts() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('   StyleSync - Test Account Creation');
  console.log('═══════════════════════════════════════════════════════════\n');

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

      const uid = userRecord.uid;
      console.log(`  ✅ Auth user created (UID: ${uid})`);

      // Create Firestore user document
      const now = new Date();
      const premiumExpiresAt = isPremium
        ? new Date(now.getTime() + 365 * 24 * 60 * 60 * 1000)
        : null;

      await db.collection('users').doc(uid).set({
        uid: uid,
        email: email,
        displayName: displayName,
        role: 'customer',
        isPremium: isPremium,
        premiumExpiresAt: premiumExpiresAt,
        accountStatus: 'active',
        profileComplete: false,
        createdAt: now,
        updatedAt: now,
        bio: `Test ${isPremium ? 'Premium' : 'Free'} Customer`,
        verified: false,
        notifications: {
          email: true,
          push: true,
          sms: false,
        },
      });
      console.log('  ✅ Firestore user document created');

      // Create username index
      const username = email.split('@')[0];
      await db.collection('username_index').doc(username).set({
        uid: uid,
        email: email,
        createdAt: now,
      });
      console.log('  ✅ Username index created\n');

      // Print account details
      console.log('📊 Account Details:');
      console.log(`   Email: ${email}`);
      console.log(`   Password: ${password}`);
      console.log(`   Name: ${displayName}`);
      console.log(`   UID: ${uid}`);
      console.log(`   Premium: ${isPremium}\n`);
    } catch (error) {
      console.error(`❌ Error creating account: ${error.message}\n`);
    }
  }
}

async function main() {
  try {
    await createAccounts();

    console.log('═══════════════════════════════════════════════════════════');
    console.log('✅ Test accounts created successfully!');
    console.log('═══════════════════════════════════════════════════════════\n');

    console.log('🎯 You can now log in with:');
    console.log('   Email: roniandave@gmail.com');
    console.log('   Password: TestPassword123!@#\n');
    console.log('   OR\n');
    console.log('   Email: tolentino.roniandave@dnsc.edu.ph');
    console.log('   Password: PremiumPass456!@#\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Setup failed:', error);
    process.exit(1);
  }
}

main();
