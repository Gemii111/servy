# 🌐 API Endpoints Specification - Servy Food Delivery System

## 📋 نظرة عامة

هذا الملف يحتوي على مواصفات جميع الـ APIs والـ Endpoints المطلوبة لنظام Servy لتوصيل الطعام. يحتوي على Request/Response formats وAuthentication requirements وError handling.

**Base URL:** `https://api.servy.app` (أو `http://localhost:8080` للتطوير)

**API Version:** `v1`

---

## 🔐 Authentication

جميع الـ APIs (عدا Login و Register) تتطلب Authentication Token في Header:

```
Authorization: Bearer {access_token}
```

---

## 📡 API Endpoints

---

## 1. Authentication APIs 🔑

### 1.1. Login
**POST** `/api/v1/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "userType": "customer" // "customer" | "driver" | "restaurant"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user-uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "phone": "+966501234567",
      "userType": "customer",
      "imageUrl": "https://...",
      "isEmailVerified": true
    },
    "accessToken": "jwt-access-token",
    "refreshToken": "jwt-refresh-token"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "error": "Invalid email or password"
}
```

---

### 1.2. Register
**POST** `/api/v1/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "userType": "customer",
  "name": "John Doe",
  "phone": "+966501234567"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user-uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "phone": "+966501234567",
      "userType": "customer",
      "isEmailVerified": false
    },
    "accessToken": "jwt-access-token",
    "refreshToken": "jwt-refresh-token"
  }
}
```

---

### 1.3. Refresh Token
**POST** `/api/v1/auth/refresh`

**Request Body:**
```json
{
  "refreshToken": "jwt-refresh-token"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "accessToken": "new-jwt-access-token",
    "refreshToken": "new-jwt-refresh-token"
  }
}
```

---

### 1.4. Logout
**POST** `/api/v1/auth/logout`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 2. User APIs 👤

### 2.1. Get Current User Profile
**GET** `/api/v1/users/me`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "user-uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+966501234567",
    "userType": "customer",
    "imageUrl": "https://...",
    "isEmailVerified": true,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### 2.2. Update User Profile
**PUT** `/api/v1/users/me`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "name": "John Doe Updated",
  "phone": "+966501234567",
  "imageUrl": "https://..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "user-uuid",
    "email": "user@example.com",
    "name": "John Doe Updated",
    "phone": "+966501234567",
    "userType": "customer",
    "imageUrl": "https://...",
    "isEmailVerified": true
  }
}
```

---

### 2.3. Update FCM Token
**PUT** `/api/v1/users/me/fcm-token`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "fcmToken": "firebase-cloud-messaging-token"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "FCM token updated"
}
```

---

## 3. Restaurants APIs 🍽️

### 3.1. Get Restaurants List
**GET** `/api/v1/restaurants`

**Query Parameters:**
- `categoryId` (optional): Filter by category ID
- `latitude` (optional): User latitude for distance calculation
- `longitude` (optional): User longitude for distance calculation
- `isOpen` (optional): Filter by open/closed status (true/false)
- `isFeatured` (optional): Filter featured restaurants (true/false)
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)
- `sortBy` (optional): Sort by (distance, rating, delivery_time, price)
- `sortOrder` (optional): asc or desc (default: asc)

**Example:**
```
GET /api/v1/restaurants?latitude=24.7136&longitude=46.6753&isOpen=true&page=1&limit=20
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "restaurants": [
      {
        "id": "restaurant-uuid",
        "name": "Pizza Palace",
        "description": "Best pizza in town",
        "imageUrl": "https://...",
        "rating": 4.5,
        "reviewCount": 234,
        "cuisineType": "Italian",
        "deliveryTime": 30,
        "deliveryFee": 5.00,
        "minOrderAmount": 25.00,
        "isOpen": true,
        "distance": 2.5,
        "address": "123 Main St, Riyadh",
        "latitude": 24.7136,
        "longitude": 46.6753,
        "images": ["https://...", "https://..."],
        "isFeatured": true
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50,
      "totalPages": 3
    }
  }
}
```

---

### 3.2. Get Restaurant Details
**GET** `/api/v1/restaurants/:id`

