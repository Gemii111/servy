# 🎛️ Admin Panel Specification - Servy Food Delivery System

## 📋 نظرة عامة

هذا الملف يحتوي على المواصفات الكاملة لبناء **Admin Panel (Website)** لمتابعة وإدارة نظام Servy لتوصيل الطعام بالكامل.

**النوع:** Web Application (Website)
**الهدف:** إدارة ومراقبة جميع جوانب النظام (Customers, Drivers, Restaurants, Orders, Analytics)

---

## 🎯 الميزات المطلوبة (Features)

### 1. **Dashboard (الصفحة الرئيسية)** ⭐

**الإحصائيات العامة:**
- 📊 Total Users (Customers + Drivers + Restaurants)
- 📊 Total Orders (Today, Week, Month, All Time)
- 📊 Total Revenue (Today, Week, Month, All Time)
- 📊 Active Restaurants (Open/Closed)
- 📊 Active Drivers (Online/Offline)
- 📊 Pending Orders
- 📊 Orders by Status (Chart)
- 📊 Revenue Chart (Daily/Weekly/Monthly)

**Graphs & Charts:**
- Orders Over Time (Line Chart)
- Revenue Over Time (Line Chart)
- Orders by Status (Pie Chart)
- Top Restaurants (Bar Chart)
- Top Drivers (Bar Chart)

---

### 2. **Users Management (إدارة المستخدمين)** 👥

#### 2.1. Customers Management
**الميزات:**
- ✅ عرض قائمة جميع العملاء
- ✅ البحث والفلترة (By Name, Email, Phone, Registration Date)
- ✅ عرض تفاصيل العميل:
  - Profile Information
  - Order History
  - Total Spent
  - Favorite Restaurants
  - Addresses
  - Payment Methods
- ✅ تعطيل/تفعيل حساب العميل
- ✅ حذف حساب العميل
- ✅ Export Data (CSV/Excel)

**الجدول:**
| Column | Description |
|--------|-------------|
| ID | User ID |
| Name | Full Name |
| Email | Email Address |
| Phone | Phone Number |
| Total Orders | Number of orders |
| Total Spent | Total money spent |
| Status | Active/Suspended |
| Registered | Registration Date |
| Actions | View/Edit/Delete/Disable |

---

#### 2.2. Drivers Management
**الميزات:**
- ✅ عرض قائمة جميع السائقين
- ✅ البحث والفلترة (By Name, Email, Status)
- ✅ عرض تفاصيل السائق:
  - Profile Information
  - Total Deliveries
  - Total Earnings
  - Current Status (Online/Offline)
  - Current Location (Map)
  - Active Orders
  - Order History
  - Ratings & Reviews
- ✅ تعطيل/تفعيل حساب السائق
- ✅ عرض Location في Real-time
- ✅ View Earnings Reports

**الجدول:**
| Column | Description |
|--------|-------------|
| ID | Driver ID |
| Name | Full Name |
| Email | Email Address |
| Phone | Phone Number |
| Status | Online/Offline |
| Total Deliveries | Number of deliveries |
| Total Earnings | Total earnings |
| Rating | Average rating |
| Registered | Registration Date |
| Actions | View/Edit/Delete/Disable |

---

#### 2.3. Restaurants Management
**الميزات:**
- ✅ عرض قائمة جميع المطاعم
- ✅ البحث والفلترة (By Name, Cuisine Type, Status)
- ✅ عرض تفاصيل المطعم:
  - Restaurant Information
  - Menu Items
  - Orders History
  - Revenue Statistics
  - Ratings & Reviews
  - Current Status (Open/Closed)
- ✅ الموافقة على المطاعم الجديدة (Approve/Reject)
- ✅ تعطيل/تفعيل المطعم
- ✅ تعديل معلومات المطعم
- ✅ عرض Menu Management

**الجدول:**
| Column | Description |
|--------|-------------|
| ID | Restaurant ID |
| Name | Restaurant Name |
| Owner Email | Owner email |
| Cuisine Type | Type of cuisine |
| Status | Open/Closed/Approved/Pending |
| Total Orders | Number of orders |
| Total Revenue | Total revenue |
| Rating | Average rating |
| Registered | Registration Date |
| Actions | View/Edit/Delete/Approve/Disable |

---

### 3. **Orders Management (إدارة الطلبات)** 📦

