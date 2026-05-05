#!/usr/bin/env node

const https = require('https');
const googleServices = require('./google-services.json');

const PROJECT_ID = googleServices.project_info.project_id;
const WEB_API_KEY = googleServices.client[0].api_key[0].current_key;

// Your specified test accounts
const testAccounts = [
  {
    email: 'roniandave@gmail.com',
    password: 'RegularCustomer123!@#',
    displayName: 'Roni Dave',
    role: 'customer',
  },
  {
    email: 'tolentino.roniandave@dnsc.edu.ph',
    password: 'PremiumCustomer456!@#',
    displayName: 'Roni Tolentino',
    role: 'premium_customer',
  },
  {
    email: 'sargado.antonioe@dnsc.edu.ph',
    password: 'BarberStylist789!@#',
    displayName: 'Antonie Sargado',
    role: 'barber',
  },
  {
    email: 'rato.frankjay@dnsc.edu.ph',
    password: 'ShopOwner000!@#',
    displayName: 'Frank Jay Rato',
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

async function createAccount(email, password, displayName, role) {
  console.log(`\n👤 Creating account: ${email}`);
  console.log(`   Role: ${role}`);
  try {
    const response = await makeRequest('identitytoolkit.googleapis.com', '/v1/accounts:signUp?key=' + WEB_API_KEY, {
      email: email,
      password: password,
      displayName: displayName,
      returnSecureToken: true,
    });

    if (response.data.idToken) {
      console.log(`✅ Account created successfully!`);
      return { success: true, uid: response.data.localId, email: email };
    } else if (response.data.error) {
      console.log(`⚠️  Account may already exist: ${response.data.error.message}`);
      return { success: false, email: email, error: response.data.error.message };
    }
  } catch (error) {
    console.log(`❌ Error creating account: ${error.message}`);
    return { success: false, email: email, error: error.message };
  }
}

async function createAllTestAccounts() {
  console.log('═'.repeat(70));
  console.log('✨ STYLESYNC TEST ACCOUNT CREATION');
  console.log('═'.repeat(70));
  console.log(`Project ID: ${PROJECT_ID}`);
  console.log(`Creating ${testAccounts.length} test accounts with all user roles...\n`);

  const results = [];

  for (const account of testAccounts) {
    try {
      const result = await createAccount(account.email, account.password, account.displayName, account.role);
      results.push(result);
    } catch (error) {
      console.log(`❌ Error processing ${account.email}: ${error.message}`);
      results.push({ success: false, email: account.email, error: error.message });
    }

    await new Promise(resolve => setTimeout(resolve, 1500));
  }

  // Summary
  const successCount = results.filter(r => r.success).length;
  console.log('\n' + '═'.repeat(70));
  console.log(`📊 CREATION SUMMARY: ${successCount}/${testAccounts.length} accounts ready`);
  console.log('═'.repeat(70));

  console.log('\n🔐 TEST ACCOUNT CREDENTIALS:');
  console.log('─'.repeat(70));
  
  for (let i = 0; i < testAccounts.length; i++) {
    const account = testAccounts[i];
    const roleEmoji = account.role === 'customer' ? '👥' : 
                     account.role === 'premium_customer' ? '⭐' :
                     account.role === 'barber' ? '✂️' : '👔';
    
    console.log(`\n${roleEmoji} ${account.role.toUpperCase()}`);
    console.log(`   Email:    ${account.email}`);
    console.log(`   Password: ${account.password}`);
    console.log(`   Name:     ${account.displayName}`);
  }

  console.log('\n' + '═'.repeat(70));
  console.log('🎯 ACCOUNT PURPOSES:');
  console.log('─'.repeat(70));
  console.log('👥 Regular Customer: Books haircuts, browses barbers');
  console.log('⭐ Premium Customer: VIP bookings, loyalty benefits');
  console.log('✂️  Barber/Stylist: Accepts bookings, manages schedule');
  console.log('👔 Shop Owner: Manages staff, analytics, settings');
  console.log('\n✅ Ready for comprehensive app testing!');
  console.log('═'.repeat(70));
}

createAllTestAccounts().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