**Example:**
```
GET /api/v1/restaurants/restaurant-uuid
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "restaurant-uuid",
    "name": "Pizza Palace",
    "description": "Best pizza in town",
    "imageUrl": "https://...",
    "rating": 4.5,
    "reviewCount": 234,
    "cuisineType": "Italian",
    "deliveryTime": 30,
    "deliveryFee": 5.00,
    "minOrderAmount": 25.00,
    "isOpen": true,
    "address": "123 Main St, Riyadh",
    "latitude": 24.7136,
    "longitude": 46.6753,
    "images": ["https://...", "https://..."],
    "isFeatured": true,
    "phone": "+966501234567",
    "email": "info@pizzapalace.com"
  }
}
```

---

### 3.3. Get Restaurant Menu
**GET** `/api/v1/restaurants/:id/menu`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "restaurantId": "restaurant-uuid",
    "categories": [
      {
        "id": "category-uuid",
        "name": "Pizzas",
        "items": [
          {
            "id": "item-uuid",
            "name": "Margherita Pizza",
            "description": "Classic pizza with tomato and mozzarella",
            "price": 45.00,
            "imageUrl": "https://...",
            "isAvailable": true,
            "extras": [
              {
                "id": "extra-uuid",
                "name": "Extra Cheese",
                "price": 5.00
              }
            ]
          }
        ]
      }
    ]
  }
}
```

---

### 3.4. Get Categories
**GET** `/api/v1/categories`

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "category-uuid",
      "name": "Pizza",
      "nameAr": "بيتزا",
      "iconUrl": "https://...",
      "color": "#FF5733"
    }
  ]
}
```

---

## 4. Orders APIs 📦

### 4.1. Place New Order
**POST** `/api/v1/orders`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "restaurantId": "restaurant-uuid",
  "items": [
    {
      "menuItemId": "item-uuid",
      "quantity": 2,
      "extras": [
        {
          "extraId": "extra-uuid"
        }
      ],
      "notes": "No onions please"
    }
  ],
  "deliveryAddress": {
    "label": "Home",
    "addressLine": "123 Main St",
    "city": "Riyadh",
    "postalCode": "12345",
    "latitude": 24.7136,
    "longitude": 46.6753
  },
  "paymentMethod": "cash", // "cash" | "card" | "wallet"
  "notes": "Please deliver quickly",
  "couponCode": "DISCOUNT10" // optional
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "userId": "user-uuid",
    "restaurantId": "restaurant-uuid",
    "restaurantName": "Pizza Palace",
    "status": "pending",
    "subtotal": 90.00,
    "deliveryFee": 5.00,
    "tax": 9.50,
    "discount": 10.00,
    "total": 94.50,
    "paymentMethod": "cash",
    "createdAt": "2024-01-01T12:00:00Z",
    "estimatedDeliveryTime": "2024-01-01T12:30:00Z",
    "items": [
      {
        "id": "order-item-uuid",
        "name": "Margherita Pizza",
        "price": 45.00,
        "quantity": 2,
        "extras": ["Extra Cheese"]
      }
    ],
    "deliveryAddress": {
      "label": "Home",
      "addressLine": "123 Main St",
      "city": "Riyadh",
      "latitude": 24.7136,
      "longitude": 46.6753
    }
  }
}
```

---

### 4.2. Get User Orders
**GET** `/api/v1/orders`

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
- `status` (optional): Filter by status
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "order-uuid",
        "restaurantId": "restaurant-uuid",
        "restaurantName": "Pizza Palace",
        "status": "delivered",
        "total": 94.50,
        "createdAt": "2024-01-01T12:00:00Z",
        "deliveredAt": "2024-01-01T12:35:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 15
    }
  }
}
```

---