**الميزات:**
- ✅ عرض جميع الطلبات
- ✅ البحث والفلترة (By Status, Date, Customer, Restaurant, Driver)
- ✅ عرض تفاصيل الطلب:
  - Order Information
  - Customer Details
  - Restaurant Details
  - Driver Details (if assigned)
  - Items List
  - Delivery Address
  - Payment Information
  - Status Timeline
- ✅ تحديث حالة الطلب
- ✅ إلغاء الطلب
- ✅ تعيين سائق للطلب
- ✅ View Order Tracking Map
- ✅ Export Orders Report

**Filters:**
- By Status: All, Pending, Accepted, Preparing, Ready, Out for Delivery, Delivered, Cancelled
- By Date: Today, This Week, This Month, Custom Range
- By Restaurant
- By Customer
- By Driver

**الجدول:**
| Column | Description |
|--------|-------------|
| Order ID | Order unique ID |
| Customer | Customer name |
| Restaurant | Restaurant name |
| Driver | Driver name (if assigned) |
| Items | Number of items |
| Total | Total amount |
| Status | Current status |
| Date | Order date |
| Actions | View/Update Status/Cancel |

---

### 4. **Restaurants Approval (الموافقة على المطاعم)** 🏪

**الميزات:**
- ✅ عرض المطاعم المعلقة (Pending Approval)
- ✅ عرض تفاصيل المطعم للاستعراض:
  - Restaurant Information
  - Owner Information
  - Documents (if any)
  - Menu Preview
- ✅ الموافقة على المطعم (Approve)
- ✅ رفض المطعم (Reject) مع إرسال Reason

**Workflow:**
1. Restaurant registers
2. Status: "Pending Approval"
3. Admin reviews
4. Admin approves/rejects
5. Restaurant receives notification

---

### 5. **Menu Management (إدارة القوائم)** 🍽️

**الميزات:**
- ✅ عرض جميع Menu Items في النظام
- ✅ البحث والفلترة (By Restaurant, Category, Availability)
- ✅ عرض تفاصيل Menu Item:
  - Item Information
  - Price
  - Availability
  - Extras/Options
  - Restaurant
- ✅ تعديل Menu Items (If needed)
- ✅ حذف Menu Items (If needed)

---

### 6. **Categories Management (إدارة الفئات)** 📂

**الميزات:**
- ✅ عرض جميع الفئات
- ✅ إضافة فئة جديدة
- ✅ تعديل فئة موجودة
- ✅ حذف فئة
- ✅ Upload Category Icon
- ✅ Set Category Color

**Fields:**
- Name (English)
- Name (Arabic)
- Icon URL
- Color (Hex Code)

---

### 7. **Ratings & Reviews Management (إدارة التقييمات)** ⭐

**الميزات:**
- ✅ عرض جميع التقييمات
- ✅ البحث والفلترة (By Restaurant, Rating, Date)
- ✅ عرض تفاصيل التقييم:
  - User Information
  - Restaurant Information
  - Rating (Stars)
  - Comment
  - Photos (if any)
  - Date
- ✅ حذف تقييم (If inappropriate)
- ✅ Respond to Review (Optional)

**Filters:**
- By Rating: 1-5 Stars
- By Restaurant
- By Date

---

### 8. **Coupons Management (إدارة الكوبونات)** 🎟️

**الميزات:**
- ✅ عرض جميع الكوبونات
- ✅ إضافة كوبون جديد:
  - Code
  - Discount Type (Percentage/Fixed)
  - Discount Value
  - Min Order Amount
  - Max Discount Amount
  - Usage Limit
  - Valid From/Until Dates
- ✅ تعديل كوبون
- ✅ حذف/تعطيل كوبون
- ✅ View Usage Statistics

**الجدول:**
| Column | Description |
|--------|-------------|
| Code | Coupon code |
| Type | Percentage/Fixed |
| Value | Discount value |
| Usage | Used/Total limit |
| Status | Active/Expired/Disabled |
| Valid Until | Expiry date |
| Actions | Edit/Delete/Disable |

---

### 9. **Reports & Analytics (التقارير والإحصائيات)** 📊

#### 9.1. Sales Reports
- ✅ Daily/Weekly/Monthly/Yearly Reports
- ✅ Revenue by Restaurant
- ✅ Revenue by Period
- ✅ Top Selling Items
- ✅ Export Reports (PDF/Excel)

