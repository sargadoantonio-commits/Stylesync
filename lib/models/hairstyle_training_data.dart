/// ML / recommendation metadata for a haircut — used by AR camera and trainers.
class HairstyleTrainingData {
  final String id;
  final String officialName;
  final List<String> aliases;
  final String description;
  final Map<String, dynamic> characteristics;
  final String imageUrl;
  final List<String> tags;
  final int tiktokTrendingScore; // 0-100 (estimated trend weight — not scraped)
  final int instagramPopularity; // 0-100
  final int barberDifficultyScore; // 1-10

  HairstyleTrainingData({
    required this.id,
    required this.officialName,
    required this.aliases,
    required this.description,
    required this.characteristics,
    required this.imageUrl,
    required this.tags,
    required this.tiktokTrendingScore,
    required this.instagramPopularity,
    required this.barberDifficultyScore,
  });

  int getCompatibilityScore(String faceShape) {
    final compatibility = characteristics['faceShapeCompatibility'] as Map?;
    return compatibility?[faceShape.toLowerCase()] ?? 50;
  }

  String getMaintenanceFrequency() {
    return characteristics['maintenanceFrequency'] ?? 'Regular';
  }

  int getTrendingScore() => ((tiktokTrendingScore + instagramPopularity) / 2).toInt();

  Map<String, dynamic> toJson() => {
        'id': id,
        'officialName': officialName,
        'aliases': aliases,
        'description': description,
        'characteristics': characteristics,
        'imageUrl': imageUrl,
        'tags': tags,
        'tiktokTrendingScore': tiktokTrendingScore,
        'instagramPopularity': instagramPopularity,
        'barberDifficultyScore': barberDifficultyScore,
      };
}
