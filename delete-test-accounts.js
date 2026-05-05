#!/usr/bin/env node

const https = require('https');
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
  },
  {
    email: 'tolentino.roniandave@dnsc.edu.ph',
    password: 'PremiumPass456!@#',
  },
];

function makeRequest(hostname, path, body, method = 'POST') {
  return new Promise((resolve, reject) => {
    const bodyString = JSON.stringify(body);
    const options = {
      hostname: hostname,
      port: 443,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': bodyString.length,
      },
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          resolve({ status: res.statusCode, data: jsonData });
        } catch (e) {
          resolve({ status: res.statusCode, data: data });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(bodyString);
    req.end();
  });
}

async function signInUser(email, password) {
  console.log(`\n🔐 Signing in as ${email}...`);
  try {
    const response = await makeRequest('identitytoolkit.googleapis.com', '/v1/accounts:signInWithPassword?key=' + WEB_API_KEY, {
      email: email,
      password: password,
      returnSecureToken: true,
    });

    if (response.data.idToken) {
      console.log(`✅ Signed in successfully. Got ID token.`);
      return response.data.idToken;
    } else if (response.data.error) {
      console.log(`❌ Sign in failed: ${response.data.error.message}`);
      return null;
    }
  } catch (error) {
    console.log(`❌ Error signing in: ${error.message}`);
    return null;
  }
}

async function deleteAccount(idToken) {
  console.log(`🗑️  Deleting account...`);
  try {
    const response = await makeRequest('identitytoolkit.googleapis.com', '/v1/accounts:delete?key=' + WEB_API_KEY, {
      idToken: idToken,
    });

    if (response.status === 200) {
      console.log(`✅ Account deleted successfully!`);
      return true;
    } else if (response.data.error) {
      console.log(`❌ Deletion failed: ${response.data.error.message}`);
      return false;
    } else {
      console.log(`❌ Deletion failed with status ${response.status}`);
      return false;
    }
  } catch (error) {
    console.log(`❌ Error deleting account: ${error.message}`);
    return false;
  }
}

async function deleteAllTestAccounts() {
  console.log('═'.repeat(60));
  console.log('🔥 FIREBASE TEST ACCOUNT DELETION SCRIPT');
  console.log('═'.repeat(60));
  console.log(`Project ID: ${PROJECT_ID}`);
  console.log(`API Key: ${WEB_API_KEY.substring(0, 20)}...`);

  let deletedCount = 0;

  for (const account of testAccounts) {
    try {
      const idToken = await signInUser(account.email, account.password);
      
      if (idToken) {
        const deleted = await deleteAccount(idToken);
        if (deleted) {
          deletedCount++;
        }
      } else {
        console.log(`⏭️  Skipping deletion - account may not exist`);
      }
    } catch (error) {
      console.log(`❌ Error processing ${account.email}: ${error.message}`);
    }

    // Add delay between requests to avoid rate limiting
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  console.log('\n' + '═'.repeat(60));
  console.log(`📊 DELETION SUMMARY: ${deletedCount}/${testAccounts.length} accounts deleted`);
  console.log('═'.repeat(60));
  console.log('\n✅ Ready to create new test accounts!');
}

deleteAllTestAccounts().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