#### 9.2. Order Reports
- ✅ Orders by Status
- ✅ Orders by Period
- ✅ Average Order Value
- ✅ Order Completion Rate
- ✅ Cancellation Rate

#### 9.3. User Reports
- ✅ New Users by Period
- ✅ Active Users
- ✅ User Retention Rate
- ✅ Top Customers

#### 9.4. Driver Reports
- ✅ Driver Performance
- ✅ Top Drivers
- ✅ Driver Earnings
- ✅ Delivery Time Statistics

#### 9.5. Restaurant Reports
- ✅ Restaurant Performance
- ✅ Top Restaurants
- ✅ Restaurant Revenue
- ✅ Restaurant Ratings

---

### 10. **Settings (الإعدادات)** ⚙️

#### 10.1. System Settings
- ✅ App Version
- ✅ Maintenance Mode (Enable/Disable)
- ✅ Default Delivery Fee
- ✅ Default Tax Rate
- ✅ Currency Settings
- ✅ Payment Gateway Settings

#### 10.2. Notification Settings
- ✅ Send Notifications to:
  - All Customers
  - All Drivers
  - All Restaurants
  - Specific Users

#### 10.3. Content Management
- ✅ Manage App Content
- ✅ Terms & Conditions
- ✅ Privacy Policy
- ✅ About Us

---

### 11. **Activity Logs (سجل الأنشطة)** 📝

**الميزات:**
- ✅ عرض جميع الأنشطة في النظام
- ✅ Filters:
  - By User Type (Admin, Customer, Driver, Restaurant)
  - By Action Type
  - By Date
- ✅ View Details:
  - User who performed action
  - Action Type
  - Timestamp
  - Details

**Activity Types:**
- User Created/Updated/Deleted
- Order Created/Updated/Cancelled
- Restaurant Approved/Rejected
- Settings Changed
- etc.

---

### 12. **Notifications Management (إدارة الإشعارات)** 🔔

**الميزات:**
- ✅ إرسال إشعارات:
  - To All Users
  - To Specific Users (Customer/Driver/Restaurant)
  - To Specific User
- ✅ Broadcast Messages
- ✅ Push Notification History

**Notification Types:**
- System Updates
- Promotions
- Maintenance Alerts
- Custom Messages

---

## 🗄️ Database Schema Additions

### 1. **admins** Table

```sql
CREATE TABLE admins (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role ENUM('super_admin', 'admin', 'moderator') DEFAULT 'admin',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role)
);
```

---

### 2. **activity_logs** Table

```sql
CREATE TABLE activity_logs (
    id VARCHAR(36) PRIMARY KEY,
    admin_id VARCHAR(36),
    user_id VARCHAR(36),
    user_type VARCHAR(50), -- customer, driver, restaurant
    action_type VARCHAR(100) NOT NULL, -- create, update, delete, approve, etc.
    entity_type VARCHAR(100) NOT NULL, -- user, order, restaurant, etc.
    entity_id VARCHAR(36),
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(id),
    INDEX idx_admin (admin_id),
    INDEX idx_user (user_id),
    INDEX idx_action (action_type),
    INDEX idx_created_at (created_at)
);
```

---

### 3. **admin_notifications** Table

```sql
CREATE TABLE admin_notifications (
    id VARCHAR(36) PRIMARY KEY,
    admin_id VARCHAR(36),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50), -- info, warning, error, success
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(id),
    INDEX idx_admin (admin_id),
    INDEX idx_is_read (is_read)
);
```

---

### 4. **system_settings** Table

```sql
CREATE TABLE system_settings (
    id VARCHAR(36) PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    updated_by VARCHAR(36),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (updated_by) REFERENCES admins(id),
    INDEX idx_key (key)
);
```

---

### 5. **broadcast_notifications** Table

```sql
CREATE TABLE broadcast_notifications (
    id VARCHAR(36) PRIMARY KEY,
    admin_id VARCHAR(36),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    target_audience ENUM('all', 'customers', 'drivers', 'restaurants') NOT NULL,
    user_ids TEXT, -- JSON array of user IDs (if specific users)
    sent_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(id),
    INDEX idx_created_at (created_at)
);
```

---

## 🌐 API Endpoints للـ Admin Panel

### Authentication APIs

