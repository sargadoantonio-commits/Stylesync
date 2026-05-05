#!/usr/bin/env node

const http = require('http');

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

function makeRequest(method, hostname, port, path, data) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: hostname,
      port: port,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = http.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            data: JSON.parse(responseData),
            headers: res.headers,
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            data: responseData,
            headers: res.headers,
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }

    req.end();
  });
}

async function deleteExistingAccounts() {
  console.log('🔍 Checking for existing accounts...\n');
  
  for (const account of testAccounts) {
    const email = account.email;
    try {
      console.log(`  Checking: ${email}`);
      // In emulator mode, we would need direct admin access to delete
      // For now, we'll just try to create new ones
    } catch (error) {
      console.error(`  Error: ${error.message}`);
    }
  }
}

async function createTestAccounts() {
  console.log('🚀 Creating test accounts via Firebase Emulator Auth...\n');

  for (const account of testAccounts) {
    try {
      const { email, password, displayName, isPremium } = account;
      console.log(`📝 Creating: ${email}`);

      // Call Auth Emulator REST API
      const signUpPath = '/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-key';
      
      const signUpData = {
        email: email,
        password: password,
        returnSecureToken: true,
      };

      console.log(`   Making request to localhost:9099${signUpPath}`);
      const signUpResponse = await makeRequest('POST', 'localhost', 9099, signUpPath, signUpData);

      console.log(`   Response status: ${signUpResponse.status}`);
      console.log(`   Response data: ${JSON.stringify(signUpResponse.data)}`);

      if (signUpResponse.status !== 200) {
        console.log(`   ❌ Error: ${signUpResponse.status}`);
        console.log(`      Response: ${JSON.stringify(signUpResponse.data)}`);
        continue;
      }

      const uid = signUpResponse.data.localId;
      console.log(`   ✅ Auth user created (UID: ${uid})`);

      // Now create Firestore document
      // Note: In emulator, we need to use the Firestore REST API
      const firestorePath = `/v1/projects/style-sync-84923/databases/(default)/documents/users/${uid}`;
      
      const firestoreData = {
        fields: {
          uid: { stringValue: uid },
          email: { stringValue: email },
          displayName: { stringValue: displayName },
          username: { stringValue: email.split('@')[0] },
          role: { stringValue: 'customer' },
          isPremium: { booleanValue: isPremium },
          createdAt: { timestampValue: new Date().toISOString() },
          updatedAt: { timestampValue: new Date().toISOString() },
          profileImageUrl: { stringValue: '' },
          bio: { stringValue: '' },
          phone: { stringValue: '' },
          address: { stringValue: '' },
          city: { stringValue: '' },
          state: { stringValue: '' },
          country: { stringValue: '' },
          zipCode: { stringValue: '' },
        },
      };

      const firestoreResponse = await makeRequest('POST', 'localhost', 8080, firestorePath, firestoreData);

      if (firestoreResponse.status >= 200 && firestoreResponse.status < 300) {
        console.log(`   ✅ Firestore user document created`);
      } else {
        console.log(`   ⚠️  Firestore response: ${firestoreResponse.status}`);
      }

      // Create username index
      const indexPath = `/v1/projects/style-sync-84923/databases/(default)/documents/username_index/${email.split('@')[0]}`;
      
      const indexData = {
        fields: {
          uid: { stringValue: uid },
          email: { stringValue: email },
        },
      };

      const indexResponse = await makeRequest('POST', 'localhost', 8080, indexPath, indexData);

      if (indexResponse.status >= 200 && indexResponse.status < 300) {
        console.log(`   ✅ Username index created\n`);
      } else {
        console.log(`   ⚠️  Index response: ${indexResponse.status}\n`);
      }

    } catch (error) {
      console.error(`   ❌ Error: ${error.message}\n`);
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
