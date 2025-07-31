const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testAPI() {
  console.log('🧪 Testing Chat API...\n');

  try {
    // Test 1: Health check
    console.log('1. Testing health check...');
    const health = await axios.get(`${BASE_URL}/health`);
    console.log('✅ Health check:', health.data);

    // Test 2: Get all chats
    console.log('\n2. Getting all chats...');
    const chats = await axios.get(`${BASE_URL}/chats`);
    console.log('✅ Chats:', chats.data);

    // Test 3: Create a new chat
    console.log('\n3. Creating a new chat...');
    const newChat = await axios.post(`${BASE_URL}/chats`, {
      title: 'API Test Chat'
    });
    console.log('✅ New chat created:', newChat.data);
    const chatId = newChat.data.id;

    // Test 4: Get messages from existing chat
    console.log('\n4. Getting messages from chat_001...');
    const messages = await axios.get(`${BASE_URL}/chats/chat_001/messages`);
    console.log('✅ Messages:', messages.data);

    // Test 5: Add a message to the new chat
    console.log('\n5. Adding a message to the new chat...');
    const newMessage = await axios.post(`${BASE_URL}/chats/${chatId}/messages`, {
      sender: 'user',
      text: 'Hello from the test!'
    });
    console.log('✅ New message added:', newMessage.data);

    // Test 6: Add another message (assistant)
    console.log('\n6. Adding an assistant message...');
    const assistantMessage = await axios.post(`${BASE_URL}/chats/${chatId}/messages`, {
      sender: 'assistant',
      text: 'Hello! How can I help you today?'
    });
    console.log('✅ Assistant message added:', assistantMessage.data);

    // Test 7: Get messages from the new chat
    console.log('\n7. Getting messages from the new chat...');
    const newChatMessages = await axios.get(`${BASE_URL}/chats/${chatId}/messages`);
    console.log('✅ New chat messages:', newChatMessages.data);

    // Test 8: Rename the chat
    console.log('\n8. Renaming the chat...');
    const renamedChat = await axios.patch(`${BASE_URL}/chats/${chatId}`, {
      title: 'Renamed Test Chat'
    });
    console.log('✅ Chat renamed:', renamedChat.data);

    // Test 9: Get all chats again to see the changes
    console.log('\n9. Getting all chats after changes...');
    const updatedChats = await axios.get(`${BASE_URL}/chats`);
    console.log('✅ Updated chats:', updatedChats.data);

    // Test 10: Delete the test chat
    console.log('\n10. Deleting the test chat...');
    const deleteResult = await axios.delete(`${BASE_URL}/chats/${chatId}`);
    console.log('✅ Chat deleted:', deleteResult.data);

    // Test 11: Verify chat is deleted
    console.log('\n11. Verifying chat is deleted...');
    const finalChats = await axios.get(`${BASE_URL}/chats`);
    console.log('✅ Final chats:', finalChats.data);

    console.log('\n🎉 All tests completed successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run the tests
testAPI(); 