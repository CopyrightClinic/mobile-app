# Live Chat — Mobile Integration Guide

Everything the mobile app needs to integrate per-stream live chat. Free for all authenticated users (no premium gate).

---

## Endpoints

| Purpose | URL |
| --- | --- |
| WebSocket (Socket.IO) | `wss://camera-project-api.brainxdemo.com/chat` |
| REST history (bootstrap / app resume) | `GET /api/v1/cameras/:slug/chat/messages?limit=30` |

- WebSocket path is **`/chat`** — it is **not** under `/api/v1`.
- **`streamId`** (WebSocket) = **`slug`** (REST) = camera `external_id` from `GET /cameras`.

---

## Auth

- Use the same **`accessToken`** from `POST /auth/login` (or refresh flow).
- WebSocket: pass token in the handshake — **required for native clients:**

```js
import { io } from 'socket.io-client';

const socket = io('https://camera-project-api.brainxdemo.com', {
  path: '/chat',
  transports: ['websocket', 'polling'],
  auth: { token: accessToken }
});
```

- REST: `Authorization: Bearer <accessToken>`
- On `unauthorized` or REST **401**: refresh token via `POST /auth/refresh`, then reconnect.

---

## Integration flow

1. **Screen open (optional, before WS):** `GET /cameras/:slug/chat/messages?limit=30` → render messages.
2. **Connect** Socket.IO with fresh token.
3. **On `connect`:** `socket.emit('join', { streamId: slug })`.
4. **On `history`:** set message list from `messages` (already oldest-first).
5. **On `message`:** append to list (includes your own sends).
6. **User sends:** `socket.emit('send', { streamId: slug, body: text })` — wait for server `message`; do not fabricate identity fields.
7. **Reconnect / app foreground:** on `connect`, emit `join` again with the same `streamId`.
8. **Switch camera:** emit `join` with the new `streamId`.

---

## WebSocket events

### Client → server

**`join`**

```js
socket.emit('join', { streamId: 'camera-slug' });
```

| Field | Type | Notes |
| --- | --- | --- |
| `streamId` | string | Camera slug, 1–255 chars |

→ Success: server emits **`history`** to this socket only.  
→ Failure: **`error`** with `code: "room_not_found"`.

**`send`**

```js
socket.emit('send', { streamId: 'camera-slug', body: 'Hello!' });
```

| Field | Type | Notes |
| --- | --- | --- |
| `streamId` | string | Same slug as `join` |
| `body` | string | 1–500 chars after trim |

→ Success: server broadcasts **`message`** to everyone in the room (including sender).  
→ Failure: **`error`** to sender only (`invalid_message` or `rate_limited`).

### Server → client

**`history`** — after successful `join`

```js
socket.on('history', ({ messages }) => { /* ChatMessage[] */ });
```

- Up to **30** messages, **oldest-first** — render as-is, no sort.

**`message`** — new chat message

```js
socket.on('message', (msg) => { /* ChatMessage */ });
```

**`error`**

```js
socket.on('error', ({ code, message }) => { /* handle */ });
```

| `code` | Meaning | Action |
| --- | --- | --- |
| `unauthorized` | Bad/missing/expired token or blocked account | Refresh token or re-login; disconnect chat |
| `room_not_found` | Camera slug invalid or inactive | Show unavailable; leave chat |
| `rate_limited` | Sent again within 2s of last accepted message | Show cooldown; keep draft |
| `invalid_message` | Empty body, too long, or validation error | Show error to user |

---

## `ChatMessage` shape

Server-stamped on every message — **never send or trust identity from the client.**

| Field | Type | Description |
| --- | --- | --- |
| `id` | string (uuid) | Message id |
| `streamId` | string | Camera slug |
| `userId` | string (uuid) | Author id |
| `username` | string | Author username |
| `displayName` | string | Author display name |
| `avatarUrl` | string \| null | Avatar URL or null |
| `body` | string | HTML-escaped text — safe to display as plain text |
| `sentAt` | string (ISO 8601 UTC) | Server timestamp — use for display only |

Example:

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "streamId": "barra-sul-jetty-ocean-panorama",
  "userId": "8d3e4567-e89b-12d3-a456-426614174000",
  "username": "jane_doe",
  "displayName": "Jane",
  "avatarUrl": null,
  "body": "Great view!",
  "sentAt": "2026-06-01T11:59:11.349Z"
}
```

---

## REST fallback

Use when WebSocket is not connected yet (cold start, app resume).

```
GET /api/v1/cameras/:slug/chat/messages?limit=30
Authorization: Bearer <accessToken>
```

- Response: `ChatMessage[]` (same shape as WS).
- Same order and content as WS **`history`** at that moment.
- Default `limit` is **30** — match WS for parity.

| Status | Meaning |
| --- | --- |
| `401` | Missing or invalid token |
| `404` | `{ "error": "camera_not_found" }` — bad slug |

---

## Rules to remember

- **One room per camera** — all viewers on the same stream share one chat.
- **Context, not archive** — only ~30 recent messages exist. No pagination, no “load older”.
- **Rate limit:** 1 accepted message per **2 seconds per user** (global, not per room).
- **Ordering:** always oldest-first from server — do not re-sort by `sentAt` unless displaying relative time labels.
- **Own messages:** you receive them via the same `message` event as everyone else; optionally show optimistic UI but reconcile with server payload.
- **Native apps:** no `Origin` header needed; use `auth.token` in the Socket.IO handshake.

---

## Quick test checklist

1. Login → get `accessToken`
2. `GET /cameras/:slug/chat/messages` → 200, array shape
3. Connect WS → `join` → receive `history`
4. `send` → receive `message` on same socket
5. Second device in same room → receives broadcast
6. Send twice within 2s → second gets `rate_limited`
7. Kill network → reconnect → `join` → fresh `history`
