const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const app = express();
const PORT = process.env.PORT || 3000;

// Swagger configuration
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Chat API',
      version: '1.0.0',
      description: 'A RESTful API for managing chats and messages with in-memory storage',
      contact: {
        name: 'API Support',
        email: 'support@example.com'
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT'
      }
    },
    servers: [
      {
        url: `http://localhost:${PORT}`,
        description: 'Development server'
      }
    ],
    components: {
      schemas: {
        Chat: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              description: 'Unique identifier for the chat'
            },
            title: {
              type: 'string',
              description: 'Title of the chat'
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
              description: 'Creation timestamp'
            },
            updatedAt: {
              type: 'string',
              format: 'date-time',
              description: 'Last update timestamp'
            }
          },
          required: ['id', 'title', 'createdAt', 'updatedAt']
        },
        Message: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              description: 'Unique identifier for the message'
            },
            sender: {
              type: 'string',
              enum: ['user', 'assistant'],
              description: 'Sender of the message'
            },
            text: {
              type: 'string',
              description: 'Content of the message'
            },
            timestamp: {
              type: 'string',
              format: 'date-time',
              description: 'Message timestamp'
            }
          },
          required: ['id', 'sender', 'text', 'timestamp']
        },
        Error: {
          type: 'object',
          properties: {
            error: {
              type: 'string',
              description: 'Error message'
            }
          }
        }
      }
    }
  },
  apis: ['./server.js']
};

const specs = swaggerJsdoc(swaggerOptions);

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Chat API Documentation'
}));

// In-memory data storage
let chats = [
  {
    id: "chat_001",
    title: "Product brainstorming",
    createdAt: "2025-07-25T10:00:00Z",
    updatedAt: "2025-07-25T12:00:00Z"
  },
  {
    id: "chat_002",
    title: "Weekly sync",
    createdAt: "2025-07-20T08:30:00Z",
    updatedAt: "2025-07-22T16:45:00Z"
  }
];

let messages = {
  "chat_001": [
    {
      id: "msg_001",
      sender: "user",
      text: "Hello!",
      timestamp: "2025-07-25T11:00:00Z"
    },
    {
      id: "msg_002",
      sender: "assistant",
      text: "Hi there! How can I help you?",
      timestamp: "2025-07-25T11:00:05Z"
    }
  ],
  "chat_002": [
    {
      id: "msg_003",
      sender: "user",
      text: "Let's discuss the weekly progress",
      timestamp: "2025-07-20T08:30:00Z"
    },
    {
      id: "msg_004",
      sender: "assistant",
      text: "Sure! What would you like to cover?",
      timestamp: "2025-07-20T08:30:05Z"
    }
  ]
};

// Sample messages for bulk creation
const sampleMessages = [
  // User messages
  "Hello! How are you today?",
  "Can you help me with a question?",
  "What's the weather like?",
  "I need some advice",
  "Can you explain this concept?",
  "What do you think about this?",
  "I'm having trouble with this",
  "Could you provide more details?",
  "That's interesting!",
  "I don't understand this part",
  "Can you give me an example?",
  "What are the best practices?",
  "I'm working on a project",
  "Can you review this for me?",
  "What's your opinion on this?",
  "I need to learn more about this",
  "Can you break this down?",
  "What are the alternatives?",
  "I'm confused about this",
  "Can you help me solve this?",
  
  // Assistant messages
  "Hello! I'm here to help you.",
  "Of course! I'd be happy to help.",
  "Let me explain that for you.",
  "Here's what I think about that.",
  "I understand your question.",
  "That's a great question!",
  "Let me break this down for you.",
  "Here's an example to illustrate this.",
  "I can help you with that.",
  "That's an interesting perspective.",
  "Let me provide some context.",
  "Here are the key points to consider.",
  "I think you're on the right track.",
  "Let me clarify that for you.",
  "That's a common concern.",
  "Here's what you should know.",
  "I can see why you'd think that.",
  "Let me give you some advice.",
  "That's a valid point.",
  "Here's how you can approach this."
];

// Helper functions
const generateId = (prefix) => {
  const timestamp = Date.now();
  const random = Math.floor(Math.random() * 1000);
  return `${prefix}_${timestamp}_${random}`;
};

const getCurrentTimestamp = () => {
  return new Date().toISOString();
};

// Function to create bulk messages
const createBulkMessages = async (chatId, count = 100) => {
  const results = {
    success: 0,
    failed: 0,
    messages: []
  };

  for (let i = 0; i < count; i++) {
    try {
      const sender = i % 2 === 0 ? 'user' : 'assistant';
      const messageIndex = i % sampleMessages.length;
      const text = sampleMessages[messageIndex];

      const newMessage = {
        id: generateId('msg'),
        sender,
        text: `${text} (Message #${i + 1})`,
        timestamp: getCurrentTimestamp()
      };

      if (!messages[chatId]) {
        messages[chatId] = [];
      }

      messages[chatId].push(newMessage);
      results.messages.push(newMessage);
      results.success++;

      // Update chat's updatedAt timestamp
      const chatIndex = chats.findIndex(chat => chat.id === chatId);
      if (chatIndex !== -1) {
        chats[chatIndex].updatedAt = newMessage.timestamp;
      }

    } catch (error) {
      results.failed++;
      console.error(`Failed to create message ${i + 1}:`, error.message);
    }
  }

  return results;
};