### 4.3. Get Order Details
**GET** `/api/v1/orders/:id`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "userId": "user-uuid",
    "restaurantId": "restaurant-uuid",
    "restaurantName": "Pizza Palace",
    "status": "preparing",
    "subtotal": 90.00,
    "deliveryFee": 5.00,
    "tax": 9.50,
    "discount": 10.00,
    "total": 94.50,
    "paymentMethod": "cash",
    "notes": "Please deliver quickly",
    "createdAt": "2024-01-01T12:00:00Z",
    "estimatedDeliveryTime": "2024-01-01T12:30:00Z",
    "items": [
      {
        "id": "order-item-uuid",
        "name": "Margherita Pizza",
        "price": 45.00,
        "quantity": 2,
        "extras": ["Extra Cheese"]
      }
    ],
    "deliveryAddress": {
      "label": "Home",
      "addressLine": "123 Main St",
      "city": "Riyadh",
      "latitude": 24.7136,
      "longitude": 46.6753
    },
    "driverId": "driver-uuid",
    "driverName": "Ahmed Ali",
    "statusHistory": [
      {
        "status": "pending",
        "timestamp": "2024-01-01T12:00:00Z"
      },
      {
        "status": "accepted",
        "timestamp": "2024-01-01T12:01:00Z"
      }
    ]
  }
}
```

---

### 4.4. Track Order (Real-time)
**GET** `/api/v1/orders/:id/track`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "orderId": "order-uuid",
    "status": "out_for_delivery",
    "driverLocation": {
      "latitude": 24.7150,
      "longitude": 46.6760,
      "heading": 90.5,
      "speed": 45.2,
      "timestamp": "2024-01-01T12:25:00Z"
    },
    "estimatedArrival": "2024-01-01T12:30:00Z"
  }
}
```

---

### 4.5. Cancel Order
**POST** `/api/v1/orders/:id/cancel`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "reason": "Changed my mind"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Order cancelled successfully"
}
```

---

## 5. Restaurant Management APIs 🏪

### 5.1. Get Restaurant Orders
**GET** `/api/v1/restaurants/:id/orders`

**Headers:** `Authorization: Bearer {token}` (Restaurant owner)

**Query Parameters:**
- `status` (optional): Filter by status
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "order-uuid",
        "userId": "user-uuid",
        "status": "pending",
        "total": 94.50,
        "createdAt": "2024-01-01T12:00:00Z",
        "items": [
          {
            "name": "Margherita Pizza",
            "quantity": 2
          }
        ]
      }
    ]
  }
}
```

---

### 5.2. Update Order Status (Restaurant)
**PUT** `/api/v1/restaurants/:restaurantId/orders/:orderId/status`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "status": "preparing" // "accepted" | "preparing" | "ready" | "cancelled"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "status": "preparing",
    "updatedAt": "2024-01-01T12:05:00Z"
  }
}
```

---

### 5.3. Get Restaurant Statistics
**GET** `/api/v1/restaurants/:id/statistics`

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
- `period` (optional): today | week | month | year (default: today)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "todayOrders": 25,
    "todayRevenue": 1250.50,
    "pendingOrders": 3,
    "activeOrders": 5,
    "averageOrderValue": 50.02,
    "weeklyOrders": 180,
    "weeklyRevenue": 9000.00,
    "monthlyOrders": 750,
    "monthlyRevenue": 37500.00
  }
}
```

---

### 5.4. Update Restaurant Profile
**PUT** `/api/v1/restaurants/:id`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "name": "Pizza Palace Updated",
  "description": "New description",
  "phone": "+966501234567",
  "email": "info@newemail.com",
  "address": "New Address",
  "latitude": 24.7136,
  "longitude": 46.6753,
  "deliveryFee": 6.00,
  "minOrderAmount": 30.00,
  "isOpen": true
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "restaurant-uuid",
    "name": "Pizza Palace Updated",
    "description": "New description",
    "isOpen": true
  }
}
```

---

### 5.5. Get Restaurant Menu (Management)
**GET** `/api/v1/restaurants/:id/menu`

**Headers:** `Authorization: Bearer {token}` (Restaurant owner)

**Response:** Same as Get Restaurant Menu (3.3)

---

### 5.6. Add Menu Category
**POST** `/api/v1/restaurants/:id/menu/categories`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "name": "Desserts",
  "displayOrder": 3
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "category-uuid",
    "restaurantId": "restaurant-uuid",
    "name": "Desserts",
    "displayOrder": 3
  }
}
```