#### 1. Admin Login
**POST** `/api/v1/admin/auth/login`

**Request:**
```json
{
  "email": "admin@servy.app",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "admin": {
      "id": "admin-uuid",
      "email": "admin@servy.app",
      "name": "Admin Name",
      "role": "super_admin"
    },
    "accessToken": "jwt-token"
  }
}
```

---

#### 2. Get Admin Profile
**GET** `/api/v1/admin/profile`

**Headers:** `Authorization: Bearer {token}`

---

### Dashboard APIs

#### 3. Get Dashboard Statistics
**GET** `/api/v1/admin/dashboard/statistics`

**Query Parameters:**
- `period` (optional): today | week | month | year | all (default: today)

**Response:**
```json
{
  "success": true,
  "data": {
    "totalUsers": 5000,
    "totalCustomers": 4000,
    "totalDrivers": 500,
    "totalRestaurants": 500,
    "totalOrders": 25000,
    "totalRevenue": 500000.00,
    "todayOrders": 150,
    "todayRevenue": 5000.00,
    "pendingOrders": 25,
    "activeRestaurants": 450,
    "activeDrivers": 200,
    "ordersByStatus": {
      "pending": 25,
      "accepted": 50,
      "preparing": 30,
      "out_for_delivery": 20,
      "delivered": 22500,
      "cancelled": 375
    }
  }
}
```

---

#### 4. Get Dashboard Charts
**GET** `/api/v1/admin/dashboard/charts`

**Query Parameters:**
- `type`: orders | revenue | users
- `period`: week | month | year
- `groupBy`: day | week | month

**Response:**
```json
{
  "success": true,
  "data": {
    "labels": ["2024-01-01", "2024-01-02", ...],
    "values": [150, 200, ...]
  }
}
```

---

### Users Management APIs

#### 5. Get All Users
**GET** `/api/v1/admin/users`

