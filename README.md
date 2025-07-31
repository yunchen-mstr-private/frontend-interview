# Chat API Service

A RESTful API service for managing chats and messages with in-memory storage.

## Features

- ✅ Create, read, update, and delete chats
- ✅ Add messages to chats
- ✅ Retrieve all messages in a chat
- ✅ In-memory data storage
- ✅ Input validation and error handling
- ✅ CORS enabled for cross-origin requests
- ✅ Security headers with Helmet

## Quick Start

### Prerequisites

#### Option 1: Local Development
- Node.js (v14 or higher)
- npm or yarn

#### Option 2: Docker Deployment
- Docker
- Docker Compose

### Installation

#### Local Development

1. Install dependencies:
```bash
npm install
```

2. Start the server:
```bash
# Development mode (with auto-restart)
npm run dev

# Production mode
npm start
```

#### Docker Deployment

1. **Quick Start with Docker Compose:**
```bash
# Build and run with docker-compose (linux/amd64)
./docker-scripts.sh compose

# Or using npm scripts
npm run docker:compose
```

2. **Development Mode with Hot Reload:**
```bash
# Run in development mode
./docker-scripts.sh dev

# Or using npm scripts
npm run docker:dev
```

3. **Platform-Specific Builds:**
```bash
# Build for linux/amd64 (default, for production servers)
npm run docker:build

# Build for local platform (development)
npm run docker:build:local

# Build multi-platform (amd64 + arm64)
npm run docker:build:multi

# Build only for specific platform
npm run docker:build:amd64
npm run docker:build:arm64
```

4. **Manual Docker Commands:**
```bash
# Build for linux/amd64
docker build --platform linux/amd64 -t chat-api:latest .

# Build for local platform
docker build -t chat-api:latest .

# Run the container
docker run -d --name chat-api-service -p 3000:3000 chat-api:latest
```

The server will start on `http://localhost:3000`

### API Documentation

Once the server is running, you can access the interactive API documentation:

- **Swagger UI**: http://localhost:3000/api-docs
- **Health Check**: http://localhost:3000/health

The Swagger UI provides an interactive interface to explore and test all API endpoints.

## API Endpoints

### Chats

#### GET /chats
Retrieve a list of all user chats.

**Response:**
```json
[
  {
    "id": "chat_001",
    "title": "Product brainstorming",
    "createdAt": "2025-07-25T10:00:00Z",
    "updatedAt": "2025-07-25T12:00:00Z"
  }
]
```

#### POST /chats
Create a new empty chat.

**Request Body:**
```json
{
  "title": "New Chat"
}
```

**Response:**
```json
{
  "id": "chat_1234567890_123",
  "title": "New Chat",
  "createdAt": "2025-07-25T13:00:00Z",
  "updatedAt": "2025-07-25T13:00:00Z"
}
```

#### PATCH /chats/{id}
Rename a chat.

**Request Body:**
```json
{
  "title": "Renamed Chat"
}
```

**Response:**
```json
{
  "id": "chat_001",
  "title": "Renamed Chat",
  "updatedAt": "2025-07-25T14:10:00Z"
}
```

#### DELETE /chats/{id}
Delete a chat by ID.

**Response:**
```json
{
  "success": true
}
```

### Messages

#### GET /chats/{id}/messages
Get all messages in a specific chat.

**Response:**
```json
[
  {
    "id": "msg_001",
    "sender": "user",
    "text": "Hello!",
    "timestamp": "2025-07-25T11:00:00Z"
  },
  {
    "id": "msg_002",
    "sender": "assistant",
    "text": "Hi there! How can I help you?",
    "timestamp": "2025-07-25T11:00:05Z"
  }
]
```

#### POST /chats/{id}/messages
Add a message to a chat.

**Request Body:**
```json
{
  "sender": "user",
  "text": "What is the weather today?"
}
```

**Response:**
```json
{
  "id": "msg_1234567890_456",
  "sender": "user",
  "text": "What is the weather today?",
  "timestamp": "2025-07-25T14:20:00Z"
}
```

#### POST /chats/{id}/messages/bulk
Create multiple messages in a specific chat.

**Request Body:**
```json
{
  "count": 50
}
```

**Response:**
```json
{
  "message": "Successfully created 50 messages",
  "chatId": "chat_001",
  "success": 50,
  "failed": 0,
  "total": 50,
  "sampleMessages": [
    {
      "id": "msg_1234567890_123",
      "sender": "user",
      "text": "Hello! How are you today? (Message #1)",
      "timestamp": "2025-07-25T14:20:00Z"
    }
  ]
}
```

#### POST /chats/messages/bulk
Create messages across all chats.

**Request Body:**
```json
{
  "count": 100
}
```

**Response:**
```json
{
  "message": "Successfully created 100 messages across 2 chats",
  "totalSuccess": 100,
  "totalFailed": 0,
  "total": 100,
  "chatResults": [
    {
      "chatId": "chat_001",
      "chatTitle": "Product brainstorming",
      "success": 50,
      "failed": 0
    },
    {
      "chatId": "chat_002",
      "chatTitle": "Weekly sync",
      "success": 50,
      "failed": 0
    }
  ]
}
```

### Health Check

#### GET /health
Check if the service is running.

**Response:**
```json
{
  "status": "OK",
  "timestamp": "2025-07-25T14:20:00Z"
}
```

## Testing the API

You can test the API using curl, Postman, or any HTTP client. Here are some examples:

### Create a new chat
```bash
curl -X POST http://localhost:3000/chats \
  -H "Content-Type: application/json" \
  -d '{"title": "My New Chat"}'
```

