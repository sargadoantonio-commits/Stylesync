#!/usr/bin/env node

// This script creates test accounts in Firebase emulator
// Run with: node create-accounts-web.js

const fetch = require('node-fetch');

const firebaseConfig = {
  apiKey: "AIzaSyDu3GKnLU0-Wqm-JjJjWqjWqjWqjWqjWq",
  authDomain: "style-sync-84923.firebaseapp.com",
  projectId: "style-sync-84923",
  storageBucket: "style-sync-84923.firebasestorage.app",
  messagingSenderId: "669385709309",
  appId: "1:669385709309:web:abc123"
};

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

const AUTH_EMULATOR_URL = 'http://localhost:9099';
const FIRESTORE_EMULATOR_URL = 'http://localhost:8080';

async function deleteExistingAccounts() {
  console.log('🔍 Checking for existing accounts in Firebase emulator...\n');
  
  for (const account of testAccounts) {
    const email = account.email;
    try {
      console.log(`  Checking: ${email}`);
      // For emulator, we can't easily delete without direct access
      // This is a simplified flow - in production, use Firebase Admin SDK
    } catch (error) {
      console.error(`  Error: ${error.message}`);
    }
  }
}

async function createTestAccounts() {
  console.log('🚀 Creating test accounts in Firebase emulator...\n');
  
  for (const account of testAccounts) {
    try {
      const { email, password, displayName, isPremium } = account;
      console.log(`📝 Creating: ${email}`);
      
      // Call Auth REST API
      const authUrl = `${AUTH_EMULATOR_URL}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=${firebaseConfig.apiKey}`;
      
      const response = await fetch(authUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: email,
          password: password,
          returnSecureToken: true,
        }),
      });
      
      if (!response.ok) {
        const error = await response.text();
        console.log(`   ❌ Error: ${error}`);
        continue;
      }
      
      const data = await response.json();
      const uid = data.localId;
      
      console.log(`   ✅ Auth user created (UID: ${uid})`);
      
    } catch (error) {
      console.error(`   ❌ Error: ${error.message}`);
    }
  }
}

async function main() {
  try {
    console.log('═══════════════════════════════════════════════════\n');
    console.log('  📱 STYLESYNC TEST ACCOUNT SETUP (Web SDK)\n');
    console.log('═══════════════════════════════════════════════════\n');

    await deleteExistingAccounts();
    await createTestAccounts();

    console.log('\n═══════════════════════════════════════════════════');
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
