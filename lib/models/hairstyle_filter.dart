import 'package:flutter/material.dart';

/// Represents a hairstyle filter for AR camera
class HairstyleFilter {
  final String id;
  final String name;
  final String description;
  final String category; // e.g., "fade", "undercut", "pompadour", "crop"
  final String difficulty; // easy, medium, hard
  final List<String> compatibleFaceShapes; // ["oval", "square", "round", etc.]
  final List<String> compatibleHairTypes; // ["straight", "wavy", "curly", "coily"]
  final Color primaryColor;
  final Color accentColor;
  final String imageUrl; // URL to hairstyle image
  final bool isPremium;
  final int usageCount;
  final double rating; // 0.0-5.0
  final bool trending;
  final DateTime createdDate;
  final String styleCode; // Unique code for render logic

  HairstyleFilter({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.compatibleFaceShapes,
    required this.compatibleHairTypes,
    required this.primaryColor,
    required this.accentColor,
    required this.imageUrl,
    this.isPremium = false,
    this.usageCount = 0,
    this.rating = 0.0,
    this.trending = false,
    required this.createdDate,
    required this.styleCode,
  });

  factory HairstyleFilter.fromJson(Map<String, dynamic> json) {
    return HairstyleFilter(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      compatibleFaceShapes: List<String>.from(json['compatibleFaceShapes'] ?? []),
      compatibleHairTypes: List<String>.from(json['compatibleHairTypes'] ?? []),
      primaryColor: Color(int.parse(json['primaryColor'] ?? '0xFFD946A6')),
      accentColor: Color(int.parse(json['accentColor'] ?? '0xFF00F5D4')),
      imageUrl: json['imageUrl'] ?? '',
      isPremium: json['isPremium'] ?? false,
      usageCount: json['usageCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      trending: json['trending'] ?? false,
      createdDate: DateTime.parse(json['createdDate'] ?? DateTime.now().toIso8601String()),
      styleCode: json['styleCode'] ?? 'default',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'difficulty': difficulty,
    'compatibleFaceShapes': compatibleFaceShapes,
    'compatibleHairTypes': compatibleHairTypes,
    'primaryColor': primaryColor.value.toString(),
    'accentColor': accentColor.value.toString(),
    'imageUrl': imageUrl,
    'isPremium': isPremium,
    'usageCount': usageCount,
    'rating': rating,
    'trending': trending,
    'createdDate': createdDate.toIso8601String(),
    'styleCode': styleCode,
  };

  HairstyleFilter copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? difficulty,
    List<String>? compatibleFaceShapes,
    List<String>? compatibleHairTypes,
    Color? primaryColor,
    Color? accentColor,
    String? imageUrl,
    bool? isPremium,
    int? usageCount,
    double? rating,
    bool? trending,
    DateTime? createdDate,
    String? styleCode,
  }) {
    return HairstyleFilter(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      compatibleFaceShapes: compatibleFaceShapes ?? this.compatibleFaceShapes,
      compatibleHairTypes: compatibleHairTypes ?? this.compatibleHairTypes,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      imageUrl: imageUrl ?? this.imageUrl,
      isPremium: isPremium ?? this.isPremium,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
      trending: trending ?? this.trending,
      createdDate: createdDate ?? this.createdDate,
      styleCode: styleCode ?? this.styleCode,
    );
  }
}

/// Represents filter application state
class FilterApplicationState {
  final bool isApplying;
  final double intensity; // 0.0-1.0 for blend intensity
  final bool enableSmoothing; // For smoother transitions
  final String selectedStyleCode;

  const FilterApplicationState({
    this.isApplying = false,
    this.intensity = 1.0,
    this.enableSmoothing = true,
    this.selectedStyleCode = 'default',
  });

  FilterApplicationState copyWith({
    bool? isApplying,
    double? intensity,
    bool? enableSmoothing,
    String? selectedStyleCode,
  }) {
    return FilterApplicationState(
      isApplying: isApplying ?? this.isApplying,
      intensity: intensity ?? this.intensity,
      enableSmoothing: enableSmoothing ?? this.enableSmoothing,
      selectedStyleCode: selectedStyleCode ?? this.selectedStyleCode,
    );
  }
}
