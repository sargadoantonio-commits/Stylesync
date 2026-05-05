import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/hairstyle_filter.dart';
import '../models/hairstyle_training_data.dart';

const String _kCatalogAssetPath = 'assets/data/hairstyle_catalog.json';

/// Loads a bundled haircut taxonomy used for consistent AR filter names,
/// synonyms, and training metadata. TikTok-/Reels-popular cuts are labeled
/// with common public terminology (not scraped from any platform).
class HairstyleCatalogLoader {
  HairstyleCatalogLoader._();

  static Future<List<Map<String, dynamic>>> loadRawMaps() async {
    final raw = await rootBundle.loadString(_kCatalogAssetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static HairstyleTrainingData mapToTrainingData(Map<String, dynamic> row) {
    final faceShapes = Map<String, int>.from(
      (row['faceShapeCompatibility'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ) ??
          {},
    );

    final hairRaw = row['hairType'];
    final hairList = hairRaw is List
        ? hairRaw.map((e) => e.toString()).toList()
        : <String>[];

    final characteristics = <String, dynamic>{
      'sideLength': row['sideLength'] ?? '',
      'topLength': row['topLength'] ?? '',
      'backLength': row['backLength'] ?? '',
      'texture': row['texture'] ?? '',
      'faceShapeCompatibility': faceShapes,
      'difficulty': row['difficulty'] ?? 'medium',
      'maintenanceLevel': row['maintenanceLevel'] ?? '',
      'maintenanceFrequency': row['maintenanceFrequency'] ?? '',
      'headSize': row['headSize'] ?? '',
      'hairType': hairList,
      'ageGroup': row['ageGroup'] ?? '',
    };

    final aliases = row['aliases'] is List
        ? (row['aliases'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final tags =
        row['tags'] is List ? (row['tags'] as List).map((e) => e.toString()).toList() : <String>[];

    return HairstyleTrainingData(
      id: row['id']?.toString() ?? 'unknown_style',
      officialName: row['officialName']?.toString() ?? 'Haircut',
      aliases: aliases,
      description: row['description']?.toString() ?? '',
      characteristics: characteristics,
      imageUrl: row['imageUrl']?.toString() ?? '',
      tags: tags,
      tiktokTrendingScore: (row['tiktokTrendingScore'] as num?)?.toInt() ?? 70,
      instagramPopularity: (row['instagramPopularity'] as num?)?.toInt() ?? 70,
      barberDifficultyScore: (row['barberDifficultyScore'] as num?)?.toInt() ?? 5,
    );
  }

  static HairstyleFilter mapToFilter(Map<String, dynamic> row, HairstyleTrainingData training) {
    final filterId = row['filterId']?.toString() ?? 'style_${training.id}';
    final compatibleFaceShapes =
        (training.characteristics['faceShapeCompatibility'] as Map?)?.keys.map((k) => k.toString()).toList() ??
            <String>['oval', 'square', 'round'];
    final ht = training.characteristics['hairType'];
    final compatibleHairTypes = ht is List ? ht.map((e) => e.toString().toLowerCase()).toList() : <String>['straight'];

    final primary = _parseHexColor(row['primaryColor']?.toString(), fallback: const Color(0xFFD946A6));
    final accent = _parseHexColor(row['accentColor']?.toString(), fallback: const Color(0xFF00F5D4));

    final imageRef = row['imageAsset']?.toString().isNotEmpty == true ? row['imageAsset']!.toString() : training.imageUrl;

    return HairstyleFilter(
      id: filterId,
      name: training.officialName,
      description: training.description,
      category: row['category']?.toString() ?? 'modern',
      difficulty: (training.characteristics['difficulty'] ?? 'medium').toString(),
      compatibleFaceShapes: compatibleFaceShapes,
      compatibleHairTypes: compatibleHairTypes,
      primaryColor: primary,
      accentColor: accent,
      imageUrl: imageRef,
      isPremium: row['isPremium'] == true,
      usageCount: (row['usageCount'] as num?)?.toInt() ?? 1000 + training.getTrendingScore() * 10,
      rating: (((row['rating'] as num?)?.toDouble()) ?? (3.8 + training.getTrendingScore() / 250)).clamp(3.5, 5.0),
      trending: training.getTrendingScore() >= 82,
      createdDate: DateTime.tryParse(row['createdDate']?.toString() ?? '') ?? DateTime(2025, 1, 1),
      styleCode: training.id,
    );
  }

  static Color _parseHexColor(String? s, {required Color fallback}) {
    if (s == null || s.isEmpty) return fallback;
    try {
      var x = s.replaceFirst('#', '').trim();
      if (x.startsWith('0x') || x.startsWith('0X')) {
        return Color(int.parse(x));
      }
      return Color(int.parse('FF$x', radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