---

### 5.7. Update Menu Category
**PUT** `/api/v1/restaurants/:id/menu/categories/:categoryId`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "name": "Desserts Updated",
  "displayOrder": 2
}
```

---

### 5.8. Delete Menu Category
**DELETE** `/api/v1/restaurants/:id/menu/categories/:categoryId`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Category deleted successfully"
}
```

---

### 5.9. Add Menu Item
**POST** `/api/v1/restaurants/:id/menu/items`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "menuCategoryId": "category-uuid",
  "name": "Chocolate Cake",
  "description": "Delicious chocolate cake",
  "price": 35.00,
  "imageUrl": "https://...",
  "isAvailable": true,
  "extras": [
    {
      "name": "Extra Whipped Cream",
      "price": 3.00
    }
  ]
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "item-uuid",
    "menuCategoryId": "category-uuid",
    "name": "Chocolate Cake",
    "price": 35.00,
    "isAvailable": true,
    "extras": [...]
  }
}
```

---

### 5.10. Update Menu Item
**PUT** `/api/v1/restaurants/:id/menu/items/:itemId`

**Headers:** `Authorization: Bearer {token}`

**Request Body:** Same as Add Menu Item

---

### 5.11. Delete Menu Item
**DELETE** `/api/v1/restaurants/:id/menu/items/:itemId`

**Headers:** `Authorization: Bearer {token}`

---

## 6. Driver APIs 🚗

### 6.1. Get Available Delivery Requests
**GET** `/api/v1/drivers/delivery-requests`

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
- `latitude`: Driver latitude
- `longitude`: Driver longitude
- `maxDistance` (optional): Max distance in km (default: 10)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "requests": [
      {
        "id": "order-uuid",
        "restaurantName": "Pizza Palace",
        "restaurantLocation": {
          "latitude": 24.7136,
          "longitude": 46.6753,
          "address": "123 Main St"
        },
        "deliveryLocation": {
          "latitude": 24.7200,
          "longitude": 46.6800,
          "address": "456 Delivery St"
        },
        "total": 94.50,
        "distance": 2.5,
        "estimatedEarnings": 15.00,
        "createdAt": "2024-01-01T12:00:00Z"
      }
    ]
  }
}
```

---

### 6.2. Accept Delivery Request
**POST** `/api/v1/drivers/delivery-requests/:orderId/accept`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "status": "accepted",
    "driverId": "driver-uuid"
  }
}
```

---

### 6.3. Reject Delivery Request
**POST** `/api/v1/drivers/delivery-requests/:orderId/reject`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Request rejected"
}
```

---

### 6.4. Update Order Status (Driver)
**PUT** `/api/v1/drivers/orders/:orderId/status`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "status": "out_for_delivery" // "out_for_delivery" | "delivered"
}
```

---

### 6.5. Get Driver Active Orders
**GET** `/api/v1/drivers/orders/active`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "order-uuid",
        "restaurantName": "Pizza Palace",
        "customerAddress": "456 Delivery St",
        "status": "out_for_delivery",
        "total": 94.50
      }
    ]
  }
}
```

---

### 6.6. Get Driver Order History
**GET** `/api/v1/drivers/orders/history`

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
- `page` (optional): Page number
- `limit` (optional): Items per page

---

### 6.7. Get Driver Earnings
**GET** `/api/v1/drivers/earnings`

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
- `period` (optional): today | week | month | all (default: all)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "todayEarnings": 150.00,
    "weekEarnings": 1050.00,
    "monthEarnings": 4500.00,
    "totalEarnings": 12500.00,
    "todayDeliveries": 10,
    "weekDeliveries": 70,
    "monthDeliveries": 300,
    "totalDeliveries": 1250,
    "averageEarningPerDelivery": 10.00,
    "weeklyEarnings": [
      {
        "date": "2024-01-01",
        "earnings": 150.00,
        "deliveries": 10
      }
    ]
  }
}
```

---

### 6.8. Update Driver Location
**POST** `/api/v1/drivers/location`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "latitude": 24.7136,
  "longitude": 46.6753,
  "heading": 90.5,
  "speed": 45.2
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Location updated"
}
```

