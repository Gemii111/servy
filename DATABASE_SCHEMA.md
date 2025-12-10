# 🗄️ Database Schema - Servy Food Delivery System

## 📋 نظرة عامة

هذا الملف يحتوي على مواصفات قاعدة البيانات الكاملة لنظام Servy لتوصيل الطعام. يحتوي على جميع الـ Tables والـ Relationships والـ Constraints المطلوبة.

---

## 📊 Database Tables

### 1. **users** (المستخدمين)

```sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    phone VARCHAR(20),
    user_type ENUM('customer', 'driver', 'restaurant') NOT NULL,
    image_url TEXT,
    is_email_verified BOOLEAN DEFAULT FALSE,
    fcm_token TEXT,
    is_online BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_user_type (user_type),
    INDEX idx_phone (phone)
);
```

**الحقول:**
- `id`: UUID للمستخدم
- `email`: البريد الإلكتروني (unique)
- `password_hash`: كلمة المرور المشفرة
- `name`: اسم المستخدم
- `phone`: رقم الهاتف
- `user_type`: نوع المستخدم (customer, driver, restaurant)
- `image_url`: رابط صورة الملف الشخصي
- `is_email_verified`: هل تم التحقق من البريد
- `fcm_token`: Token للإشعارات
- `is_online`: حالة الاتصال (للـ Drivers)
- `created_at`: تاريخ الإنشاء
- `updated_at`: تاريخ آخر تحديث

---

### 2. **restaurants** (المطاعم)

```sql
CREATE TABLE restaurants (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INT DEFAULT 0,
    cuisine_type VARCHAR(100),
    delivery_time DECIMAL(5,2) DEFAULT 30.00, -- in minutes
    delivery_fee DECIMAL(10,2) DEFAULT 5.00,
    min_order_amount DECIMAL(10,2),
    is_open BOOLEAN DEFAULT TRUE,
    address TEXT NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    images TEXT, -- JSON array of image URLs
    is_featured BOOLEAN DEFAULT FALSE,
    phone VARCHAR(20),
    email VARCHAR(255),
    auto_accept_orders BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_location (latitude, longitude),
    INDEX idx_is_open (is_open),
    INDEX idx_is_featured (is_featured),
    INDEX idx_cuisine (cuisine_type)
);
```

**الحقول:**
- `id`: UUID للمطعم
- `user_id`: ربط بجدول المستخدمين
- `name`: اسم المطعم
- `description`: وصف المطعم
- `image_url`: صورة المطعم الرئيسية
- `rating`: التقييم المتوسط (0.00 - 5.00)
- `review_count`: عدد التقييمات
- `cuisine_type`: نوع المطبخ
- `delivery_time`: وقت التوصيل المتوقع (بالدقائق)
- `delivery_fee`: رسوم التوصيل
- `min_order_amount`: الحد الأدنى للطلب
- `is_open`: هل المطعم مفتوح
- `address`: العنوان
- `latitude`, `longitude`: الإحداثيات
- `images`: مجموعة صور المطعم (JSON)
- `is_featured`: هل المطعم مميز
- `phone`: رقم الهاتف
- `email`: البريد الإلكتروني
- `auto_accept_orders`: قبول الطلبات تلقائياً

---

### 3. **categories** (الفئات)

```sql
CREATE TABLE categories (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NOT NULL,
    icon_url TEXT,
    color VARCHAR(7), -- Hex color code
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name)
);
```

---

### 4. **menu_categories** (فئات القوائم - للمطاعم)

```sql
CREATE TABLE menu_categories (
    id VARCHAR(36) PRIMARY KEY,
    restaurant_id VARCHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_display_order (display_order)
);
```

---

### 5. **menu_items** (عناصر القائمة)

```sql
CREATE TABLE menu_items (
    id VARCHAR(36) PRIMARY KEY,
    menu_category_id VARCHAR(36) NOT NULL,
    restaurant_id VARCHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (menu_category_id) REFERENCES menu_categories(id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_category (menu_category_id),
    INDEX idx_is_available (is_available)
);
```

---

### 6. **menu_extras** (الإضافات - Extra Options)

```sql
CREATE TABLE menu_extras (
    id VARCHAR(36) PRIMARY KEY,
    menu_item_id VARCHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE,
    INDEX idx_menu_item (menu_item_id)
);
```

---

### 7. **addresses** (العناوين)

