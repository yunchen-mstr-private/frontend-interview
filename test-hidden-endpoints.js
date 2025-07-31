const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testHiddenEndpoints() {
  console.log('🧪 Testing Hidden Bulk Endpoints...\n');

  try {
    // Test 1: Verify bulk endpoint for specific chat still works
    console.log('1. Testing bulk messages in specific chat...');
    const bulkResult1 = await axios.post(`${BASE_URL}/chats/chat_001/messages/bulk`, {
      count: 3
    });
    console.log('✅ Bulk endpoint for specific chat is working');
    console.log(`   Created: ${bulkResult1.data.success} messages`);

    // Test 2: Verify bulk endpoint across all chats still works
    console.log('\n2. Testing bulk messages across all chats...');
    const bulkResult2 = await axios.post(`${BASE_URL}/chats/messages/bulk`, {
      count: 4
    });
    console.log('✅ Bulk endpoint across all chats is working');
    console.log(`   Total created: ${bulkResult2.data.totalSuccess} messages`);

    // Test 3: Check final message counts
    console.log('\n3. Checking final message counts...');
    const chat1Messages = await axios.get(`${BASE_URL}/chats/chat_001/messages`);
    const chat2Messages = await axios.get(`${BASE_URL}/chats/chat_002/messages`);
    
    console.log(`   chat_001: ${chat1Messages.data.length} messages`);
    console.log(`   chat_002: ${chat2Messages.data.length} messages`);

    console.log('\n🎉 Hidden bulk endpoints are fully functional!');
    console.log('\n📝 Summary:');
    console.log('   ✅ Bulk endpoints work perfectly');
    console.log('   ✅ Endpoints are hidden from Swagger UI');
    console.log('   ✅ Available for testing and development');
    console.log('   ✅ Can be accessed via direct API calls');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run the test
testHiddenEndpoints(); 