**Query Parameters:**
- `userType`: customer | driver | restaurant
- `search`: Search query
- `status`: active | suspended
- `page`: Page number
- `limit`: Items per page
- `sortBy`: name | email | created_at
- `sortOrder`: asc | desc

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "user-uuid",
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+966501234567",
        "userType": "customer",
        "status": "active",
        "totalOrders": 25,
        "totalSpent": 1250.00,
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 5000,
      "totalPages": 250
    }
  }
}
```

---

#### 6. Get User Details
**GET** `/api/v1/admin/users/:id`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user-uuid",
    "email": "john@example.com",
    "name": "John Doe",
    "phone": "+966501234567",
    "userType": "customer",
    "status": "active",
    "totalOrders": 25,
    "totalSpent": 1250.00,
    "addresses": [...],
    "paymentMethods": [...],
    "favoriteRestaurants": [...],
    "orderHistory": [...],
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

---

#### 7. Update User Status
**PUT** `/api/v1/admin/users/:id/status`

**Request:**
```json
{
  "status": "suspended" // active | suspended
}
```

---

#### 8. Delete User
**DELETE** `/api/v1/admin/users/:id`

---

### Restaurants Management APIs

#### 9. Get All Restaurants
**GET** `/api/v1/admin/restaurants`

**Query Parameters:**
- `status`: all | approved | pending | suspended
- `search`: Search query
- `page`: Page number
- `limit`: Items per page

---

#### 10. Get Restaurant Details (Admin)
**GET** `/api/v1/admin/restaurants/:id`

---

#### 11. Approve Restaurant
**POST** `/api/v1/admin/restaurants/:id/approve`

**Response:**
```json
{
  "success": true,
  "message": "Restaurant approved successfully"
}
```

---

#### 12. Reject Restaurant
**POST** `/api/v1/admin/restaurants/:id/reject`

**Request:**
```json
{
  "reason": "Missing required documents"
}
```

---

#### 13. Update Restaurant Status
**PUT** `/api/v1/admin/restaurants/:id/status`

**Request:**
```json
{
  "status": "suspended" // approved | pending | suspended
}
```

---

### Orders Management APIs

#### 14. Get All Orders (Admin)
**GET** `/api/v1/admin/orders`

**Query Parameters:**
- `status`: Filter by status
- `restaurantId`: Filter by restaurant
- `customerId`: Filter by customer
- `driverId`: Filter by driver
- `dateFrom`: Start date
- `dateTo`: End date
- `page`: Page number
- `limit`: Items per page

---

#### 15. Get Order Details (Admin)
**GET** `/api/v1/admin/orders/:id`

---

#### 16. Update Order Status (Admin)
**PUT** `/api/v1/admin/orders/:id/status`

**Request:**
```json
{
  "status": "cancelled",
  "reason": "Admin cancellation reason"
}
```

---

#### 17. Assign Driver to Order
**POST** `/api/v1/admin/orders/:id/assign-driver`

**Request:**
```json
{
  "driverId": "driver-uuid"
}
```

---

### Categories Management APIs

#### 18. Get All Categories (Admin)
**GET** `/api/v1/admin/categories`

---

#### 19. Create Category
**POST** `/api/v1/admin/categories`

**Request:**
```json
{
  "name": "Pizza",
  "nameAr": "بيتزا",
  "iconUrl": "https://...",
  "color": "#FF5733"
}
```

---

#### 20. Update Category
**PUT** `/api/v1/admin/categories/:id`

---

#### 21. Delete Category
**DELETE** `/api/v1/admin/categories/:id`

---

### Coupons Management APIs

#### 22. Get All Coupons
**GET** `/api/v1/admin/coupons`

---

#### 23. Create Coupon
**POST** `/api/v1/admin/coupons`

**Request:**
```json
{
  "code": "DISCOUNT10",
  "discountType": "percentage",
  "discountValue": 10.00,
  "minOrderAmount": 50.00,
  "maxDiscountAmount": 20.00,
  "usageLimit": 100,
  "validFrom": "2024-01-01T00:00:00Z",
  "validUntil": "2024-12-31T23:59:59Z"
}
```

---

#### 24. Update Coupon
**PUT** `/api/v1/admin/coupons/:id`

---

#### 25. Delete Coupon
**DELETE** `/api/v1/admin/coupons/:id`

---

### Reports & Analytics APIs

#### 26. Get Sales Report
**GET** `/api/v1/admin/reports/sales`

**Query Parameters:**
- `period`: today | week | month | year | custom
- `dateFrom`: Start date (if custom)
- `dateTo`: End date (if custom)
- `restaurantId`: Filter by restaurant (optional)
- `format`: json | pdf | excel

---

#### 27. Get Orders Report
**GET** `/api/v1/admin/reports/orders`

---

#### 28. Get Users Report
**GET** `/api/v1/admin/reports/users`

---

#### 29. Export Report
**GET** `/api/v1/admin/reports/export`

**Query Parameters:**
- `type`: sales | orders | users
- `format`: pdf | excel | csv
- `period`: ...

---

### Activity Logs APIs

#### 30. Get Activity Logs
**GET** `/api/v1/admin/activity-logs`

**Query Parameters:**
- `userType`: customer | driver | restaurant | admin
- `actionType`: create | update | delete | approve
- `dateFrom`: Start date
- `dateTo`: End date
- `page`: Page number
- `limit`: Items per page

**Response:**
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": "log-uuid",
        "adminId": "admin-uuid",
        "adminName": "Admin Name",
        "userId": "user-uuid",
        "userType": "customer",
        "actionType": "update",
        "entityType": "user",
        "entityId": "user-uuid",
        "description": "User status updated to suspended",
        "ipAddress": "192.168.1.1",
        "createdAt": "2024-01-01T12:00:00Z"
      }
    ],
    "pagination": {...}
  }
}
```

---

### Settings APIs

#### 31. Get System Settings
**GET** `/api/v1/admin/settings`

**Response:**
```json
{
  "success": true,
  "data": {
    "appVersion": "1.0.0",
    "maintenanceMode": false,
    "defaultDeliveryFee": 5.00,
    "defaultTaxRate": 0.15,
    "currency": "SAR",
    "paymentGateway": {
      "stripe": {...},
      "paypal": {...}
    }
  }
}
```

---

#### 32. Update System Settings
**PUT** `/api/v1/admin/settings`

**Request:**
```json
{
  "maintenanceMode": true,
  "defaultDeliveryFee": 6.00,
  "defaultTaxRate": 0.15
}
```

---

### Notifications APIs

#### 33. Send Broadcast Notification
**POST** `/api/v1/admin/notifications/broadcast`

**Request:**
```json
{
  "title": "System Maintenance",
  "message": "The system will be under maintenance tomorrow",
  "targetAudience": "all", // all | customers | drivers | restaurants
  "userIds": ["user-id-1", "user-id-2"] // Optional: if specific users
}
```