```sql
CREATE TABLE addresses (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    label VARCHAR(50) NOT NULL, -- Home, Work, etc.
    address_line TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_is_default (is_default)
);
```

---

### 8. **orders** (الطلبات)

```sql
CREATE TABLE orders (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    restaurant_id VARCHAR(36) NOT NULL,
    driver_id VARCHAR(36),
    status ENUM('pending', 'accepted', 'preparing', 'ready', 'out_for_delivery', 'delivered', 'cancelled') DEFAULT 'pending',
    subtotal DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2),
    discount DECIMAL(10,2),
    total DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- cash, card, wallet
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estimated_delivery_time TIMESTAMP,
    delivered_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancelled_reason TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
    FOREIGN KEY (driver_id) REFERENCES users(id),
    INDEX idx_user (user_id),
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_driver (driver_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
```

**الحقول المهمة:**
- `status`: حالة الطلب
- `estimated_delivery_time`: وقت التوصيل المتوقع
- `delivered_at`: وقت التسليم الفعلي
- `cancelled_at`: وقت الإلغاء
- `cancelled_reason`: سبب الإلغاء

---

### 9. **order_items** (عناصر الطلب)

```sql
CREATE TABLE order_items (
    id VARCHAR(36) PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL,
    menu_item_id VARCHAR(36) NOT NULL,
    menu_item_name VARCHAR(255) NOT NULL, -- Store name for historical records
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id),
    INDEX idx_order (order_id)
);
```

---

### 10. **order_item_extras** (إضافات عناصر الطلب)

```sql
CREATE TABLE order_item_extras (
    id VARCHAR(36) PRIMARY KEY,
    order_item_id VARCHAR(36) NOT NULL,
    extra_name VARCHAR(255) NOT NULL,
    extra_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE,
    INDEX idx_order_item (order_item_id)
);
```

---

### 11. **order_delivery_address** (عنوان التوصيل للطلب)

```sql
CREATE TABLE order_delivery_address (
    id VARCHAR(36) PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL UNIQUE,
    label VARCHAR(50),
    address_line TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);
```

---

### 12. **ratings** (التقييمات)

```sql
CREATE TABLE ratings (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    restaurant_id VARCHAR(36) NOT NULL,
    order_id VARCHAR(36),
    rating DECIMAL(2,1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    comment TEXT,
    image_urls TEXT, -- JSON array
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    UNIQUE KEY unique_user_restaurant_order (user_id, restaurant_id, order_id),
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_user (user_id),
    INDEX idx_created_at (created_at)
);
```

---

### 13. **driver_locations** (مواقع السائقين - Real-time)

```sql
CREATE TABLE driver_locations (
    id VARCHAR(36) PRIMARY KEY,
    driver_id VARCHAR(36) NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    heading DECIMAL(5,2), -- Direction in degrees
    speed DECIMAL(5,2), -- Speed in km/h
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_driver (driver_id),
    INDEX idx_timestamp (timestamp),
    UNIQUE KEY unique_driver (driver_id) -- Only latest location per driver
);
```

---

### 14. **payment_methods** (طرق الدفع)

```sql
CREATE TABLE payment_methods (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    type VARCHAR(50) NOT NULL, -- card, wallet
    card_number VARCHAR(20), -- Last 4 digits only for security
    card_holder_name VARCHAR(255),
    expiry_month INT,
    expiry_year INT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id)
);
```

---

### 15. **coupons** (الكوبونات)

```sql
CREATE TABLE coupons (
    id VARCHAR(36) PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_type ENUM('percentage', 'fixed') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2),
    max_discount_amount DECIMAL(10,2),
    usage_limit INT,
    used_count INT DEFAULT 0,
    valid_from TIMESTAMP,
    valid_until TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_is_active (is_active)
);
```

---

### 16. **coupon_usages** (استخدامات الكوبونات)

```sql
CREATE TABLE coupon_usages (
    id VARCHAR(36) PRIMARY KEY,
    coupon_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    order_id VARCHAR(36) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_user (user_id),
    INDEX idx_coupon (coupon_id)
);
```

---

### 17. **favorites** (المطاعم المفضلة)

```sql
CREATE TABLE favorites (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    restaurant_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_restaurant (user_id, restaurant_id),
    INDEX idx_user (user_id),
    INDEX idx_restaurant (restaurant_id)
);
```

---

### 18. **order_status_history** (سجل حالة الطلب)

