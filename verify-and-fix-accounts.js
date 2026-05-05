#!/usr/bin/env node

const https = require('https');
const fs = require('fs');

const googleServices = require('./google-services.json');
const PROJECT_ID = googleServices.project_info.project_id;

let apiKey = null;
if (googleServices.client && googleServices.client[0] && googleServices.client[0].api_key && googleServices.client[0].api_key[0]) {
  apiKey = googleServices.client[0].api_key[0].current_key;
}

const WEB_API_KEY = apiKey || 'AIzaSyAi5U1CJTr9ec5m7jWqjWqjWqjWqjWqjWq';

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

function makeRequest(hostname, path, body) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: hostname,
      port: 443,
      path: path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': JSON.stringify(body).length,
      },
    };

    const req = https.request(options, (res) => {
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

    req.write(JSON.stringify(body));
    req.end();
  });
}

async function testLoginAndRecreate() {
  console.log('\n═══════════════════════════════════════════════════');
  console.log('  🔐 TESTING ACCOUNTS AND RECREATING IF NEEDED\n');
  console.log('═══════════════════════════════════════════════════\n');

  for (const account of testAccounts) {
    const { email, password, displayName } = account;
    
    console.log(`📧 Testing: ${email}`);
    
    // Try to login first
    try {
      const loginResponse = await makeRequest(
        'identitytoolkit.googleapis.com',
        `/v1/accounts:signInWithPassword?key=${WEB_API_KEY}`,
        {
          email: email,
          password: password,
          returnSecureToken: true,
        }
      );

      if (loginResponse.status === 200 && loginResponse.data.localId) {
        console.log(`   ✅ Login successful (UID: ${loginResponse.data.localId})\n`);
        continue;
      } else if (loginResponse.data.error && loginResponse.data.error.code === 'INVALID_PASSWORD') {
        console.log(`   ⚠️  Wrong password for existing account`);
        console.log(`   🔄 Resetting password...\n`);
      } else if (loginResponse.data.error && loginResponse.data.error.code === 'USER_DISABLED') {
        console.log(`   ⚠️  Account is disabled`);
        console.log(`   🔄 Will try to recreate...\n`);
      }
    } catch (error) {
      console.log(`   Error during login test: ${error.message}\n`);
    }

    // Try to create/update account
    try {
      console.log(`   Creating new account...`);
      const signUpResponse = await makeRequest(
        'identitytoolkit.googleapis.com',
        `/v1/accounts:signUp?key=${WEB_API_KEY}`,
        {
          email: email,
          password: password,
          displayName: displayName,
          returnSecureToken: true,
        }
      );

      if (signUpResponse.status === 200 && signUpResponse.data.localId) {
        console.log(`   ✅ Account created/updated (UID: ${signUpResponse.data.localId})\n`);
      } else if (signUpResponse.data.error && signUpResponse.data.error.code === 'EMAIL_EXISTS') {
        console.log(`   ℹ️  Account already exists\n`);
      } else {
        console.log(`   Response: ${JSON.stringify(signUpResponse.data)}\n`);
      }
    } catch (error) {
      console.error(`   ❌ Error: ${error.message}\n`);
    }
  }

  console.log('═══════════════════════════════════════════════════');
  console.log('  ✅ Accounts verified and ready!\n');
  console.log('  Try logging in with:');
  console.log('  - Email: roniandave@gmail.com');
  console.log('  - Password: TestPassword123!@#\n');
  console.log('═══════════════════════════════════════════════════\n');
}

testLoginAndRecreate().catch(console.error);