---

#### 34. Get Notification History
**GET** `/api/v1/admin/notifications/history`

---

## 🎨 UI/UX Design Requirements

### Technology Stack (مقترح)

#### Frontend Options:

**Option 1: React.js (موصى به)** ✅
- ✅ React 18+
- ✅ TypeScript
- ✅ Material-UI (MUI) or Ant Design
- ✅ React Query (for API calls)
- ✅ React Router (for navigation)
- ✅ Recharts (for charts)

**Option 2: Vue.js**
- ✅ Vue 3
- ✅ TypeScript
- ✅ Vuetify or Element Plus
- ✅ Vue Query
- ✅ Vue Router

**Option 3: Next.js (Full-stack)**
- ✅ Next.js 14+
- ✅ TypeScript
- ✅ Tailwind CSS
- ✅ Shadcn/ui

---

### Design System

**Components Needed:**
- ✅ Dashboard Cards
- ✅ Data Tables (with pagination, sorting, filtering)
- ✅ Charts & Graphs
- ✅ Forms (Create/Edit)
- ✅ Modals/Dialogs
- ✅ Status Badges
- ✅ Action Buttons
- ✅ Search Bars
- ✅ Filters
- ✅ Breadcrumbs
- ✅ Sidebar Navigation
- ✅ Top Navigation Bar
- ✅ User Dropdown

**Color Scheme:**
- Primary: Purple/Blue (consistent with mobile apps)
- Secondary: Orange
- Success: Green
- Error: Red
- Warning: Yellow
- Info: Blue

---

### Layout Structure

```
┌─────────────────────────────────────┐
│  Top Bar: Logo | Search | Admin     │
├──────────┬──────────────────────────┤
│          │                          │
│ Sidebar  │  Main Content Area       │
│          │                          │
│ - Dash   │  - Dashboard Cards       │
│ - Users  │  - Data Tables           │
│ - Orders │  - Charts                │
│ - Rest   │  - Forms                 │
│ - Reports│                          │
│ - Settings                           │
│          │                          │
└──────────┴──────────────────────────┘
```

---

## 📱 Pages/Screens المطلوبة

### 1. Login Page
- Email & Password
- Remember Me
- Forgot Password

### 2. Dashboard
- Statistics Cards
- Charts
- Recent Activities
- Quick Actions

### 3. Users Management
- Users List Page
- User Details Page
- User Edit Page

### 4. Restaurants Management
- Restaurants List Page
- Restaurant Details Page
- Restaurant Edit Page
- Pending Approval Page

### 5. Orders Management
- Orders List Page
- Order Details Page

### 6. Categories Management
- Categories List Page
- Add/Edit Category Page

### 7. Coupons Management
- Coupons List Page
- Add/Edit Coupon Page

### 8. Reports & Analytics
- Reports Dashboard
- Sales Reports Page
- Orders Reports Page
- Users Reports Page
- Export Page

### 9. Settings
- System Settings Page
- Notification Settings Page

### 10. Activity Logs
- Activity Logs List Page
- Activity Details Page

---

## 🔐 Security Requirements

### 1. Authentication
- ✅ JWT Token-based Authentication
- ✅ Role-based Access Control (RBAC)
- ✅ Session Management
- ✅ Password Encryption (bcrypt)

### 2. Authorization
- ✅ Roles:
  - **Super Admin:** Full access
  - **Admin:** Full access (except system settings)
  - **Moderator:** Limited access (view only, basic actions)

### 3. Security Features
- ✅ HTTPS only
- ✅ CSRF Protection
- ✅ XSS Protection
- ✅ Rate Limiting
- ✅ IP Whitelisting (Optional)
- ✅ Two-Factor Authentication (Optional)

---

## 📊 Features Details

### Dashboard Statistics Cards

```
┌──────────────┬──────────────┬──────────────┬──────────────┐
│ Total Users  │ Total Orders │ Total Revenue│ Active Rest  │
│    5,000     │    25,000    │   $500,000   │     450      │
└──────────────┴──────────────┴──────────────┴──────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Orders Over Time Chart                    │
│         [Line Chart showing orders trend]                    │
└─────────────────────────────────────────────────────────────┘

┌──────────────────┬──────────────────┐
│ Orders by Status │ Top Restaurants  │
│   [Pie Chart]    │   [Bar Chart]    │
└──────────────────┴──────────────────┘
```