---

### 6.9. Update Driver Online Status
**PUT** `/api/v1/drivers/online-status`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "isOnline": true
}
```

---

## 7. Addresses APIs 📍

### 7.1. Get User Addresses
**GET** `/api/v1/users/:userId/addresses`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "address-uuid",
      "userId": "user-uuid",
      "label": "Home",
      "addressLine": "123 Main St",
      "city": "Riyadh",
      "postalCode": "12345",
      "latitude": 24.7136,
      "longitude": 46.6753,
      "isDefault": true
    }
  ]
}
```

---

### 7.2. Create Address
**POST** `/api/v1/users/:userId/addresses`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "label": "Work",
  "addressLine": "456 Office St",
  "city": "Riyadh",
  "postalCode": "67890",
  "latitude": 24.7200,
  "longitude": 46.6800,
  "isDefault": false
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "address-uuid",
    "userId": "user-uuid",
    "label": "Work",
    "addressLine": "456 Office St",
    "city": "Riyadh",
    "latitude": 24.7200,
    "longitude": 46.6800,
    "isDefault": false
  }
}
```

---

### 7.3. Update Address
**PUT** `/api/v1/users/:userId/addresses/:addressId`

**Headers:** `Authorization: Bearer {token}`

**Request Body:** Same as Create Address

---

### 7.4. Delete Address
**DELETE** `/api/v1/users/:userId/addresses/:addressId`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Address deleted successfully"
}
```

---

## 8. Ratings & Reviews APIs ⭐

### 8.1. Get Restaurant Ratings
**GET** `/api/v1/restaurants/:id/ratings`

**Query Parameters:**
- `page` (optional): Page number
- `limit` (optional): Items per page
- `minRating` (optional): Filter by minimum rating (1-5)
- `sortBy` (optional): newest | oldest | highest | lowest (default: newest)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "ratings": [
      {
        "id": "rating-uuid",
        "userId": "user-uuid",
        "userName": "John Doe",
        "userImageUrl": "https://...",
        "restaurantId": "restaurant-uuid",
        "orderId": "order-uuid",
        "rating": 4.5,
        "comment": "Great food!",
        "imageUrls": ["https://...", "https://..."],
        "createdAt": "2024-01-01T12:00:00Z"
      }
    ],
    "summary": {
      "averageRating": 4.5,
      "totalRatings": 234,
      "ratingDistribution": {
        "5": 100,
        "4": 80,
        "3": 40,
        "2": 10,
        "1": 4
      }
    },
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 234
    }
  }
}
```

---

### 8.2. Submit Rating/Review
**POST** `/api/v1/ratings`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "restaurantId": "restaurant-uuid",
  "orderId": "order-uuid",
  "rating": 4.5,
  "comment": "Great food and fast delivery!",
  "imageUrls": ["https://...", "https://..."]
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "rating-uuid",
    "userId": "user-uuid",
    "userName": "John Doe",
    "restaurantId": "restaurant-uuid",
    "rating": 4.5,
    "comment": "Great food and fast delivery!",
    "createdAt": "2024-01-01T12:00:00Z"
  }
}
```

---

### 8.3. Update Rating/Review
**PUT** `/api/v1/ratings/:id`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "rating": 5.0,
  "comment": "Updated review - even better!",
  "imageUrls": ["https://..."]
}
```

---

### 8.4. Delete Rating/Review
**DELETE** `/api/v1/ratings/:id`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Rating deleted successfully"
}
```

---

## 9. Favorites APIs ❤️

### 9.1. Get User Favorites
**GET** `/api/v1/users/:userId/favorites`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "restaurant-uuid",
      "name": "Pizza Palace",
      "imageUrl": "https://...",
      "rating": 4.5
    }
  ]
}
```

---

### 9.2. Add to Favorites
**POST** `/api/v1/users/:userId/favorites`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "restaurantId": "restaurant-uuid"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Added to favorites"
}
```

---