// Routes

/**
 * @swagger
 * /chats:
 *   get:
 *     summary: Get all chats
 *     description: Retrieve a list of all user chats
 *     tags: [Chats]
 *     responses:
 *       200:
 *         description: List of chats retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Chat'
 *             example:
 *               - id: "chat_001"
 *                 title: "Product brainstorming"
 *                 createdAt: "2025-07-25T10:00:00Z"
 *                 updatedAt: "2025-07-25T12:00:00Z"
 *               - id: "chat_002"
 *                 title: "Weekly sync"
 *                 createdAt: "2025-07-20T08:30:00Z"
 *                 updatedAt: "2025-07-22T16:45:00Z"
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
app.get('/chats', (req, res) => {
  try {
    res.json(chats);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * @swagger
 * /chats:
 *   post:
 *     summary: Create a new chat
 *     description: Create a new empty chat
 *     tags: [Chats]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 description: Title of the new chat
 *                 example: "New Chat"
 *             required:
 *               - title
 *     responses:
 *       201:
 *         description: Chat created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Chat'
 *             example:
 *               id: "chat_1234567890_123"
 *               title: "New Chat"
 *               createdAt: "2025-07-25T13:00:00Z"
 *               updatedAt: "2025-07-25T13:00:00Z"
 *       400:
 *         description: Bad request - title is required
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *             example:
 *               error: "Title is required and must be a string"
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
app.post('/chats', (req, res) => {
  try {
    const { title } = req.body;
    
    if (!title || typeof title !== 'string') {
      return res.status(400).json({ error: 'Title is required and must be a string' });
    }

    const now = getCurrentTimestamp();
    const newChat = {
      id: generateId('chat'),
      title,
      createdAt: now,
      updatedAt: now
    };

    chats.push(newChat);
    messages[newChat.id] = []; // Initialize empty messages array

    res.status(201).json(newChat);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * @swagger
 * /chats/{id}:
 *   patch:
 *     summary: Rename a chat
 *     description: Update the title of an existing chat
 *     tags: [Chats]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The chat ID
 *         example: "chat_001"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 description: New title for the chat
 *                 example: "Renamed Chat"
 *             required:
 *               - title
 *     responses:
 *       200:
 *         description: Chat renamed successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 title:
 *                   type: string
 *                 updatedAt:
 *                   type: string
 *                   format: date-time
 *             example:
 *               id: "chat_001"
 *               title: "Renamed Chat"
 *               updatedAt: "2025-07-25T14:10:00Z"
 *       400:
 *         description: Bad request - title is required
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Chat not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
app.patch('/chats/:id', (req, res) => {
  try {
    const { id } = req.params;
    const { title } = req.body;

    if (!title || typeof title !== 'string') {
      return res.status(400).json({ error: 'Title is required and must be a string' });
    }

    const chatIndex = chats.findIndex(chat => chat.id === id);
    
    if (chatIndex === -1) {
      return res.status(404).json({ error: 'Chat not found' });
    }

    chats[chatIndex].title = title;
    chats[chatIndex].updatedAt = getCurrentTimestamp();

    res.json({
      id: chats[chatIndex].id,
      title: chats[chatIndex].title,
      updatedAt: chats[chatIndex].updatedAt
    });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * @swagger
 * /chats/{id}:
 *   delete:
 *     summary: Delete a chat
 *     description: Delete a chat and all its messages by ID
 *     tags: [Chats]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The chat ID to delete
 *         example: "chat_001"
 *     responses:
 *       200:
 *         description: Chat deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *       404:
 *         description: Chat not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
app.delete('/chats/:id', (req, res) => {
  try {
    const { id } = req.params;
    
    const chatIndex = chats.findIndex(chat => chat.id === id);
    
    if (chatIndex === -1) {
      return res.status(404).json({ error: 'Chat not found' });
    }

    // Remove chat from chats array
    chats.splice(chatIndex, 1);
    
    // Remove messages for this chat
    delete messages[id];

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * @swagger
 * /chats/{id}/messages:
 *   get:
 *     summary: Get chat messages
 *     description: Get all messages in a specific chat
 *     tags: [Messages]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The chat ID
 *         example: "chat_001"
 *     responses:
 *       200:
 *         description: Messages retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Message'
 *             example:
 *               - id: "msg_001"
 *                 sender: "user"
 *                 text: "Hello!"
 *                 timestamp: "2025-07-25T11:00:00Z"
 *               - id: "msg_002"
 *                 sender: "assistant"
 *                 text: "Hi there! How can I help you?"
 *                 timestamp: "2025-07-25T11:00:05Z"
 *       404:
 *         description: Chat not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
app.get('/chats/:id/messages', (req, res) => {
  try {
    const { id } = req.params;
    
    if (!messages[id]) {
      return res.status(404).json({ error: 'Chat not found' });
    }

    res.json(messages[id]);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * @swagger
 * /chats/{id}/messages:
 *   post:
 *     summary: Add a message to a chat
 *     description: Add a single message to a specific chat
 *     tags: [Messages]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The chat ID
 *         example: "chat_001"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               sender:
 *                 type: string
 *                 enum: [user, assistant]
 *                 description: Sender of the message
 *                 example: "user"
 *               text:
 *                 type: string
 *                 description: Content of the message
 *                 example: "What is the weather today?"
 *             required:
 *               - sender
 *               - text
 *     responses:
 *       201:
 *         description: Message created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Message'
 *             example:
 *               id: "msg_1234567890_456"
 *               sender: "user"
 *               text: "What is the weather today?"
 *               timestamp: "2025-07-25T14:20:00Z"
 *       400:
 *         description: Bad request - invalid sender or missing text
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Chat not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
app.post('/chats/:id/messages', (req, res) => {
  try {
    const { id } = req.params;
    const { sender, text } = req.body;

    if (!messages[id]) {
      return res.status(404).json({ error: 'Chat not found' });
    }

    if (!sender || !text || typeof sender !== 'string' || typeof text !== 'string') {
      return res.status(400).json({ error: 'Sender and text are required and must be strings' });
    }

    if (!['user', 'assistant'].includes(sender)) {
      return res.status(400).json({ error: 'Sender must be either "user" or "assistant"' });
    }

    const newMessage = {
      id: generateId('msg'),
      sender,
      text,
      timestamp: getCurrentTimestamp()
    };

    messages[id].push(newMessage);

    // Update chat's updatedAt timestamp
    const chatIndex = chats.findIndex(chat => chat.id === id);
    if (chatIndex !== -1) {
      chats[chatIndex].updatedAt = newMessage.timestamp;
    }

    res.status(201).json(newMessage);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /chats/{id}/messages/bulk - Create multiple messages in a chat (Hidden from Swagger)
app.post('/chats/:id/messages/bulk', async (req, res) => {
  try {
    const { id } = req.params;
    const { count = 100 } = req.body;

    // Validate chat exists
    const chatIndex = chats.findIndex(chat => chat.id === id);
    if (chatIndex === -1) {
      return res.status(404).json({ error: 'Chat not found' });
    }

    // Validate count parameter
    if (count && (typeof count !== 'number' || count < 1 || count > 1000)) {
      return res.status(400).json({ error: 'Count must be a number between 1 and 1000' });
    }

    console.log(`🚀 Creating ${count} messages for chat ${id}...`);

    // Create bulk messages
    const results = await createBulkMessages(id, count);

    console.log(`✅ Created ${results.success} messages, ${results.failed} failed`);

    res.status(201).json({
      message: `Successfully created ${results.success} messages`,
      chatId: id,
      success: results.success,
      failed: results.failed,
      total: results.success + results.failed,
      sampleMessages: results.messages.slice(0, 5) // Show first 5 messages as sample
    });

  } catch (error) {
    console.error('Error creating bulk messages:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /chats/messages/bulk - Create messages across all chats (Hidden from Swagger)
app.post('/chats/messages/bulk', async (req, res) => {
  try {
    const { count = 100 } = req.body;

    // Validate count parameter
    if (count && (typeof count !== 'number' || count < 1 || count > 1000)) {
      return res.status(400).json({ error: 'Count must be a number between 1 and 1000' });
    }

    if (chats.length === 0) {
      return res.status(400).json({ error: 'No chats available to add messages to' });
    }

    console.log(`🚀 Creating ${count} messages across ${chats.length} chats...`);

    const allResults = {
      totalSuccess: 0,
      totalFailed: 0,
      chatResults: []
    };

    // Distribute messages across all chats
    const messagesPerChat = Math.ceil(count / chats.length);

    for (const chat of chats) {
      const results = await createBulkMessages(chat.id, messagesPerChat);
      allResults.totalSuccess += results.success;
      allResults.totalFailed += results.failed;
      allResults.chatResults.push({
        chatId: chat.id,
        chatTitle: chat.title,
        success: results.success,
        failed: results.failed
      });
    }

    console.log(`✅ Created ${allResults.totalSuccess} messages across all chats, ${allResults.totalFailed} failed`);

    res.status(201).json({
      message: `Successfully created ${allResults.totalSuccess} messages across ${chats.length} chats`,
      totalSuccess: allResults.totalSuccess,
      totalFailed: allResults.totalFailed,
      total: allResults.totalSuccess + allResults.totalFailed,
      chatResults: allResults.chatResults
    });

  } catch (error) {
    console.error('Error creating bulk messages across chats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Health check endpoint
 *     description: Check if the service is running
 *     tags: [Health]
 *     responses:
 *       200:
 *         description: Service is healthy
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "OK"
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *                   example: "2025-07-25T14:20:00Z"
 */
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: getCurrentTimestamp() });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use((error, req, res, next) => {
  console.error('Error:', error);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Chat API server running on port ${PORT}`);
  console.log(`📖 API Documentation: http://localhost:${PORT}/api-docs`);
  console.log(`🏥 Health Check: http://localhost:${PORT}/health`);
});

module.exports = app; 