```sql
CREATE TABLE order_status_history (
    id VARCHAR(36) PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL,
    status VARCHAR(50) NOT NULL,
    changed_by VARCHAR(36), -- user_id who changed status
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order (order_id),
    INDEX idx_created_at (created_at)
);
```

---

## 🔗 Relationships (العلاقات)

### العلاقات الرئيسية:

1. **users** ←→ **restaurants** (One-to-One)
   - `restaurants.user_id` → `users.id`

2. **users** ←→ **addresses** (One-to-Many)
   - `addresses.user_id` → `users.id`

3. **users** ←→ **orders** (One-to-Many)
   - `orders.user_id` → `users.id` (Customer)
   - `orders.driver_id` → `users.id` (Driver)

4. **restaurants** ←→ **menu_categories** (One-to-Many)
   - `menu_categories.restaurant_id` → `restaurants.id`

5. **menu_categories** ←→ **menu_items** (One-to-Many)
   - `menu_items.menu_category_id` → `menu_categories.id`

6. **menu_items** ←→ **menu_extras** (One-to-Many)
   - `menu_extras.menu_item_id` → `menu_items.id`

7. **orders** ←→ **order_items** (One-to-Many)
   - `order_items.order_id` → `orders.id`

8. **order_items** ←→ **order_item_extras** (One-to-Many)
   - `order_item_extras.order_item_id` → `order_items.id`

9. **restaurants** ←→ **ratings** (One-to-Many)
   - `ratings.restaurant_id` → `restaurants.id`

10. **users** ←→ **favorites** ←→ **restaurants** (Many-to-Many)
    - `favorites.user_id` → `users.id`
    - `favorites.restaurant_id` → `restaurants.id`

---

## 📊 Indexes (الفهارس)

### Indexes المضافة في الـ Tables:

- ✅ **Email indexes** لسرعة البحث
- ✅ **Location indexes** (latitude, longitude) للبحث القريب
- ✅ **Status indexes** لفلترة الطلبات
- ✅ **Date indexes** للترتيب حسب التاريخ
- ✅ **Foreign key indexes** لتحسين Join operations

---

## 🔐 Constraints (القيود)

### Unique Constraints:

- `users.email` - UNIQUE
- `restaurants.user_id` - One restaurant per user account
- `ratings(user_id, restaurant_id, order_id)` - One rating per order
- `favorites(user_id, restaurant_id)` - No duplicate favorites
- `coupons.code` - UNIQUE coupon codes

### Check Constraints:

- `ratings.rating` - BETWEEN 1.0 AND 5.0
- `orders.status` - Valid enum values

---

## 📝 Notes (ملاحظات مهمة)

### 1. **Soft Deletes:**
- يمكن إضافة حقل `deleted_at` للـ Soft Deletes
- بدلاً من حذف البيانات الفعلية

### 2. **Data Types:**
- استخدام `VARCHAR(36)` للـ UUIDs
- استخدام `DECIMAL(10,2)` للمبالغ المالية
- استخدام `TIMESTAMP` للتواريخ

### 3. **JSON Fields:**
- `restaurants.images` - JSON array
- `ratings.image_urls` - JSON array

### 4. **Real-time Updates:**
- `driver_locations` يتم تحديثها بشكل مستمر
- يمكن استخدام Redis للـ Real-time location tracking

### 5. **Archival:**
- يمكن إنشاء جداول منفصلة للـ Archived orders
- للاحتفاظ بالأداء

---

## 🔄 Migration Notes

### المراحل المقترحة:

1. **Phase 1:** Core Tables (users, restaurants, orders)
2. **Phase 2:** Menu System (categories, menu_items, extras)
3. **Phase 3:** User Features (addresses, favorites, ratings)
4. **Phase 4:** Advanced (payment_methods, coupons, driver_locations)

---

## ✅ Checklist للـ Backend Developer

- [ ] إنشاء جميع الـ Tables
- [ ] إضافة جميع الـ Foreign Keys
- [ ] إضافة جميع الـ Indexes
- [ ] إضافة الـ Constraints
- [ ] اختبار الـ Relationships
- [ ] إضافة Seed Data (اختياري)
- [ ] إعداد Database Backups
- [ ] Document API responses matching these schemas

---

**تم إنشاء هذا الملف بتاريخ:** 2024
**آخر تحديث:** 2024
**الإصدار:** 1.0

