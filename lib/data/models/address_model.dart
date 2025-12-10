/// Address model for user delivery addresses
class AddressModel {
  final String id;
  final String userId;
  final String label; // Home, Work, etc.
  final String addressLine;
  final String city;
  final String? postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.addressLine,
    required this.city,
    this.postalCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  /// Full address string
  String get fullAddress {
    return '$addressLine, $city${postalCode != null ? ', $postalCode' : ''}';
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String,
      addressLine: json['address_line'] as String,
      city: json['city'] as String,
      postalCode: json['postal_code'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'address_line': addressLine,
      'city': city,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  /// Create a copy with updated fields
  AddressModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? addressLine,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

