const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testBulkMessages() {
  console.log('🧪 Testing Integrated Bulk Message Creation...\n');

  try {
    // Test 1: Create bulk messages in a specific chat
    console.log('1. Creating 25 messages in chat_001...');
    const bulkResult1 = await axios.post(`${BASE_URL}/chats/chat_001/messages/bulk`, {
      count: 25
    });
    console.log('✅ Bulk creation result:', bulkResult1.data);

    // Test 2: Create bulk messages across all chats
    console.log('\n2. Creating 40 messages across all chats...');
    const bulkResult2 = await axios.post(`${BASE_URL}/chats/messages/bulk`, {
      count: 40
    });
    console.log('✅ Cross-chat bulk creation result:', bulkResult2.data);

    // Test 3: Check message counts
    console.log('\n3. Checking final message counts...');
    const chat1Messages = await axios.get(`${BASE_URL}/chats/chat_001/messages`);
    const chat2Messages = await axios.get(`${BASE_URL}/chats/chat_002/messages`);
    
    console.log(`   chat_001: ${chat1Messages.data.length} messages`);
    console.log(`   chat_002: ${chat2Messages.data.length} messages`);
    console.log(`   Total: ${chat1Messages.data.length + chat2Messages.data.length} messages`);

    // Test 4: Show sample messages
    console.log('\n4. Sample messages from chat_001:');
    const sampleMessages = chat1Messages.data.slice(-3);
    sampleMessages.forEach((msg, index) => {
      console.log(`   ${index + 1}. [${msg.sender}] ${msg.text}`);
    });

    console.log('\n🎉 All bulk message tests completed successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run the tests
testBulkMessages(); 