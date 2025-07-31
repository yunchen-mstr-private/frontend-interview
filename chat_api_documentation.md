# 📘 Chat API Documentation

---

## 🔹 `GET /chats`

**Description:** Retrieve a list of all user chats.

**Response:**
```json
[
  {
    "id": "chat_001",
    "title": "Product brainstorming",
    "createdAt": "2025-07-25T10:00:00Z",
    "updatedAt": "2025-07-25T12:00:00Z"
  },
  {
    "id": "chat_002",
    "title": "Weekly sync",
    "createdAt": "2025-07-20T08:30:00Z",
    "updatedAt": "2025-07-22T16:45:00Z"
  }
]
```

---

## 🔹 `POST /chats`

**Description:** Create a new empty chat.

**Request Body:**
```json
{
  "title": "New Chat"
}
```

**Response:**
```json
{
  "id": "chat_003",
  "title": "New Chat",
  "createdAt": "2025-07-25T13:00:00Z",
  "updatedAt": "2025-07-25T13:00:00Z"
}
```

---

## 🔹 `PATCH /chats/{id}`

**Description:** Rename a chat.

**Path Parameters:**
- `id`: The chat ID to rename.

**Request Body:**
```json
{
  "title": "Renamed Chat"
}
```

**Response:**
```json
{
  "id": "chat_003",
  "title": "Renamed Chat",
  "updatedAt": "2025-07-25T14:10:00Z"
}
```

---

## 🔹 `DELETE /chats/{id}`

**Description:** Delete a chat by ID.

**Response:**
```json
{
  "success": true
}
```

---

## 🔹 `GET /chats/{id}/messages`

**Description:** Get all messages in a specific chat.

**Path Parameters:**
- `id`: The chat ID.

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

---

## 🔹 `POST /chats/{id}/messages`

**Description:** Add a message to a chat (useful for testing or mock behavior).

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
  "id": "msg_005",
  "sender": "user",
  "text": "What is the weather today?",
  "timestamp": "2025-07-25T14:20:00Z"
}
```

---
