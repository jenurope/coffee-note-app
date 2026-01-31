class CoffeeLog {
  final String id;
  final String userId;
  final DateTime cafeVisitDate;
  final String coffeeType;
  final String? coffeeName;
  final String cafeName;
  final double rating;
  final String? notes;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoffeeLog({
    required this.id,
    required this.userId,
    required this.cafeVisitDate,
    required this.coffeeType,
    this.coffeeName,
    required this.cafeName,
    required this.rating,
    this.notes,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoffeeLog.fromJson(Map<String, dynamic> json) {
    return CoffeeLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cafeVisitDate: DateTime.parse(json['cafe_visit_date'] as String),
      coffeeType: json['coffee_type'] as String,
      coffeeName: json['coffee_name'] as String?,
      cafeName: json['cafe_name'] as String,
      rating: (json['rating'] as num).toDouble(),
      notes: json['notes'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cafe_visit_date': cafeVisitDate.toIso8601String().split('T').first,
      'coffee_type': coffeeType,
      'coffee_name': coffeeName,
      'cafe_name': cafeName,
      'rating': rating,
      'notes': notes,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'cafe_visit_date': cafeVisitDate.toIso8601String().split('T').first,
      'coffee_type': coffeeType,
      'coffee_name': coffeeName,
      'cafe_name': cafeName,
      'rating': rating,
      'notes': notes,
      'image_url': imageUrl,
    };
  }

  CoffeeLog copyWith({
    String? id,
    String? userId,
    DateTime? cafeVisitDate,
    String? coffeeType,
    String? coffeeName,
    String? cafeName,
    double? rating,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CoffeeLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cafeVisitDate: cafeVisitDate ?? this.cafeVisitDate,
      coffeeType: coffeeType ?? this.coffeeType,
      coffeeName: coffeeName ?? this.coffeeName,
      cafeName: cafeName ?? this.cafeName,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const List<String> coffeeTypes = [
    '에스프레소',
    '아메리카노',
    '라떼',
    '카푸치노',
    '모카',
    '마끼아또',
    '플랫화이트',
    '콜드브루',
    '아포가토',
    '기타',
  ];
}
