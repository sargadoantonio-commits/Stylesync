#!/usr/bin/env node

const https = require('https');
const googleServices = require('./google-services.json');

const PROJECT_ID = googleServices.project_info.project_id;

let apiKey = null;
if (googleServices.client && googleServices.client[0] && googleServices.client[0].api_key && googleServices.client[0].api_key[0]) {
  apiKey = googleServices.client[0].api_key[0].current_key;
}

const WEB_API_KEY = apiKey || 'AIzaSyAi5U1CJTr9ec5m7jWqjWqjWqjWqjWqjWq';

// Fresh test accounts
const testAccounts = [
  {
    email: 'roniandave@gmail.com',
    password: 'TestPassword123!@#',
    displayName: 'Roni Dave',
    role: 'user',
  },
  {
    email: 'tolentino.roniandave@dnsc.edu.ph',
    password: 'PremiumPass456!@#',
    displayName: 'Roni Tolentino',
    role: 'barber',
  },
  {
    email: 'shopowner@stylesync.com',
    password: 'ShopOwnerPass789!@#',
    displayName: 'Shop Owner',
    role: 'shop_owner',
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

async function createAccount(email, password, displayName) {
  console.log(`\n👤 Creating account: ${email}`);
  try {
    const response = await makeRequest('identitytoolkit.googleapis.com', '/v1/accounts:signUp?key=' + WEB_API_KEY, {
      email: email,
      password: password,
      displayName: displayName,
      returnSecureToken: true,
    });

    if (response.data.idToken) {
      console.log(`✅ Account created successfully!`);
      console.log(`   Email: ${email}`);
      console.log(`   Display Name: ${displayName}`);
      return { success: true, uid: response.data.localId, email: email };
    } else if (response.data.error) {
      console.log(`❌ Creation failed: ${response.data.error.message}`);
      return { success: false, email: email, error: response.data.error.message };
    }
  } catch (error) {
    console.log(`❌ Error creating account: ${error.message}`);
    return { success: false, email: email, error: error.message };
  }
}

async function createAllTestAccounts() {
  console.log('═'.repeat(60));
  console.log('✨ FIREBASE TEST ACCOUNT CREATION SCRIPT');
  console.log('═'.repeat(60));
  console.log(`Project ID: ${PROJECT_ID}`);
  console.log(`API Key: ${WEB_API_KEY.substring(0, 20)}...`);
  console.log(`Creating ${testAccounts.length} test accounts...\n`);

  const results = [];

  for (const account of testAccounts) {
    try {
      const result = await createAccount(account.email, account.password, account.displayName);
      results.push(result);
    } catch (error) {
      console.log(`❌ Error processing ${account.email}: ${error.message}`);
      results.push({ success: false, email: account.email, error: error.message });
    }

    // Add delay between requests to avoid rate limiting
    await new Promise(resolve => setTimeout(resolve, 1500));
  }

  // Summary
  const successCount = results.filter(r => r.success).length;
  console.log('\n' + '═'.repeat(60));
  console.log(`📊 CREATION SUMMARY: ${successCount}/${testAccounts.length} accounts created`);
  console.log('═'.repeat(60));

  console.log('\n🔐 TEST ACCOUNT CREDENTIALS:');
  console.log('─'.repeat(60));
  for (const account of testAccounts) {
    console.log(`\nEmail:    ${account.email}`);
    console.log(`Password: ${account.password}`);
    console.log(`Role:     ${account.role}`);
  }

  console.log('\n' + '═'.repeat(60));
  if (successCount === testAccounts.length) {
    console.log('✅ All accounts created successfully!');
  } else {
    console.log(`⚠️  ${testAccounts.length - successCount} accounts failed to create`);
  }
  console.log('═'.repeat(60));
}

createAllTestAccounts().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
