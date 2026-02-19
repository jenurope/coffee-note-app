import 'bean_detail.dart';
import 'brew_detail.dart';
import '../domain/catalogs/roast_level_catalog.dart';

class CoffeeBean {
  final String id;
  final String userId;
  final String name;
  final String roastery;
  final DateTime purchaseDate;
  final double rating;
  final String? tastingNotes;
  final String? roastLevel;
  final int? price;
  final String? purchaseLocation;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 관계 데이터
  final List<BeanDetail>? beanDetails;
  final List<BrewDetail>? brewDetails;

  CoffeeBean({
    required this.id,
    required this.userId,
    required this.name,
    required this.roastery,
    required this.purchaseDate,
    required this.rating,
    this.tastingNotes,
    this.roastLevel,
    this.price,
    this.purchaseLocation,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.beanDetails,
    this.brewDetails,
  });

  factory CoffeeBean.fromJson(Map<String, dynamic> json) {
    return CoffeeBean(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      roastery: json['roastery'] as String,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      rating: (json['rating'] as num).toDouble(),
      tastingNotes: json['tasting_notes'] as String?,
      roastLevel: json['roast_level'] as String?,
      price: json['price'] as int?,
      purchaseLocation: json['purchase_location'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      beanDetails: json['bean_details'] != null
          ? (json['bean_details'] as List)
                .map((e) => BeanDetail.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      brewDetails: json['brew_details'] != null
          ? (json['brew_details'] as List)
                .map((e) => BrewDetail.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'roastery': roastery,
      'purchase_date': purchaseDate.toIso8601String().split('T').first,
      'rating': rating,
      'tasting_notes': tastingNotes,
      'roast_level': roastLevel,
      'price': price,
      'purchase_location': purchaseLocation,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'roastery': roastery,
      'purchase_date': purchaseDate.toIso8601String().split('T').first,
      'rating': rating,
      'tasting_notes': tastingNotes,
      'roast_level': roastLevel,
      'price': price,
      'purchase_location': purchaseLocation,
      'image_url': imageUrl,
    };
  }

  CoffeeBean copyWith({
    String? id,
    String? userId,
    String? name,
    String? roastery,
    DateTime? purchaseDate,
    double? rating,
    String? tastingNotes,
    String? roastLevel,
    int? price,
    String? purchaseLocation,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BeanDetail>? beanDetails,
    List<BrewDetail>? brewDetails,
  }) {
    return CoffeeBean(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      roastery: roastery ?? this.roastery,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      rating: rating ?? this.rating,
      tastingNotes: tastingNotes ?? this.tastingNotes,
      roastLevel: roastLevel ?? this.roastLevel,
      price: price ?? this.price,
      purchaseLocation: purchaseLocation ?? this.purchaseLocation,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      beanDetails: beanDetails ?? this.beanDetails,
      brewDetails: brewDetails ?? this.brewDetails,
    );
  }

  static const List<String> roastLevels = RoastLevelCatalog.codes;
}
