const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testSwagger() {
  console.log('🧪 Testing Swagger Documentation...\n');

  try {
    // Test 1: Check if Swagger UI is accessible
    console.log('1. Testing Swagger UI accessibility...');
    const swaggerResponse = await axios.get(`${BASE_URL}/api-docs/`);
    console.log('✅ Swagger UI is accessible');
    console.log(`   Status: ${swaggerResponse.status}`);
    console.log(`   Content-Type: ${swaggerResponse.headers['content-type']}`);

    // Test 2: Check if health endpoint works
    console.log('\n2. Testing health endpoint...');
    const healthResponse = await axios.get(`${BASE_URL}/health`);
    console.log('✅ Health endpoint is working');
    console.log(`   Response: ${JSON.stringify(healthResponse.data)}`);

    // Test 3: Test a simple API call to verify integration
    console.log('\n3. Testing API integration...');
    const chatsResponse = await axios.get(`${BASE_URL}/chats`);
    console.log('✅ API endpoints are working');
    console.log(`   Found ${chatsResponse.data.length} chats`);

    console.log('\n🎉 Swagger documentation is fully functional!');
    console.log('\n📖 You can now visit:');
    console.log(`   Swagger UI: ${BASE_URL}/api-docs`);
    console.log(`   Health Check: ${BASE_URL}/health`);

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run the test
testSwagger(); 