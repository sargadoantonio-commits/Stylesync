#!/usr/bin/env node

const https = require('https');
const googleServices = require('./google-services.json');

const PROJECT_ID = googleServices.project_info.project_id;
const WEB_API_KEY = googleServices.client[0].api_key[0].current_key;

const ADMIN_EMAIL = 'sargado.antonioe@dnsc.edu.ph';
const ADMIN_PASSWORD = 'BarberStylist789!@#';

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

async function setAdminFlag() {
  console.log('═'.repeat(70));
  console.log('👑 SETTING ADMIN FLAG FOR PLATFORM ADMIN');
  console.log('═'.repeat(70));
  console.log(`Project ID: ${PROJECT_ID}`);
  console.log(`Admin Email: ${ADMIN_EMAIL}\n`);

  try {
    console.log('🔐 Step 1: Signing in as admin user...');
    const signInResponse = await makeRequest(
      'identitytoolkit.googleapis.com',
      '/v1/accounts:signInWithPassword?key=' + WEB_API_KEY,
      {
        email: ADMIN_EMAIL,
        password: ADMIN_PASSWORD,
        returnSecureToken: true,
      }
    );

    if (!signInResponse.data.idToken) {
      throw new Error(signInResponse.data.error?.message || 'Sign in failed');
    }

    const uid = signInResponse.data.localId;
    const idToken = signInResponse.data.idToken;
    console.log(`✅ Signed in successfully! UID: ${uid}`);

    console.log('\n🔧 Step 2: Setting admin flag in Firestore...');
    
    // We'll use a cloud function to set the admin flag
    // But first, let's create the flag update directly via HTTPS
    const firestoreRequest = {
      writes: [
        {
          update: {
            name: `projects/${PROJECT_ID}/databases/(default)/documents/users/${uid}`,
            fields: {
              isAdmin: {
                booleanValue: true
              }
            },
            updateMask: {
              fieldPaths: ['isAdmin']
            }
          }
        }
      ]
    };

    const firestoreResponse = await makeRequest(
      'firestore.googleapis.com',
      `/v1/projects/${PROJECT_ID}/databases/(default)/documents:commit?key=${WEB_API_KEY}`,
      firestoreRequest
    );

    if (firestoreResponse.status === 200) {
      console.log('✅ Admin flag set successfully!');
    } else {
      console.log('⚠️  Firestore update status:', firestoreResponse.status);
      console.log('    Response:', firestoreResponse.data);
    }

    console.log('\n═'.repeat(70));
    console.log('✅ ADMIN ACCOUNT SETUP COMPLETE!');
    console.log('═'.repeat(70));
    console.log('\n🎯 Admin Capabilities:');
    console.log('   📊 Monitor all bookings in real-time');
    console.log('   👥 View all barbers and their performance');
    console.log('   📈 Track customer activity');
    console.log('   💰 See revenue analytics');
    console.log('   🏪 Monitor shop operations');
    
    console.log('\n📱 Admin Login Credentials:');
    console.log(`   Email:    ${ADMIN_EMAIL}`);
    console.log(`   Password: ${ADMIN_PASSWORD}`);
    console.log('   Role:     Barber (with Admin Dashboard)');
    
    console.log('\n═'.repeat(70));

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

setAdminFlag().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
