import 'package:flutter/material.dart';

/// Complete Localization class for Arabic and English
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  bool get isArabic => locale.languageCode == 'ar';

  // Helper method to get localized string
  String _getString(String en, String ar) => isArabic ? ar : en;

  // ==================== Common ====================
  String get appName => _getString('Servy', 'سيرفي');
  String get welcomeToApp =>
      _getString('Welcome to Servy', 'أهلاً بك في سيرفي');
  String get selectUserType =>
      _getString('Select User Type', 'اختار نوع المستخدم');
  String get selectUserTypeToLogin => _getString(
    'Select your account type to login',
    'اختار نوع حسابك عشان تسجل دخول',
  );
  String get customer => _getString('Customer', 'عميل');
  String get driver => _getString('Driver', 'سائق');
  String get restaurant => _getString('Restaurant', 'مطعم');
  String get customerDescription =>
      _getString('Order food from restaurants', 'اطلب أكلك من المطاعم');
  String get driverDescription =>
      _getString('Deliver orders and earn money', 'وصل الطلبات واكسب فلوس');
  String get restaurantDescription =>
      _getString('Manage your restaurant orders', 'ادار طلبات مطعمك');
  String get loading => _getString('Loading...', 'جاري التحميل...');
  String get cancel => _getString('Cancel', 'إلغاء');
  String get save => _getString('Save', 'حفظ');
  String get delete => _getString('Delete', 'حذف');
  String get edit => _getString('Edit', 'تعديل');
  String get done => _getString('Done', 'تمام');
  String get ok => _getString('OK', 'تمام');
  String get yes => _getString('Yes', 'آه');
  String get no => _getString('No', 'لأ');
  String get change => _getString('Change', 'غير');
  String get switchUserType =>
      _getString('Switch User Type', 'غير نوع المستخدم');
  String get failedToOpenMaps =>
      _getString('Failed to open maps', 'فشل فتح الخريطة');

  // ==================== Auth ====================
  String get login => _getString('Login', 'دخول');
  String get register => _getString('Register', 'تسجيل');
  String get logout => _getString('Logout', 'خروج');
  String get email => _getString('Email', 'الإيميل');
  String get password => _getString('Password', 'الباسورد');
  String get confirmPassword =>
      _getString('Confirm Password', 'تأكيد الباسورد');
  String get phone => _getString('Phone Number', 'رقم التليفون');
  String get name => _getString('Name', 'الاسم');
  String get welcomeBack => _getString('Welcome Back!', 'أهلاً بعودتك!');
  String get signInToContinue =>
      _getString('Sign in to continue', 'سجل دخول عشان تكمل');
  String get createAccount => _getString('Create Account', 'اعمل حساب');
  String get alreadyHaveAccount =>
      _getString('Already have an account?', 'عندك حساب؟');
  String get dontHaveAccount =>
      _getString("Don't have an account?", 'مش عندك حساب؟');
  String get forgotPassword => _getString('Forgot Password?', 'نسيت الباسورد؟');
  String get enterYourEmail =>
      _getString('Enter your email', 'دخل الإيميل بتاعك');
  String get enterYourPassword =>
      _getString('Enter your password', 'دخل الباسورد');
  String get enterYourName => _getString('Enter your name', 'دخل اسمك');
  String get enterYourPhone =>
      _getString('Enter your phone number', 'دخل رقم التليفون');
  String get confirmYourPassword =>
      _getString('Confirm your password', 'أكد الباسورد');
  String get signUpToGetStarted =>
      _getString('Sign up to get started', 'سجل عشان تبدأ');

  // ==================== Navigation ====================
  String get home => _getString('Home', 'الرئيسية');
  String get orders => _getString('Orders', 'الطلبات');
  String get profile => _getString('Profile', 'الملف الشخصي');
  String get cart => _getString('Cart', 'السلة');
  String get menu => _getString('Menu', 'القائمة');
  String get settings => _getString('Settings', 'الإعدادات');
  String get notifications => _getString('Notifications', 'الإشعارات');

  // ==================== Home Screen ====================
  String get helloGuest => _getString('Hello, Guest! 👋', 'أهلاً، ضيف! 👋');
  String helloUser(String name) =>
      _getString('Hello, $name! 👋', 'أهلاً، $name! 👋');
  String get whatWouldYouLikeToOrder =>
      _getString('What would you like to order?', 'عايز تطلب إيه؟');
  String get categories => _getString('Categories', 'الأقسام');
  String get featuredRestaurants =>
      _getString('Featured Restaurants', 'المطاعم المميزة');
  String get hotDeals => _getString('Hot Deals', 'عروض ساخنة');
  String get orderNow => _getString('Order Now', 'اطلب دلوقتي');
  String get specialOffer => _getString('Special Offer', 'عرض خاص');
  String get get50OffFirstOrder => _getString(
    'Get 50% off on your first order!',
    'احصل على خصم 50% على أول طلب!',
  );
  String get seeAll => _getString('See All', 'شوف الكل');
  String get viewCart => _getString('View Cart', 'شوف السلة');
  String get searchHint => _getString(
    'Search for restaurants or dishes...',
    'دور على مطاعم أو أكل...',
  );
  String get noRestaurantsFound =>
      _getString('No restaurants found', 'مفيش مطاعم');
  String get clearFilter => _getString('Clear Filter', 'شيل الفلتر');
  String get applyFilters => _getString('Apply Filters', 'طبق الفلاتر');
  String get filters => _getString('Filters', 'الفلاتر');
  String get sortBy => _getString('Sort By', 'ترتيب حسب');
  String get openRestaurantsOnly =>
      _getString('Open Restaurants Only', 'المطاعم المفتوحة فقط');

  // ==================== Restaurant ====================
  String get restaurantDetails =>
      _getString('Restaurant Details', 'تفاصيل المطعم');
  String get deliveryTime => _getString('Delivery Time', 'وقت التوصيل');
  String get minOrder => _getString('Min Order', 'أقل طلب');
  String get deliveryFee => _getString('Delivery Fee', 'مصاريف التوصيل');
  String get rating => _getString('Rating', 'التقييم');
  String get reviews => _getString('Reviews', 'التقييمات');
  String get featured => _getString('Featured', 'مميز');
  String get open => _getString('Open', 'مفتوح');
  String get openNow => _getString('Open Now', 'مفتوح دلوقتي');
  String get closed => _getString('Closed', 'مقفول');
  String get addToCart => _getString('Add to Cart', 'ضيف للسلة');
  String get outOfStock => _getString('Out of Stock', 'نفذ');
  String get itemAddedToCart => _getString('Added to cart', 'اتضاف للسلة');

  // ==================== Cart ====================
  String get yourCart => _getString('Your Cart', 'السلة بتاعتك');
  String get cartIsEmpty => _getString('Your cart is empty', 'السلة فاضية');
  String get items => _getString('items', 'حاجات');
  String get item => _getString('item', 'حاجة');
  String get clearCart => _getString('Clear Cart', 'فاضي السلة');
  String get proceedToCheckout =>
      _getString('Proceed to Checkout', 'روح للدفع');

  // ==================== Checkout ====================
  String get checkout => _getString('Checkout', 'الدفع');
  String get deliveryAddress => _getString('Delivery Address', 'عنوان التوصيل');
  String get paymentMethod => _getString('Payment Method', 'طريقة الدفع');
  String get cashOnDelivery =>
      _getString('Cash on Delivery', 'دفع عند الاستلام');
  String get creditCard => _getString('Credit Card', 'كارت');
  String get orderSummary => _getString('Order Summary', 'ملخص الطلب');
  String get subtotal => _getString('Subtotal', 'المجموع');
  String get tax => _getString('Tax', 'الضريبة');
  String get total => _getString('Total', 'الإجمالي');
  String get placeOrder => _getString('Place Order', 'أكد الطلب');
  String get couponDiscount => _getString('Coupon/Discount', 'كود خصم');
  String get enterCouponCode =>
      _getString('Enter coupon code', 'دخل كود الخصم');
  String get apply => _getString('Apply', 'طبق');
  String get couponApplied => _getString('Coupon Applied', 'الكود اتعمل');
  String get discount => _getString('Discount', 'خصم');
  String get orderNotes =>
      _getString('Order Notes (Optional)', 'ملاحظات (اختياري)');
  String get specialInstructions => _getString(
    'Special instructions for delivery...',
    'تعليمات خاصة للتوصيل...',
  );
  String get addNewAddress => _getString('Add New Address', 'ضيف عنوان جديد');
  String get selectAddress =>
      _getString('Please select an address', 'اختار عنوان');

  // ==================== Orders ====================
  String get myOrders => _getString('My Orders', 'طلباتي');
  String get noOrdersYet => _getString('No orders yet', 'مفيش طلبات لسه');
  String get orderHistory => _getString(
    'Your order history will appear here',
    'تاريخ الطلبات هيفضل هنا',
  );
  String get order => _getString('Order', 'طلب');
  String get viewOrder => _getString('View Order', 'شوف الطلب');
  String get trackOrder => _getString('Track Order', 'اتتبع الطلب');
  String get orderConfirmed => _getString('Order Confirmed!', 'الطلب اتعمل!');
  String get orderPlacedSuccessfully => _getString(
    'Your order has been placed successfully',
    'الطلب اتعمل بنجاح',
  );
  String get viewOrders => _getString('View Orders', 'شوف الطلبات');
  String get continueShopping => _getString('Continue Shopping', 'كمل تسوق');
  String get estimatedDelivery =>
      _getString('Estimated Delivery', 'وقت التوصيل المتوقع');
  String get orderDetails => _getString('Order Details', 'تفاصيل الطلب');
  String get orderStatus => _getString('Order Status', 'حالة الطلب');

  // ==================== Order Status ====================
  String get pending => _getString('Pending', 'قيد الانتظار');
  String get accepted => _getString('Accepted', 'مقبول');
  String get preparing => _getString('Preparing', 'بيتجهز');
  String get onTheWay => _getString('On the Way', 'في الطريق');
  String get delivered => _getString('Delivered', 'وصل');
  String get cancelled => _getString('Cancelled', 'اتلغى');
  String get rejected => _getString('Rejected', 'اترفض');

  // ==================== Profile ====================
  String get editProfile => _getString('Edit Profile', 'عدل البروفايل');
  String get addresses => _getString('Addresses', 'العناوين');
  String get paymentMethods => _getString('Payment Methods', 'طرق الدفع');
  String get helpSupport => _getString('Help & Support', 'المساعدة والدعم');
  String get about => _getString('About', 'عن التطبيق');
  String get privacyPolicy => _getString('Privacy Policy', 'سياسة الخصوصية');
  String get termsOfService => _getString('Terms of Service', 'شروط الاستخدام');

  // ==================== Address ====================
  String get myAddresses => _getString('My Addresses', 'عناويني');
  String get noAddressesYet =>
      _getString('No addresses yet', 'مفيش عناوين لسه');
  String get addFirstAddress =>
      _getString('Add your first delivery address', 'ضيف أول عنوان توصيل');
  String get addAddress => _getString('Add Address', 'ضيف عنوان');
  String get editAddress => _getString('Edit Address', 'عدل العنوان');
  String get addNewAddressTitle =>
      _getString('Add New Address', 'ضيف عنوان جديد');
  String get addressLine => _getString('Address Line', 'عنوان الشارع');
  String get city => _getString('City', 'المدينة');
  String get postalCode => _getString('Postal Code', 'الرمز البريدي');
  String get label => _getString('Label', 'الاسم');
  String get homeLabel => _getString('Home', 'البيت');
  String get work => _getString('Work', 'الشغل');
  String get other => _getString('Other', 'تاني');
  String get customLabel => _getString('Custom Label', 'اسم مخصص');
  String get setAsDefault =>
      _getString('Set as Default Address', 'خليه العنوان الافتراضي');
  String get useCurrentLocation =>
      _getString('Use Current Location', 'استخدم الموقع الحالي');
  String get selectLocation => _getString('Select Location', 'اختار الموقع');
  String get confirmLocation => _getString('Confirm Location', 'أكد الموقع');
  String get map => _getString('Map', 'الخريطة');
  String get yourLocation => _getString('Your Location', 'موقعك الحالي');
  String get driverLocation => _getString('Driver Location', 'موقع السائق');
  String get distance => _getString('Distance', 'المسافة');
  String get km => _getString('km', 'كم');
  String get defaultAddress => _getString('Default', 'افتراضي');
  String get deleteAddress => _getString('Delete Address', 'احذف العنوان');
  String get deleteAddressConfirm => _getString(
    'Are you sure you want to delete this address?',
    'متأكد إنك عايز تحذف العنوان ده؟',
  );
  String get addressDeleted =>
      _getString('Address deleted successfully', 'العنوان اتحذف');
  String get addressAdded =>
      _getString('Address added successfully!', 'العنوان اتعمل!');

  // ==================== Payment Methods ====================
  String get addPaymentMethod =>
      _getString('Add Payment Method', 'إضافة طريقة دفع');
  String get cardNumber => _getString('Card Number', 'رقم البطاقة');
  String get cardHolderName =>
      _getString('Card Holder Name', 'اسم حامل البطاقة');
  String get expiryDate => _getString('Expiry Date', 'تاريخ الانتهاء');
  String get cvv => _getString('CVV', 'رمز الأمان');
  String get saveCard => _getString(
    'Save this card for future use',
    'حفظ هذه البطاقة للاستخدام المستقبلي',
  );
  String get addCard => _getString('Add Card', 'إضافة بطاقة');
  String get paymentInfoSecure => _getString(
    'Your payment information is encrypted and secure',
    'معلومات الدفع مشفرة وآمنة',
  );

  // ==================== Settings ====================
  String get language => _getString('Language', 'اللغة');
  String get selectLanguage => _getString('Select Language', 'اختار اللغة');
  String get english => _getString('English', 'إنجليزي');
  String get arabic => _getString('Arabic', 'عربي');
  String get pushNotifications => _getString('Push Notifications', 'الإشعارات');
  String get receiveOrderUpdates => _getString(
    'Receive order updates and promotions',
    'استقبل تحديثات الطلبات والعروض',
  );
  String get locationServices =>
      _getString('Location Services', 'خدمات الموقع');
  String get allowLocationAccess => _getString(
    'Allow location access for better experience',
    'اسمح بالوصول للموقع عشان تجربة أحسن',
  );
  // ==================== Onboarding ====================
  String get skip => _getString('Skip', 'تخطى');
  String get next => _getString('Next', 'التالي');
  String get getStarted => _getString('Get Started', 'ابدأ دلوقتي');

  // ==================== Errors ====================
  String get errorOccurred => _getString('An error occurred', 'حصل خطأ');
  String get tryAgain => _getString('Try Again', 'حاول تاني');
  String get failedToLoad => _getString('Failed to load', 'فشل التحميل');
  String get somethingWentWrong =>
      _getString('Something went wrong', 'حصل حاجة غلط');
  String get pleaseLoginFirst =>
      _getString('Please login first', 'سجل دخول الأول');
  String get browseAsGuest =>
      _getString('Browse as Guest', 'تصفح كضيف');
  String get continueAsGuest =>
      _getString('Continue as Guest', 'كمل كضيف');
  String get pleaseRegisterToCheckout =>
      _getString('Please register to complete your order', 'سجل عشان تكمل طلبك');
  String get loginOrRegisterToCheckout =>
      _getString('Login or Register to checkout', 'سجل دخول أو اعمل حساب عشان تطلب');
  String get youMustLoginToCheckout =>
      _getString('You must login or register to complete your order', 'لازم تسجل أو تعمل حساب عشان تكمل طلبك');
  String get restaurantNotFound =>
      _getString('Restaurant not found', 'المطعم مش موجود');
  String get orderNotFound => _getString('Order not found', 'الطلب مش موجود');
  String get locationTrackingStarted =>
      _getString('Location tracking started', 'تم تفعيل تتبع الموقع');
  String get locationTrackingStopped =>
      _getString('Location tracking stopped', 'تم إيقاف تتبع الموقع');
  String get locationPermissionRequired => _getString(
    'Location permission is required to go online',
    'السماح بالموقع مطلوب لتكون متاح',
  );
  String get failedToStartLocationTracking =>
      _getString('Failed to start location tracking', 'فشل تفعيل تتبع الموقع');
  String get failedToPlaceOrder =>
      _getString('Failed to place order', 'فشل الطلب');
  String get couponAppliedSuccessfully =>
      _getString('Coupon applied successfully!', 'الكود اتعمل!');
  String get exitApp => _getString('Exit App', 'إغلاق التطبيق');
  String get exitAppConfirm => _getString(
    'Are you sure you want to exit?',
    'متأكد إنك عايز تخرج من التطبيق؟',
  );
  String get exit => _getString('Exit', 'خرج');

  // ==================== Success Messages ====================
  String get orderPlacedSuccess =>
      _getString('Order placed successfully!', 'الطلب اتعمل بنجاح!');
  String get profileUpdated =>
      _getString('Profile updated successfully', 'البروفايل اتحدث');
  String get changesSaved => _getString('Changes saved', 'التغييرات اتحفظت');
  String get imagePickerComingSoon =>
      _getString('Image picker will be implemented', 'منتقي الصور هيتعمل قريب');
  String get paymentMethodAdded =>
      _getString('Payment method added successfully!', 'طريقة الدفع اتعملت!');
  String get setDefaultComingSoon => _getString(
    'Set default feature coming soon',
    'ميزة تعيين الافتراضي هتجيلك قريب',
  );
  String get privacyPolicyComingSoon =>
      _getString('Privacy Policy coming soon', 'سياسة الخصوصية هتجيلك قريب');
  String get termsComingSoon =>
      _getString('Terms of Service coming soon', 'شروط الاستخدام هتجيلك قريب');
  String get version => _getString('Version 1.0.0', 'الإصدار 1.0.0');
  String get versionLabel => _getString('Version', 'الإصدار');

  // ==================== Additional UI Strings ====================
  String get goBack => _getString('Go Back', 'ارجع');
  String get clear => _getString('Clear', 'مسح');
  String get reset => _getString('Reset', 'إعادة تعيين');
  String get noMenuItemsAvailable =>
      _getString('No menu items available', 'مفيش أكل متاح');
  String get failedToLoadMenu =>
      _getString('Failed to load menu', 'فشل تحميل القائمة');
  String get failedToLoadAddresses =>
      _getString('Failed to load addresses', 'فشل تحميل العناوين');
  String get failedToLoadOrder =>
      _getString('Failed to load order', 'فشل تحميل الطلب');
  String get failedToGetLocation =>
      _getString('Failed to get location', 'فشل الحصول على الموقع');
  String get failedToOpenLocationPicker =>
      _getString('Failed to open location picker', 'فشل فتح منتقي الموقع');
  String get useThisAddressByDefault => _getString(
    'Use this address by default for deliveries',
    'استخدم العنوان ده افتراضياً للتوصيل',
  );
  String get payWhenYouReceive =>
      _getString('Pay when you receive your order', 'ادفع لما تستلم الطلب');
  String get orderItems => _getString('Order Items', 'الأكل المطلوب');
  String get delivery => _getString('Delivery', 'التوصيل');
  String get min => _getString('min', 'دقيقة');
  String get orderNumber => _getString('Order #', 'طلب رقم #');

  // ==================== Driver ====================
  String get availableOrders =>
      _getString('Available Orders', 'الطلبات المتاحة');
  String get noOrdersAvailable =>
      _getString('No orders available', 'مفيش طلبات متاحة');
  String get failedToLoadOrders =>
      _getString('Failed to load orders', 'فشل تحميل الطلبات');
  String get acceptOrder => _getString('Accept Order', 'قبول الطلب');
  String get rejectOrder => _getString('Reject Order', 'رفض الطلب');
  String get activeOrders => _getString('Active Orders', 'الطلبات النشطة');
  String get driverOrderHistory => _getString('Order History', 'سجل الطلبات');
  String get earnings => _getString('Earnings', 'الأرباح');
  String get todaysEarnings => _getString("Today's Earnings", 'أرباح النهاردة');
  String get totalDeliveries =>
      _getString('Total Deliveries', 'إجمالي التوصيلات');
  String get startAcceptingOrders =>
      _getString('Start Accepting Orders', 'ابدأ استقبال الطلبات');
  String get stopAcceptingOrders =>
      _getString('Stop Accepting Orders', 'اوقف استقبال الطلبات');
  String get online => _getString('Online', 'متصل');
  String get offline => _getString('Offline', 'غير متصل');
  String get navigateToRestaurant =>
      _getString('Navigate to Restaurant', 'روح للمطعم');
  String get navigateToCustomer =>
      _getString('Navigate to Customer', 'روح للعميل');
  String get markAsPickedUp => _getString('Mark as Picked Up', 'تم الاستلام');
  String get markAsDelivered => _getString('Mark as Delivered', 'تم التسليم');
  String get pickupFrom => _getString('Pickup from', 'استلم من');
  String get deliverTo => _getString('Deliver to', 'سلم لـ');
  String get deliveryRequests =>
      _getString('Delivery Requests', 'طلبات التوصيل');
  String get viewAvailableOrders =>
      _getString('View available orders', 'شوف الطلبات المتاحة');
  String get trackDeliveries =>
      _getString('Track deliveries', 'تتبع التوصيلات');
  String get pastDeliveries =>
      _getString('Past deliveries', 'التوصيلات السابقة');
  String get viewEarnings => _getString('View earnings', 'شوف الأرباح');
  String get quickActions => _getString('Quick Actions', 'إجراءات سريعة');
  String get youAreOnlineAndReady => _getString(
    'You are online and ready to accept orders',
    'أنت متصل وجاهز لاستقبال الطلبات',
  );
  String get turnOnToStartReceiving => _getString(
    'Turn on to start receiving delivery requests',
    'شغّل عشان تبدأ تستقبل طلبات التوصيل',
  );
  String get noActiveOrders =>
      _getString('No active orders', 'مفيش طلبات نشطة');

  // ==================== Restaurant ====================
  String get dashboard => _getString('Dashboard', 'لوحة التحكم');
  String get todaysOrders => _getString("Today's Orders", 'طلبات النهاردة');
  String get todaysRevenue => _getString("Today's Revenue", 'إيرادات النهاردة');
  String get pendingOrders => _getString('Pending Orders', 'الطلبات المعلقة');
  String get activeOrdersCount => _getString('Active Orders', 'الطلبات النشطة');
  String get restaurantIsOpen =>
      _getString('Restaurant is Open', 'المطعم مفتوح');
  String get restaurantIsClosed =>
      _getString('Restaurant is Closed', 'المطعم مغلق');
  String get restaurantIsOnline =>
      _getString('Restaurant is now online', 'المطعم متصل الآن');
  String get restaurantIsOffline =>
      _getString('Restaurant is now offline', 'المطعم غير متصل الآن');
  String get manageMenu => _getString('Manage Menu', 'إدارة القائمة');
  String get viewAnalytics => _getString('View Analytics', 'عرض التحليلات');
  String get recentOrders => _getString('Recent Orders', 'الطلبات الأخيرة');
  String get startPreparing => _getString('Start Preparing', 'ابدأ التحضير');
  String get markAsReady => _getString('Mark as Ready', 'اعلم إنه جاهز');
  String get cancelOrder => _getString('Cancel Order', 'إلغاء الطلب');
  String get restaurantOrders =>
      _getString('Restaurant Orders', 'طلبات المطعم');
  String get noRestaurantOrders =>
      _getString('No orders yet', 'مفيش طلبات لسه');
  String get orderAcceptedSuccess =>
      _getString('Order accepted successfully', 'تم قبول الطلب بنجاح');
  String get orderStatusUpdated =>
      _getString('Order status updated', 'تم تحديث حالة الطلب');
  String get orderDelivered =>
      _getString('Order Delivered', 'تم تسليم الطلب');
  String get openRestaurant => _getString('Open Restaurant', 'افتح المطعم');
  String get closeRestaurant => _getString('Close Restaurant', 'اقفل المطعم');
  String get all => _getString('All', 'الكل');
  String get ready => _getString('Ready', 'جاهز');
  String get addCategory => _getString('Add Category', 'أضف فئة');
  String get editCategory => _getString('Edit Category', 'تعديل الفئة');
  String get deleteCategory => _getString('Delete Category', 'حذف الفئة');
  String get categoryName => _getString('Category Name', 'اسم الفئة');
  String get categoryNameRequired =>
      _getString('Category name is required', 'اسم الفئة مطلوب');
  String get categoryAddedSuccessfully =>
      _getString('Category added successfully', 'تمت إضافة الفئة بنجاح');
  String get categoryUpdatedSuccessfully =>
      _getString('Category updated successfully', 'تم تحديث الفئة بنجاح');
  String get categoryDeletedSuccessfully =>
      _getString('Category deleted successfully', 'تم حذف الفئة بنجاح');
  String get deleteCategoryConfirm => _getString(
    'Are you sure you want to delete this category? All items in this category will also be deleted.',
    'هل أنت متأكد من حذف هذه الفئة؟ جميع العناصر في هذه الفئة سيتم حذفها أيضاً',
  );
  String get noCategories => _getString('No categories', 'مفيش فئات');
  String get addFirstCategory => _getString(
    'Add your first category to start managing your menu',
    'أضف أول فئة لإدارة القائمة',
  );
  String get addItem => _getString('Add Item', 'أضف عنصر');
  String get editItem => _getString('Edit Item', 'تعديل العنصر');
  String get deleteItem => _getString('Delete Item', 'حذف العنصر');
  String get itemName => _getString('Item Name', 'اسم العنصر');
  String get itemNameRequired =>
      _getString('Item name is required', 'اسم العنصر مطلوب');
  String get priceRequired => _getString('Price is required', 'السعر مطلوب');
  String get invalidPrice => _getString('Invalid price', 'سعر غير صحيح');
  String get itemAddedSuccessfully =>
      _getString('Item added successfully', 'تمت إضافة العنصر بنجاح');
  String get itemUpdatedSuccessfully =>
      _getString('Item updated successfully', 'تم تحديث العنصر بنجاح');
  String get itemDeletedSuccessfully =>
      _getString('Item deleted successfully', 'تم حذف العنصر بنجاح');
  String get deleteItemConfirm => _getString(
    'Are you sure you want to delete this item?',
    'هل أنت متأكد من حذف هذا العنصر؟',
  );
  String get noItemsInCategory =>
      _getString('No items in this category', 'مفيش عناصر في هذه الفئة');
  String get markAvailable => _getString('Mark as Available', 'اعلم إنه متاح');
  String get markUnavailable =>
      _getString('Mark as Unavailable', 'اعلم إنه غير متاح');
  String get unavailable => _getString('Unavailable', 'غير متاح');
  String get add => _getString('Add', 'أضف');
  String get available => _getString('Available', 'متاح');
  String get description => _getString('Description', 'الوصف');
  String get descriptionRequired =>
      _getString('Description is required', 'الوصف مطلوب');
  String get price => _getString('Price', 'السعر');
  String get imageUrl => _getString('Image URL', 'رابط الصورة');

  // ==================== Restaurant Profile ====================
  String get restaurantProfile =>
      _getString('Restaurant Profile', 'معلومات المطعم');
  String get editRestaurantInfo =>
      _getString('Edit Restaurant Info', 'تعديل معلومات المطعم');
  String get restaurantName => _getString('Restaurant Name', 'اسم المطعم');
  String get restaurantDescriptionDetail =>
      _getString('Restaurant Description', 'وصف المطعم');
  String get deliveryTimeMinutes =>
      _getString('Delivery Time (minutes)', 'وقت التوصيل (بالدقائق)');
  String get deliveryFeeAmount => _getString('Delivery Fee', 'رسوم التوصيل');
  String get minimumOrderAmount =>
      _getString('Minimum Order Amount', 'أقل قيمة طلب');
  String get restaurantAddress =>
      _getString('Restaurant Address', 'عنوان المطعم');
  String get restaurantInfoUpdated => _getString(
    'Restaurant info updated successfully',
    'تم تحديث معلومات المطعم بنجاح',
  );
  String get restaurantNameRequired =>
      _getString('Restaurant name is required', 'اسم المطعم مطلوب');
  String get restaurantDescriptionRequired =>
      _getString('Restaurant description is required', 'وصف المطعم مطلوب');
  String get isRequired => _getString('is required', 'مطلوب');
  String get changeRestaurantImage =>
      _getString('Change Restaurant Image', 'تغيير صورة المطعم');
  String get updateRestaurantInfo =>
      _getString('Update Restaurant Info', 'تحديث معلومات المطعم');
  String get restaurantSettings =>
      _getString('Restaurant Settings', 'إعدادات المطعم');
  String get minutes => _getString('minutes', 'دقيقة');
  String get restaurantInfo => _getString('Restaurant Info', 'معلومات المطعم');
  String get enableNotifications =>
      _getString('Enable Notifications', 'تفعيل الإشعارات');
  String get support => _getString('Support', 'الدعم');
  String get legal => _getString('Legal', 'قانوني');
  String get aboutUs => _getString('About Us', 'من نحن');
  String get contactSupport => _getString('Contact Support', 'اتصل بالدعم');
  String get termsAndConditions =>
      _getString('Terms and Conditions', 'الشروط والأحكام');

  // ==================== Analytics ====================
  String get today => _getString('Today', 'اليوم');
  String get week => _getString('Week', 'الأسبوع');
  String get month => _getString('Month', 'الشهر');
  String get totalOrders => _getString('Total Orders', 'إجمالي الطلبات');
  String get totalRevenue => _getString('Total Revenue', 'إجمالي الإيرادات');
  String get averageOrderValue =>
      _getString('Average Order Value', 'متوسط قيمة الطلب');
  String get perOrder => _getString('per order', 'لكل طلب');
  String get weeklyOrders => _getString('Weekly Orders', 'طلبات الأسبوع');
  String get weeklyRevenue => _getString('Weekly Revenue', 'إيرادات الأسبوع');
  String get monthlyOrders => _getString('Monthly Orders', 'طلبات الشهر');
  String get monthlyRevenue => _getString('Monthly Revenue', 'إيرادات الشهر');
  String get newOrderReceived => _getString('New order received!', 'طلب جديد!');
  String get newNotification => _getString('New notification', 'إشعار جديد');
  String get view => _getString('View', 'عرض');
  String get viewAll => _getString('View All', 'عرض الكل');

  // ==================== Onboarding ====================
  String get orderYourFavoriteFood =>
      _getString('Order Your Favorite Food', 'اطلب أكلك المفضل');
  String get orderYourFavoriteFoodDescription => _getString(
    'Order from a wide range of restaurants and cuisines.',
    'اطلب من مجموعة كبيرة من المطاعم والأكلات.',
  );
  String get fastDelivery => _getString('Fast Delivery', 'توصيل سريع');
  String get fastDeliveryDescription => _getString(
    'Get your food delivered quickly and efficiently to your doorstep.',
    'أكلك هيوصلك بسرعة وكفاءة لحد باب بيتك.',
  );
  String get easyPayment => _getString('Easy Payment', 'دفع سهل');
  String get easyPaymentDescription => _getString(
    'Pay with various secure payment options, including cash on delivery.',
    'ادفع بطرق دفع آمنة ومختلفة، بما في ذلك الدفع عند الاستلام.',
  );
  String get autoAcceptOrders =>
      _getString('Auto Accept Orders', 'قبول الطلبات تلقائياً');
  String get autoAcceptOrdersDescription => _getString(
    'Automatically accept new orders after 30 seconds when restaurant is open',
    'قبول الطلبات الجديدة تلقائياً بعد 30 ثانية عندما يكون المطعم مفتوح',
  );
  String get orderWillBeAcceptedIn =>
      _getString('Order will be accepted in', 'سيتم قبول الطلب خلال');
  String get seconds => _getString('seconds', 'ثانية');
  String get autoAcceptedOrder =>
      _getString('Order automatically accepted', 'تم قبول الطلب تلقائياً');
  String get ratingsAndReviews =>
      _getString('Ratings & Reviews', 'التقييمات والمراجعات');
  String get writeAReview => _getString('Write a Review', 'اكتب تقييم');
  String get rateYourOrder => _getString('Rate Your Order', 'قيم طلبك');
  String get howWasYourOrder =>
      _getString('How was your order?', 'كيف كانت تجربتك؟');
  String get rateRestaurant => _getString('Rate Restaurant', 'قيم المطعم');
  String get yourRating => _getString('Your Rating', 'تقييمك');
  String get writeReview => _getString('Write Review', 'اكتب مراجعة');
  String get optional => _getString('Optional', 'اختياري');
  String get submitReview => _getString('Submit Review', 'إرسال التقييم');
  String get thankYouForReview =>
      _getString('Thank you for your review!', 'شكراً لك على تقييمك!');
  String get reviewSubmittedSuccessfully =>
      _getString('Review submitted successfully', 'تم إرسال التقييم بنجاح');
  String get reviewText => _getString('Review Text', 'نص المراجعة');
  String get addPhotos => _getString('Add Photos', 'أضف صور');
  String get allReviews => _getString('All Reviews', 'جميع المراجعات');
  String get noReviewsYet =>
      _getString('No reviews yet', 'لا توجد مراجعات بعد');
  String get beTheFirstToReview =>
      _getString('Be the first to review!', 'كن أول من يقيم!');
  String get review => _getString('Review', 'مراجعة');
  String get averageRating => _getString('Average Rating', 'متوسط التقييم');
  String get totalReviews => _getString('Total Reviews', 'إجمالي المراجعات');
  String get filterByRating =>
      _getString('Filter by Rating', 'فلترة حسب التقييم');
  String get sortReviews => _getString('Sort Reviews', 'ترتيب المراجعات');
  String get newestFirst => _getString('Newest First', 'الأحدث أولاً');
  String get oldestFirst => _getString('Oldest First', 'الأقدم أولاً');
  String get highestRated => _getString('Highest Rated', 'الأعلى تقييماً');
  String get lowestRated => _getString('Lowest Rated', 'الأقل تقييماً');
  String get helpful => _getString('Helpful', 'مفيد');
  String get report => _getString('Report', 'بلّغ');
  String get editReview => _getString('Edit Review', 'تعديل المراجعة');
  String get deleteReview => _getString('Delete Review', 'حذف المراجعة');
  String get pleaseSelectRating =>
      _getString('Please select a rating', 'الرجاء اختيار تقييم');
  String get favorites => _getString('Favorites', 'المفضلة');
  String get favoriteRestaurants =>
      _getString('Favorite Restaurants', 'المطاعم المفضلة');
  String get noFavoritesYet =>
      _getString('No favorites yet', 'لا توجد مطاعم مفضلة بعد');
  String get addToFavorites => _getString('Add to Favorites', 'أضف للمفضلة');
  String get removeFromFavorites =>
      _getString('Remove from Favorites', 'إزالة من المفضلة');
  String get addedToFavorites =>
      _getString('Added to favorites', 'تمت الإضافة للمفضلة');
  String get removedFromFavorites =>
      _getString('Removed from favorites', 'تمت الإزالة من المفضلة');
  String get noHotDeals => _getString('No Hot Deals', 'لا توجد عروض ساخنة');
  String get restaurantNotActive =>
      _getString('Restaurant Not Active', 'المطعم غير نشط حالياً');
  String get restaurantWillBeActiveSoon =>
      _getString('This restaurant is currently offline. It will be active soon.',
          'المطعم غير نشط حالياً. سيكون نشط قريباً');
  String get restaurantClosedMessage =>
      _getString('This restaurant is closed and will not accept orders at this time. We will be back soon.',
          'هذا المطعم مغلق ولن يستقبل طلبات حالياً. سنعود قريباً');
  String get appearance => _getString('Appearance', 'المظهر');
  String get lightMode => _getString('Light Mode', 'الوضع الفاتح');
  String get darkMode => _getString('Dark Mode', 'الوضع الداكن');
  String get systemDefault => _getString('System Default', 'افتراضي النظام');
  String get noInternetConnection =>
      _getString('No Internet Connection', 'لا يوجد اتصال بالإنترنت');
  String get retry => _getString('Retry', 'إعادة المحاولة');
  String get offlineMode => _getString('Offline Mode', 'الوضع غير المتصل');
  String get youAreOffline => _getString('You are offline', 'أنت غير متصل');
  String get checkYourConnection =>
      _getString('Check your internet connection', 'تحقق من اتصالك بالإنترنت');

  // Static method to get instance
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}

/// Extension to easily access localization
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