### Get all chats
```bash
curl http://localhost:3000/chats
```

### Add a message to a chat
```bash
curl -X POST http://localhost:3000/chats/chat_001/messages \
  -H "Content-Type: application/json" \
  -d '{"sender": "user", "text": "Hello world!"}'
```

### Get messages from a chat
```bash
curl http://localhost:3000/chats/chat_001/messages
```

### Create bulk messages in a specific chat (Hidden from Swagger)
```bash
curl -X POST http://localhost:3000/chats/chat_001/messages/bulk \
  -H "Content-Type: application/json" \
  -d '{"count": 50}'
```

### Create bulk messages across all chats (Hidden from Swagger)
```bash
curl -X POST http://localhost:3000/chats/messages/bulk \
  -H "Content-Type: application/json" \
  -d '{"count": 100}'
```

> **Note**: Bulk message endpoints are hidden from the Swagger documentation but remain fully functional for testing and development purposes.

## Error Handling

The API returns appropriate HTTP status codes and error messages:

- `400 Bad Request` - Invalid input data
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

Error responses include a descriptive message:
```json
{
  "error": "Title is required and must be a string"
}
```

## Data Storage

This service uses in-memory storage, which means:
- Data persists only while the server is running
- Data is lost when the server restarts
- No database setup required
- Perfect for development and testing

## 🚀 Deployment

### Docker Management

The project includes a comprehensive Docker management script:

```bash
# Show all available commands
./docker-scripts.sh help

# Build the Docker image
./docker-scripts.sh build

# Run with docker-compose (production)
./docker-scripts.sh compose

# Run in development mode with hot reload
./docker-scripts.sh dev

# Stop all containers
./docker-scripts.sh stop

# Show container logs
./docker-scripts.sh logs

# Show container status
./docker-scripts.sh status

# Test the API endpoints
./docker-scripts.sh test

# Clean up all Docker resources
./docker-scripts.sh cleanup
```

### Docker Compose Files

- **`docker-compose.yml`** - Production deployment (linux/amd64)
- **`docker-compose.dev.yml`** - Development with hot reload (linux/amd64)

### Platform Compatibility

The Docker images are built for maximum compatibility:

- **`linux/amd64`** - Intel/AMD 64-bit servers (default for production)
- **`linux/arm64`** - ARM 64-bit (Apple Silicon, ARM servers)
- **Multi-platform** - Both amd64 and arm64 in single image

**Why linux/amd64 by default?**
- Most production servers use x86_64 architecture
- Ensures compatibility when building on Apple Silicon Macs
- Smaller image size compared to multi-platform builds

### Environment Variables

The following environment variables can be configured:

- `NODE_ENV` - Environment (production/development)
- `PORT` - Server port (default: 3000)

### Health Checks

The Docker container includes health checks that monitor:
- API health endpoint availability
- Service responsiveness
- Automatic restart on failure

### Kubernetes Deployment

The project includes Kubernetes manifests and deployment scripts:

```bash
# Deploy to Kubernetes
./deploy-k8s.sh deploy

# Check deployment status
./deploy-k8s.sh status

# Scale deployment
./deploy-k8s.sh scale 5

# Show logs
./deploy-k8s.sh logs

# Delete deployment
./deploy-k8s.sh delete
```

### Docker Hub Deployment

Push your Docker image to Docker Hub for easy sharing and deployment:

```bash
# Basic push to Docker Hub
./push-to-dockerhub.sh -u yourusername

# Push with custom tag
./push-to-dockerhub.sh -u yourusername -t v1.0.0

# Push with custom image name
./push-to-dockerhub.sh -u yourusername -i my-chat-api -t stable

# Using npm scripts
npm run dockerhub:push -- -u yourusername
```

The script will:
- Build the Docker image
- Push to Docker Hub
- Create a pull script for others
- Optionally test the pushed image

For more examples, run:
```bash
./example-dockerhub-push.sh
./push-to-dockerhub.sh --help
```

### Cloud Deployment

For detailed cloud deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).

Supported platforms:
- **Docker Hub** - Container registry
- **AWS ECS** - Elastic Container Service
- **Google Cloud Run** - Serverless containers
- **Azure Container Instances** - Managed containers
- **DigitalOcean App Platform** - App deployment
- **Kubernetes** - Any Kubernetes cluster

## Development

### Running Tests
```bash
npm test
```

### Project Structure
```
service/
├── server.js              # Main server file
├── package.json           # Dependencies and scripts
├── README.md             # This file
└── chat_api_documentation.md  # API documentation
```

## Environment Variables

- `PORT` - Server port (default: 3000)

## Security Features

- CORS enabled for cross-origin requests
- Helmet.js for security headers
- Input validation on all endpoints
- Error handling to prevent information leakage

## API Documentation

This API includes comprehensive Swagger/OpenAPI documentation:

### Interactive Documentation
- **Swagger UI**: http://localhost:3000/api-docs
  - Interactive API explorer
  - Try out endpoints directly from the browser
  - View request/response schemas
  - See example requests and responses

### Documentation Features
- Complete endpoint documentation with examples
- Request/response schemas
- Error code documentation
- Interactive testing interface
- Organized by tags (Health, Chats, Messages)
- Bulk endpoints hidden from documentation (but still functional)

### OpenAPI Specification
The API follows OpenAPI 3.0 specification standards and includes:
- Detailed parameter descriptions
- Request body schemas
- Response examples
- Error handling documentation
- Data model definitions

## License

MIT 