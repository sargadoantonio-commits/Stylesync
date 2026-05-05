import 'package:flutter/material.dart';

class Category {
  final String name;
  final String iconPath;
  final Color color;
  final bool isSelected;

  const Category({
    required this.name,
    required this.iconPath,
    required this.color,
    this.isSelected = false,
  });

  Category copyWith({
    String? name,
    String? iconPath,
    Color? color,
    bool? isSelected,
  }) {
    return Category(
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  static List<Category> getCategories() {
    return [
      const Category(
        name: 'Haircuts',
        iconPath: 'assets/icons/haircut.svg',
        color: Colors.blue,
        isSelected: true,
      ),
      const Category(
        name: 'Shaves',
        iconPath: 'assets/icons/shave.svg',
        color: Colors.green,
      ),
      const Category(
        name: 'Beard',
        iconPath: 'assets/icons/beard.svg',
        color: Colors.orange,
      ),
      // Add more as needed
    ];
  }
}