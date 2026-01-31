class BeanDetail {
  final String id;
  final String coffeeBeanId;
  final String origin;
  final String? variety;
  final String? process;
  final int? ratio;
  final DateTime createdAt;

  BeanDetail({
    required this.id,
    required this.coffeeBeanId,
    required this.origin,
    this.variety,
    this.process,
    this.ratio,
    required this.createdAt,
  });

  factory BeanDetail.fromJson(Map<String, dynamic> json) {
    return BeanDetail(
      id: json['id'] as String,
      coffeeBeanId: json['coffee_bean_id'] as String,
      origin: json['origin'] as String,
      variety: json['variety'] as String?,
      process: json['process'] as String?,
      ratio: json['ratio'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coffee_bean_id': coffeeBeanId,
      'origin': origin,
      'variety': variety,
      'process': process,
      'ratio': ratio,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'coffee_bean_id': coffeeBeanId,
      'origin': origin,
      'variety': variety,
      'process': process,
      'ratio': ratio,
    };
  }

  BeanDetail copyWith({
    String? id,
    String? coffeeBeanId,
    String? origin,
    String? variety,
    String? process,
    int? ratio,
    DateTime? createdAt,
  }) {
    return BeanDetail(
      id: id ?? this.id,
      coffeeBeanId: coffeeBeanId ?? this.coffeeBeanId,
      origin: origin ?? this.origin,
      variety: variety ?? this.variety,
      process: process ?? this.process,
      ratio: ratio ?? this.ratio,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