### 9.3. Remove from Favorites
**DELETE** `/api/v1/users/:userId/favorites/:restaurantId`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Removed from favorites"
}
```

---

## 10. Coupons APIs 🎟️

### 10.1. Validate Coupon
**POST** `/api/v1/coupons/validate`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "code": "DISCOUNT10",
  "restaurantId": "restaurant-uuid",
  "orderAmount": 100.00
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "code": "DISCOUNT10",
    "discountType": "percentage",
    "discountValue": 10.00,
    "discountAmount": 10.00,
    "valid": true
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "error": "Invalid or expired coupon code"
}
```

---

## 11. Payment Methods APIs 💳

### 11.1. Get User Payment Methods
**GET** `/api/v1/users/:userId/payment-methods`

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "payment-method-uuid",
      "type": "card",
      "cardNumber": "****1234",
      "cardHolderName": "John Doe",
      "expiryMonth": 12,
      "expiryYear": 2025,
      "isDefault": true
    }
  ]
}
```

---

### 11.2. Add Payment Method
**POST** `/api/v1/users/:userId/payment-methods`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "type": "card",
  "cardNumber": "4111111111111111",
  "cardHolderName": "John Doe",
  "expiryMonth": 12,
  "expiryYear": 2025,
  "cvv": "123",
  "isDefault": true
}
```

---

### 11.3. Delete Payment Method
**DELETE** `/api/v1/users/:userId/payment-methods/:methodId`

**Headers:** `Authorization: Bearer {token}`

---

## 12. Search APIs 🔍

### 12.1. Search Restaurants
**GET** `/api/v1/search/restaurants`

**Query Parameters:**
- `q`: Search query
- `latitude` (optional): User latitude
- `longitude` (optional): User longitude
- `page` (optional): Page number
- `limit` (optional): Items per page

**Example:**
```
GET /api/v1/search/restaurants?q=pizza&latitude=24.7136&longitude=46.6753
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "id": "restaurant-uuid",
        "name": "Pizza Palace",
        "description": "...",
        "rating": 4.5
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 5
    }
  }
}
```

---

## 📊 Error Responses

جميع الأخطاء تتبع نفس التنسيق:

```json
{
  "success": false,
  "error": "Error message in English",
  "errorAr": "رسالة الخطأ بالعربي", // optional
  "code": "ERROR_CODE" // optional
}
```

### Status Codes:
- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Missing or invalid token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource conflict (e.g., duplicate email)
- `422 Unprocessable Entity` - Validation errors
- `500 Internal Server Error` - Server error

---

## 🔄 Real-time Updates

### WebSocket Connection
**WS** `wss://api.servy.app/ws`

**Authentication:**
```
?token={access_token}&userType={customer|driver|restaurant}
```

**Message Types:**
- `order_status_update` - Order status changed
- `new_order` - New order notification (restaurant)
- `new_delivery_request` - New delivery request (driver)
- `driver_location_update` - Driver location update (customer)
- `order_assigned` - Order assigned to driver

---

## 📝 Notes (ملاحظات مهمة)

1. **Pagination:** جميع الـ List endpoints تدعم pagination
2. **Filtering:** معظم الـ List endpoints تدعم filtering و sorting
3. **Authentication:** جميع الـ APIs (عدا Login/Register) تحتاج token
4. **Real-time:** استخدم WebSocket للـ Real-time updates
5. **Image Upload:** استخدم multipart/form-data لرفع الصور

---

## ✅ Checklist للـ Backend Developer

- [ ] Implement جميع الـ Authentication APIs
- [ ] Implement جميع الـ Restaurant APIs
- [ ] Implement جميع الـ Order APIs
- [ ] Implement جميع الـ Driver APIs
- [ ] Implement جميع الـ Rating APIs
- [ ] Add Authentication middleware
- [ ] Add Input validation
- [ ] Add Error handling
- [ ] Add Pagination support
- [ ] Add Filtering & Sorting
- [ ] Setup WebSocket server
- [ ] Add Rate limiting
- [ ] Add CORS support
- [ ] Add API documentation (Swagger/OpenAPI)
- [ ] Add Unit tests
- [ ] Add Integration tests

---

**تم إنشاء هذا الملف بتاريخ:** 2024
**آخر تحديث:** 2024
**الإصدار:** 1.0

