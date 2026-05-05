#!/usr/bin/env node

const http = require('http');
const https = require('https');

// Get API key from google-services.json
const googleServices = require('./google-services.json');

// Find the API key
let apiKey = null;
if (googleServices.client && googleServices.client[0]) {
  const client = googleServices.client[0];
  if (client.api_key && client.api_key[0]) {
    apiKey = client.api_key[0].current_key;
  }
}

const PROJECT_ID = googleServices.project_info.project_id;
const WEB_API_KEY = apiKey || 'AIzaSyDu3GKnLU0-Wqm-JjJjWqjWqjWqjWqjWq';

console.log(`📋 Using Project ID: ${PROJECT_ID}`);
console.log(`🔑 Using API Key: ${WEB_API_KEY.substring(0, 20)}...\n`);

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

async function createAccounts() {
  console.log('═══════════════════════════════════════════════════');
  console.log('  📱 CREATING TEST ACCOUNTS IN FIREBASE\n');
  console.log('═══════════════════════════════════════════════════\n');

  for (const account of testAccounts) {
    try {
      const { email, password, displayName } = account;
      console.log(`📝 Creating: ${email}`);

      // Create user via Firebase REST API
      const response = await makeRequest(
        'identitytoolkit.googleapis.com',
        `/v1/accounts:signUp?key=${WEB_API_KEY}`,
        {
          email: email,
          password: password,
          displayName: displayName,
          returnSecureToken: true,
        }
      );

      if (response.status === 200 && response.data.localId) {
        const uid = response.data.localId;
        console.log(`   ✅ Account created`);
        console.log(`   ✅ UID: ${uid}`);
        console.log(`   ✅ Can login now\n`);
      } else if (response.data.error) {
        console.log(`   ⚠️  Firebase Response:`);
        console.log(`   Error Code: ${response.data.error.code}`);
        console.log(`   Message: ${response.data.error.message}\n`);
      } else {
        console.log(`   Response: ${JSON.stringify(response.data)}\n`);
      }
    } catch (error) {
      console.error(`   ❌ Error: ${error.message}\n`);
    }
  }

  console.log('═══════════════════════════════════════════════════');
  console.log('  ✅ Accounts Created!\n');
  console.log('  Login with:');
  console.log('  - Email: roniandave@gmail.com');
  console.log('  - Password: TestPassword123!@#\n');
  console.log('  - Email: tolentino.roniandave@dnsc.edu.ph');
  console.log('  - Password: PremiumPass456!@#');
  console.log('═══════════════════════════════════════════════════\n');
}

createAccounts().catch(console.error);
