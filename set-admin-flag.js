#!/usr/bin/env node

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Load service account (if available)
let serviceAccount;
try {
  const serviceAccountPath = path.join(__dirname, 'firebase-adminsdk.json');
  if (fs.existsSync(serviceAccountPath)) {
    serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
  }
} catch (e) {
  console.log('Service account file not found, using environment credentials');
}

// Initialize Firebase Admin
if (serviceAccount) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} else {
  // Fall back to GOOGLE_APPLICATION_CREDENTIALS environment variable
  admin.initializeApp({
    projectId: 'style-sync-84923',
  });
}

const db = admin.firestore();
const auth = admin.auth();

const ADMIN_EMAIL = 'sargado.antonioe@dnsc.edu.ph';

async function setAdminFlag() {
  console.log('═'.repeat(70));
  console.log('👑 SETTING ADMIN FLAG FOR PLATFORM ADMIN');
  console.log('═'.repeat(70));

  try {
    console.log(`\n🔍 Finding user: ${ADMIN_EMAIL}`);
    
    // Get user by email
    const userRecord = await auth.getUserByEmail(ADMIN_EMAIL);
    console.log(`✅ Found user: ${userRecord.uid}`);
    
    // Update Firestore document
    console.log(`\n🔧 Setting admin flag in Firestore...`);
    await db.collection('users').doc(userRecord.uid).update({
      isAdmin: true,
    });
    
    console.log(`✅ Admin flag set successfully!`);
    
    // Verify the update
    const docSnapshot = await db.collection('users').doc(userRecord.uid).get();
    const userData = docSnapshot.data();
    
    console.log('\n📊 Updated User Profile:');
    console.log('─'.repeat(70));
    console.log(`UID:       ${userRecord.uid}`);
    console.log(`Email:     ${userData.email}`);
    console.log(`Name:      ${userData.displayName}`);
    console.log(`Role:      ${userData.role}`);
    console.log(`Is Admin:  ${userData.isAdmin ? '✅ YES' : '❌ NO'}`);
    
    console.log('\n═'.repeat(70));
    console.log('✅ ADMIN ACCOUNT SETUP COMPLETE!');
    console.log('═'.repeat(70));
    console.log('\n🎯 Admin can now:');
    console.log('   • Monitor all bookings in real-time');
    console.log('   • View all barbers and their performance');
    console.log('   • Track customer activity');
    console.log('   • See revenue analytics');
    console.log('   • Monitor shop operations');
    
    console.log('\n📱 Login with:');
    console.log(`   Email:    ${ADMIN_EMAIL}`);
    console.log(`   Password: BarberStylist789!@#`);
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    
    if (error.code === 'auth/user-not-found') {
      console.log('\n⚠️  User not found. Make sure the account was created first.');
      console.log('   Run: node setup-stylesync-accounts.js');
    }
    
    process.exit(1);
  }
  
  process.exit(0);
}

setAdminFlag();