---

### Data Tables Features

**Required Features:**
- ✅ Pagination
- ✅ Sorting (by any column)
- ✅ Filtering (multiple filters)
- ✅ Search (global search)
- ✅ Export (CSV/Excel)
- ✅ Bulk Actions (Select multiple)
- ✅ Row Actions (View/Edit/Delete)

**Example:**
```
┌─────────────────────────────────────────────────────────────┐
│  [Search...]  [Filter ▼]  [Export ▼]  [Refresh]            │
├─────────────────────────────────────────────────────────────┤
│ ☐ Name    │ Email          │ Phone       │ Status │ Actions│
├───────────┼────────────────┼─────────────┼────────┼────────┤
│ ☐ John    │ john@...       │ +966...     │ Active │ [View] │
│ ☐ Jane    │ jane@...       │ +966...     │ Active │ [View] │
├───────────┴────────────────┴─────────────┴────────┴────────┤
│ Showing 1-20 of 5000        [< Prev] [Next >]              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Implementation Steps

### Phase 1: Setup & Authentication (Week 1)
1. ✅ Setup Project (React/Next.js)
2. ✅ Design System Setup (UI Library)
3. ✅ Routing Setup
4. ✅ Authentication System
5. ✅ Login Page
6. ✅ Protected Routes

### Phase 2: Dashboard & Users (Week 2)
1. ✅ Dashboard Page
2. ✅ Statistics Cards
3. ✅ Charts Integration
4. ✅ Users Management
5. ✅ User Details Page

### Phase 3: Restaurants & Orders (Week 3)
1. ✅ Restaurants Management
2. ✅ Restaurant Approval
3. ✅ Orders Management
4. ✅ Order Details

### Phase 4: Categories & Coupons (Week 4)
1. ✅ Categories Management
2. ✅ Coupons Management
3. ✅ Menu Items View

### Phase 5: Reports & Analytics (Week 5)
1. ✅ Reports Dashboard
2. ✅ Sales Reports
3. ✅ Orders Reports
4. ✅ Export Functionality

### Phase 6: Settings & Logs (Week 6)
1. ✅ System Settings
2. ✅ Activity Logs
3. ✅ Notifications Management
4. ✅ Final Testing

---

## 💻 Technical Stack Recommendations

### Frontend (Website)

**Option 1: React.js + TypeScript** ✅ (موصى به)
```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "typescript": "^5.0.0",
    "@mui/material": "^5.14.0",
    "@mui/icons-material": "^5.14.0",
    "@tanstack/react-query": "^5.0.0",
    "react-router-dom": "^6.20.0",
    "recharts": "^2.10.0",
    "axios": "^1.6.0",
    "date-fns": "^3.0.0"
  }
}
```

**Option 2: Next.js + TypeScript**
```json
{
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "typescript": "^5.0.0",
    "@tanstack/react-query": "^5.0.0",
    "tailwindcss": "^3.4.0",
    "shadcn/ui": "latest",
    "recharts": "^2.10.0"
  }
}
```

---

## 📋 Database Tables Summary

### New Tables Needed for Admin Panel:

1. **admins** - Admin users
2. **activity_logs** - System activity tracking
3. **admin_notifications** - Admin notifications
4. **system_settings** - System configuration
5. **broadcast_notifications** - Broadcast messages history

### Existing Tables (From Mobile Apps):

- ✅ users (customers, drivers, restaurants)
- ✅ restaurants
- ✅ orders
- ✅ categories
- ✅ menu_items
- ✅ ratings
- ✅ coupons
- ✅ addresses
- etc.

---

## 🔄 Integration Points

### 1. **Authentication**
- Use same JWT system as mobile apps
- Add Admin role to users table OR create separate admins table

### 2. **API Integration**
- Use same API base URL
- Add `/admin` prefix for admin-specific endpoints
- Reuse existing endpoints where possible

### 3. **Real-time Updates**
- WebSocket connection for real-time order updates
- Real-time dashboard statistics

---

## 📝 Checklist للمطور

### Backend Developer:

- [ ] Create `admins` table
- [ ] Create `activity_logs` table
- [ ] Create `system_settings` table
- [ ] Create `admin_notifications` table
- [ ] Implement Admin Authentication APIs
- [ ] Implement Dashboard Statistics APIs
- [ ] Implement Users Management APIs
- [ ] Implement Restaurants Management APIs
- [ ] Implement Orders Management APIs
- [ ] Implement Reports APIs
- [ ] Implement Activity Logging
- [ ] Add Admin Role Checks to existing APIs
- [ ] Implement Broadcast Notifications

### Frontend Developer:

- [ ] Setup Project (React/Next.js)
- [ ] Setup UI Library (MUI/Ant Design)
- [ ] Implement Authentication Flow
- [ ] Create Layout (Sidebar + Top Bar)
- [ ] Implement Dashboard Page
- [ ] Implement Users Management Pages
- [ ] Implement Restaurants Management Pages
- [ ] Implement Orders Management Pages
- [ ] Implement Reports Pages
- [ ] Implement Settings Page
- [ ] Add Charts & Graphs
- [ ] Add Data Tables with Filters
- [ ] Implement Export Functionality
- [ ] Add Real-time Updates

---

## 🎯 Priority Features (ما يجب عمله أولاً)

### High Priority (Must Have) ⭐⭐⭐

1. ✅ Dashboard with Statistics
2. ✅ Users Management (View, Edit, Delete)
3. ✅ Restaurants Management (Approve/Reject)
4. ✅ Orders Management (View, Update Status)
5. ✅ Authentication & Authorization

### Medium Priority (Should Have) ⭐⭐

6. ✅ Categories Management
7. ✅ Coupons Management
8. ✅ Reports & Analytics
9. ✅ Activity Logs

### Low Priority (Nice to Have) ⭐

10. ✅ Broadcast Notifications
11. ✅ Advanced Analytics
12. ✅ Export Reports

---

## 📖 Example Page Structure

### Dashboard Page

```jsx
// Dashboard Page Structure
<Layout>
  <DashboardStats>
    <StatCard title="Total Users" value={5000} />
    <StatCard title="Total Orders" value={25000} />
    <StatCard title="Total Revenue" value={500000} />
    <StatCard title="Active Restaurants" value={450} />
  </DashboardStats>
  
  <ChartsSection>
    <OrdersChart />
    <RevenueChart />
    <OrdersByStatusChart />
  </ChartsSection>
  
  <RecentActivities>
    <ActivityList />
  </RecentActivities>
