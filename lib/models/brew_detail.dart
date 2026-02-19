import '../domain/catalogs/brew_method_catalog.dart';
import '../domain/catalogs/grind_size_catalog.dart';

class BrewDetail {
  final String id;
  final String coffeeBeanId;
  final DateTime brewDate;
  final String? brewMethod;
  final String? grindSize;
  final String? brewTime;
  final int? waterTemperature;
  final String? pairedFood;
  final String? brewNotes;
  final DateTime createdAt;

  BrewDetail({
    required this.id,
    required this.coffeeBeanId,
    required this.brewDate,
    this.brewMethod,
    this.grindSize,
    this.brewTime,
    this.waterTemperature,
    this.pairedFood,
    this.brewNotes,
    required this.createdAt,
  });

  factory BrewDetail.fromJson(Map<String, dynamic> json) {
    return BrewDetail(
      id: json['id'] as String,
      coffeeBeanId: json['coffee_bean_id'] as String,
      brewDate: DateTime.parse(json['brew_date'] as String),
      brewMethod: json['brew_method'] as String?,
      grindSize: json['grind_size'] as String?,
      brewTime: json['brew_time'] as String?,
      waterTemperature: json['water_temperature'] as int?,
      pairedFood: json['paired_food'] as String?,
      brewNotes: json['brew_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coffee_bean_id': coffeeBeanId,
      'brew_date': brewDate.toIso8601String().split('T').first,
      'brew_method': brewMethod,
      'grind_size': grindSize,
      'brew_time': brewTime,
      'water_temperature': waterTemperature,
      'paired_food': pairedFood,
      'brew_notes': brewNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'coffee_bean_id': coffeeBeanId,
      'brew_date': brewDate.toIso8601String().split('T').first,
      'brew_method': brewMethod,
      'grind_size': grindSize,
      'brew_time': brewTime,
      'water_temperature': waterTemperature,
      'paired_food': pairedFood,
      'brew_notes': brewNotes,
    };
  }

  BrewDetail copyWith({
    String? id,
    String? coffeeBeanId,
    DateTime? brewDate,
    String? brewMethod,
    String? grindSize,
    String? brewTime,
    int? waterTemperature,
    String? pairedFood,
    String? brewNotes,
    DateTime? createdAt,
  }) {
    return BrewDetail(
      id: id ?? this.id,
      coffeeBeanId: coffeeBeanId ?? this.coffeeBeanId,
      brewDate: brewDate ?? this.brewDate,
      brewMethod: brewMethod ?? this.brewMethod,
      grindSize: grindSize ?? this.grindSize,
      brewTime: brewTime ?? this.brewTime,
      waterTemperature: waterTemperature ?? this.waterTemperature,
      pairedFood: pairedFood ?? this.pairedFood,
      brewNotes: brewNotes ?? this.brewNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static const List<String> brewMethods = BrewMethodCatalog.codes;

  static const List<String> grindSizes = GrindSizeCatalog.codes;
}
