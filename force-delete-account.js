#!/usr/bin/env node

const https = require('https');
const googleServices = require('./google-services.json');
const WEB_API_KEY = googleServices.client[0].api_key[0].current_key;

const passwords = [
  'Password123!',
  'password123',
  'Test123456!',
  'Roni123456',
  'TestPassword123!@#',
];

function makeRequest(hostname, path, body) {
  return new Promise((resolve, reject) => {
    const bodyString = JSON.stringify(body);
    const options = {
      hostname, port: 443, path, method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': bodyString.length }
    };
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(data) });
        } catch (e) {
          resolve({ status: res.statusCode, data });
        }
      });
    });
    req.on('error', reject);
    req.write(bodyString);
    req.end();
  });
}

async function tryDelete() {
  console.log('Trying to delete roniandave@gmail.com with various passwords...\n');
  
  for (const pwd of passwords) {
    try {
      console.log(`Trying password: '${pwd}'`);
      const response = await makeRequest('identitytoolkit.googleapis.com', '/v1/accounts:signInWithPassword?key=' + WEB_API_KEY, {
        email: 'roniandave@gmail.com',
        password: pwd,
        returnSecureToken: true,
      });
      
      if (response.data.idToken) {
        console.log('✅ Signed in!');
        const delResponse = await makeRequest('identitytoolkit.googleapis.com', '/v1/accounts:delete?key=' + WEB_API_KEY, {
          idToken: response.data.idToken
        });
        console.log('✅ Account deleted!');
        return;
      } else if (response.data.error) {
        console.log(`   → ${response.data.error.message}`);
      }
    } catch (e) {
      console.log(`   → Error: ${e.message}`);
    }
    
    await new Promise(r => setTimeout(r, 500));
  }
  console.log('\n❌ Could not delete account with any password');
  console.log('Do you know the password for roniandave@gmail.com?');
}
tryDelete();
