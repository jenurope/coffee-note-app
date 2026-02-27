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
  final String? brewMethod;
  final String? recipe;
  final int? price;
  final String? purchaseLocation;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoffeeBean({
    required this.id,
    required this.userId,
    required this.name,
    required this.roastery,
    required this.purchaseDate,
    required this.rating,
    this.tastingNotes,
    this.roastLevel,
    this.brewMethod,
    this.recipe,
    this.price,
    this.purchaseLocation,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
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
      brewMethod: json['brew_method'] as String?,
      recipe: json['recipe'] as String?,
      price: json['price'] as int?,
      purchaseLocation: json['purchase_location'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'brew_method': brewMethod,
      'recipe': recipe,
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
      'brew_method': brewMethod,
      'recipe': recipe,
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
    String? brewMethod,
    String? recipe,
    int? price,
    String? purchaseLocation,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      brewMethod: brewMethod ?? this.brewMethod,
      recipe: recipe ?? this.recipe,
      price: price ?? this.price,
      purchaseLocation: purchaseLocation ?? this.purchaseLocation,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const List<String> roastLevels = RoastLevelCatalog.codes;
}