</Layout>
```

---

### Users Management Page

```jsx
// Users Management Page
<Layout>
  <UsersHeader>
    <SearchBar />
    <Filters />
    <ExportButton />
  </UsersHeader>
  
  <UsersTable>
    <TableHeader />
    <TableRows data={users} />
    <TablePagination />
  </UsersTable>
</Layout>
```

---

## 🔗 Links & Resources

### UI Libraries:
- Material-UI: https://mui.com/
- Ant Design: https://ant.design/
- Shadcn/ui: https://ui.shadcn.com/

### Charts Libraries:
- Recharts: https://recharts.org/
- Chart.js: https://www.chartjs.org/
- ApexCharts: https://apexcharts.com/

### Icons:
- Material Icons: https://fonts.google.com/icons
- React Icons: https://react-icons.github.io/react-icons/

---

## ✅ Summary

**ما المطلوب منك:**

### 1. **Backend Developer:**
- ✅ إنشاء جداول الـ Admin في Database
- ✅ بناء جميع الـ Admin APIs
- ✅ إضافة Activity Logging
- ✅ إضافة Authorization Checks

### 2. **Frontend Developer:**
- ✅ بناء Website باستخدام React/Next.js
- ✅ بناء جميع الصفحات المطلوبة
- ✅ ربط الـ APIs
- ✅ إضافة Charts & Analytics

**الوقت المتوقع:**
- Backend: 3-4 أسابيع
- Frontend: 4-5 أسابيع
- Testing: 1-2 أسابيع

**الإجمالي:** 8-11 أسابيع

---

## 📞 Next Steps

1. ✅ مراجعة المواصفات
2. ✅ تحديد Technology Stack
3. ✅ البدء بالـ Backend (Database + APIs)
4. ✅ البدء بالـ Frontend (Website)
5. ✅ Integration & Testing

---

**تم إنشاء هذا الملف بتاريخ:** 2024
**آخر تحديث:** 2024
**الإصدار:** 1.0

