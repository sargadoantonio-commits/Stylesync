#!/usr/bin/env node

const fs = require('fs');
const http = require('http');
const path = require('path');

// Firebase project config
const PROJECT_ID = 'style-sync-84923';
const AUTH_EMULATOR_HOST = 'localhost:9099';

const testAccounts = [
  {
    email: 'roniandave@gmail.com',
    password: 'TestPassword123!@#',
    displayName: 'Roni Dave',
  },
  {
    email: 'tolentino.roniandave@dnsc.edu.ph',
    password: 'PremiumPass456!@#',
    displayName: 'Roni Tolentino',
  },
];

function makeRequest(method, path, body) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 9099,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            data: JSON.parse(data),
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            data: data,
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (body) {
      req.write(JSON.stringify(body));
    }

    req.end();
  });
}

async function createAccounts() {
  console.log('\n═══════════════════════════════════════════════════');
  console.log('  📱 CREATING TEST ACCOUNTS IN FIREBASE EMULATOR\n');
  console.log('═══════════════════════════════════════════════════\n');

  for (const account of testAccounts) {
    try {
      const { email, password, displayName } = account;
      console.log(`📝 Creating: ${email}`);

      // Create user via emulator REST API
      const response = await makeRequest(
        'POST',
        `/identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDu3GKnLU0-Wqm-JjJjWqjWqjWqjWqjWq`,
        {
          email: email,
          password: password,
          displayName: displayName,
          returnSecureToken: true,
        }
      );

      if (response.status === 200) {
        const uid = response.data.localId;
        console.log(`   ✅ Account created (UID: ${uid})`);
        console.log(`   ✅ Email: ${email}`);
        console.log(`   ✅ Password: ${password}\n`);
      } else {
        console.log(`   ⚠️  Response: ${response.status}`);
        console.log(`   Data: ${JSON.stringify(response.data)}\n`);
      }
    } catch (error) {
      console.error(`   ❌ Error: ${error.message}`);
      console.error(`   ${error.stack}\n`);
    }
  }

  console.log('═══════════════════════════════════════════════════');
  console.log('  ✅ Accounts Ready for Login!\n');
  console.log('  Account 1 (FREE):');
  console.log('  - Email: roniandave@gmail.com');
  console.log('  - Password: TestPassword123!@#\n');
  console.log('  Account 2 (PREMIUM):');
  console.log('  - Email: tolentino.roniandave@dnsc.edu.ph');
  console.log('  - Password: PremiumPass456!@#');
  console.log('═══════════════════════════════════════════════════\n');
}

createAccounts().catch(console.error);
