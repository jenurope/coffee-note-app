class UserProfile {
  final String id;
  final String nickname;
  final String? email;
  final String? avatarUrl;
  final bool isWithdrawn;
  final bool isBeanRecordsEnabled;
  final bool isCoffeeRecordsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.nickname,
    this.email,
    this.avatarUrl,
    this.isWithdrawn = false,
    this.isBeanRecordsEnabled = true,
    this.isCoffeeRecordsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isWithdrawn: json['is_withdrawn'] as bool? ?? false,
      isBeanRecordsEnabled: json['is_bean_records_enabled'] as bool? ?? true,
      isCoffeeRecordsEnabled:
          json['is_coffee_records_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'email': email,
      'avatar_url': avatarUrl,
      'is_withdrawn': isWithdrawn,
      'is_bean_records_enabled': isBeanRecordsEnabled,
      'is_coffee_records_enabled': isCoffeeRecordsEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? nickname,
    String? email,
    String? avatarUrl,
    bool? isWithdrawn,
    bool? isBeanRecordsEnabled,
    bool? isCoffeeRecordsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isWithdrawn: isWithdrawn ?? this.isWithdrawn,
      isBeanRecordsEnabled: isBeanRecordsEnabled ?? this.isBeanRecordsEnabled,
      isCoffeeRecordsEnabled:
          isCoffeeRecordsEnabled ?? this.isCoffeeRecordsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
