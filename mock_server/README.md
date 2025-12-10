# Servy Mock API Server

Mock REST API server for Servy food delivery app development and testing.

## Quick Start

```bash
cd mock_server
dart pub get
dart run lib/server.dart
```

The server will start on `http://localhost:8080` by default.

## Environment Variables

- `PORT`: Server port (default: 8080)

Example:
```bash
PORT=3000 dart run lib/server.dart
```

## Available Endpoints

### Authentication
- `POST /auth/login` - Login with phone and password
- `POST /auth/register` - Register new user

### Restaurants
- `GET /restaurants?lat={lat}&lng={lng}` - Get restaurants list
- `GET /restaurants/:id` - Get restaurant details
- `GET /restaurants/:id/menu` - Get restaurant menu

### Addresses
- `GET /users/:id/addresses` - Get user addresses
- `POST /users/:id/addresses` - Create new address

### Orders
- `POST /orders` - Place new order
- `GET /orders/:id/track` - Get order tracking status

### Coupons
- `POST /coupons/validate` - Validate coupon code

## Example Requests

### Login
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "0501234567", "password": "password123"}'
```

### Get Restaurants
```bash
curl http://localhost:8080/restaurants?lat=24.7136&lng=46.6753
```

## Response Format

All endpoints return JSON in this format:

```json
{
  "success": true,
  "data": { ... }
}
```

Errors:
```json
{
  "success": false,
  "error": "Error message"
}
```

