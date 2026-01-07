# myEvent Mock Server

## Quick Start

1. **Start the server:**
   ```
   Double-click start-server.bat
   ```
   Or run:
   ```powershell
   cd mock-server
   json-server --watch db.json --routes routes.json --host 0.0.0.0 --port 3000
   ```

2. **Server will be available at:**
   - http://192.168.86.23:3000
   - http://localhost:3000

## Demo Credentials

- **Email:** demo@myevent.com
- **Password:** 123456

Or:
- **Email:** john@myevent.com
- **Password:** 123456

## Available Endpoints

### Authentication
- `POST /api/auth/login` - Login (email + password in body)
- `POST /api/auth/register` - Register new user

### Events
- `GET /api/events` - All events
- `GET /api/events/:id` - Single event
- `GET /api/events/popular` - Popular events (sorted by attendees)
- `POST /api/events` - Create event
- `PUT /api/events/:id` - Update event
- `DELETE /api/events/:id` - Delete event

### Tickets
- `GET /api/users/:userId/tickets` - User's tickets
- `GET /api/events/:eventId/tickets` - Event tickets
- `POST /api/tickets` - Purchase ticket

### Messages
- `GET /api/messages/:conversationId` - Messages in conversation
- `GET /api/conversations/:userId` - User's conversations
- `POST /api/messages` - Send message

### Users
- `GET /api/users/:id` - Get user profile
- `PUT /api/users/:id` - Update profile

## Editing Data

Edit `db.json` to add/modify:
- Users
- Events
- Tickets
- Messages
- Conversations

The server will auto-reload when you save the file.

## Testing with curl

```powershell
# Login
curl -X POST http://192.168.86.23:3000/api/auth/login -H "Content-Type: application/json" -d "{\"email\":\"demo@myevent.com\",\"password\":\"123456\"}"

# Get events
curl http://192.168.86.23:3000/api/events

# Get popular events
curl http://192.168.86.23:3000/api/events/popular
```
