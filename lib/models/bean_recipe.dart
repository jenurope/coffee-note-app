class BeanRecipe {
  final String id;
  final String userId;
  final String name;
  final String brewMethod;
  final String recipe;
  final DateTime createdAt;
  final DateTime updatedAt;

  BeanRecipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.brewMethod,
    required this.recipe,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BeanRecipe.fromJson(Map<String, dynamic> json) {
    return BeanRecipe(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      brewMethod: json['brew_method'] as String,
      recipe: json['recipe'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'brew_method': brewMethod,
      'recipe': recipe,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'brew_method': brewMethod,
      'recipe': recipe,
    };
  }

  BeanRecipe copyWith({
    String? id,
    String? userId,
    String? name,
    String? brewMethod,
    String? recipe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BeanRecipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      brewMethod: brewMethod ?? this.brewMethod,
      recipe: recipe ?? this.recipe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
