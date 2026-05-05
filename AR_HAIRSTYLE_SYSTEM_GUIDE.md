# StyleSync AR Hairstyle Filter System 🎬✨

## Overview
Advanced AR hairstyle filtering system with TikTok-like experience, real-time face detection, and ML-based hairstyle recommendations. The system provides realistic hairstyle simulations using advanced rendering engines and global hairstyle data integration.

---

## Architecture

### Core Components

#### 1. **ARHairstyleRenderingEngine** (`lib/services/ar_hairstyle_rendering_engine.dart`)
Advanced hairstyle rendering engine that simulates realistic hairstyle overlays on detected faces.

**Features:**
- 7 hairstyle types with detailed rendering:
  - Classic Fade
  - Modern Undercut
  - Classic Pompadour
  - Textured Crop
  - Beard Blend
  - Slicked Back (Premium)
  - Faux Hawk (Premium)

- Customizable rendering parameters:
  - Hair length (short, medium, long)
  - Top volume and height
  - Side blend ratios
  - Texture types (matte, textured, glossy, spike)
  - Shimmer and shine effects

- Advanced features:
  - Realistic hair path rendering
  - Texture and shine effects
  - Spiky texture generation
  - Beard blending support
  - Smooth filtering with blur effects

**Usage:**
```dart
ARHairstyleRenderingEngine.renderHairstyle(
  canvas,
  size,
  face,
  'fade_classic',
  intensity: 0.95,
  enableSmoothing: true,
);
```

#### 2. **MLFaceAnalysisService** (`lib/services/ml_face_analysis_service.dart`)
ML-based face analysis service using Google ML Kit for intelligent hairstyle recommendations.

**Features:**
- Face shape detection (oval, round, square, rectangle, diamond, heart)
- Face characteristics analysis:
  - Smile detection
  - Head tilt measurement
  - Skin tone estimation
  - Beard growth prediction
  - Face symmetry calculation
  - Jaw definition analysis

- Hairstyle compatibility scoring:
  - Face shape compatibility matrix
  - Characteristic-based compatibility
  - Real-time recommendation engine
  - Confidence scoring (0-100%)

**Usage:**
```dart
final analysis = MLFaceAnalysisService.analyzeFace(detectedFace);
print('Face Shape: ${analysis.faceShape}');
print('Best Match: ${analysis.bestMatch}');
print('Top Recommendations: ${analysis.recommendedStyles}');
print('Compatibility Score: ${analysis.compatibilityScores['fade_classic']}%');
```

**Returns:**
```dart
FaceAnalysisResult {
  faceShape: String,           // 'oval', 'round', 'square', etc.
  characteristics: FaceCharacteristics,
  recommendedStyles: List<String>,
  compatibilityScores: Map<String, double>,
  confidenceScore: double,     // 0.0-1.0
}
```

#### 3. **GlobalHairstyleDataService** (`lib/services/global_hairstyle_data_service.dart`)
Fetches and manages global hairstyle data from multiple sources with offline fallback.

**Features:**
- Multi-source data fetching:
  - Public APIs (hairstyledb.com, barberconnect.com)
  - Trending styles detection
  - Community-submitted styles
  - Offline fallback data

- Data management:
  - Local caching system
  - Search functionality
  - Filter by category, face shape, hair type
  - Rating and trending detection
  - Premium/Free tier support

**Usage:**
```dart
final service = GlobalHairstyleDataService();
await service.initialize();

// Get all styles
final allStyles = service.getAllStyles();

// Get trending styles
final trending = service.getTrendingStyles(limit: 10);

// Get compatible styles for face shape
final compatible = service.getCompatibleStyles('oval');

// Search styles
final results = service.searchStyles('fade');

// Get by ID
final style = service.getStyleById('style_fade');
```

#### 4. **Enhanced AR Camera Screen** (`lib/features/ar/presentation/ar_camera_screen.dart`)
Main UI screen with TikTok-like AR experience.

**Features:**
- Real-time face detection with ML analysis
- Live hairstyle preview with advanced rendering
- Adjustable filter intensity (0-100%)
- Smooth filtering toggle
- Recording functionality (up to 60 seconds)
- Hairstyle shuffling
- Compatibility scoring display
- Recommended styles carousel
- Side action buttons (Record, Beauty Effects, Close)

---

## Usage Guide

### Basic Integration

1. **Initialize the enhanced AR camera:**
```dart
// In your router or navigation
GoRoute(
  path: AppRoutes.ar,
  pageBuilder: (context, state) => const ArCameraScreen(),
),
```

2. **Access hairstyle data:**
```dart
final service = GlobalHairstyleDataService();
await service.initialize();
final styles = service.getTrendingStyles();
```

3. **Analyze face and get recommendations:**
```dart
if (faces.isNotEmpty) {
  final analysis = MLFaceAnalysisService.analyzeFace(faces.first);
  print('Best Hairstyle: ${analysis.bestMatch}');
}
```

### Advanced Rendering

**Customize hairstyle rendering:**
```dart
ARHairstyleRenderingEngine.renderHairstyle(
  canvas,
  size,
  face,
  'pompadour_classic',
  intensity: 0.8,      // 80% opacity
  enableSmoothing: true, // Apply blur filter
);
```

**Render specific hairstyle types:**
- `fade_classic` - Clean fade with precision edges
- `undercut_modern` - Sharp sides with textured top
- `pompadour_classic` - Volume with sleek styling
- `crop_textured` - Soft fringe with matte finish
- `beard_blend` - Seamless beard transition
- `slicked_back_premium` - Wet look with shine
- `faux_hawk_premium` - Edgy mohawk style

### ML Face Analysis in Depth

**Get detailed characteristics:**
```dart
final analysis = MLFaceAnalysisService.analyzeFace(face);

// Access detailed characteristics
final chars = analysis.characteristics;
print('Smiling: ${chars.isSmiling}');
print('Beard Growth: ${chars.estimatedBeardGrowth}'); // 0.0-1.0
print('Symmetry: ${chars.symmetryScore}');           // 0.0-1.0
print('Jaw Definition: ${chars.jawDefinition}');     // 0.0-1.0
```

**Check compatibility for specific style:**
```dart
final score = analysis.compatibilityScores['undercut_modern'];
print('Undercut compatibility: ${score?.toStringAsFixed(0)}%');
```

**Get ranked recommendations:**
```dart
final topFive = analysis.getTopRecommendations(5);
// Returns: ['fade_classic', 'undercut_modern', ...]
```

### Data Management

**Search and filter hairstyles:**
```dart
final service = GlobalHairstyleDataService();

// By category
final fades = service.getStylesByCategory('fade');

// By face shape
final roundFaceFriendly = service.getCompatibleStyles('round');

// Search by name/description
final results = service.searchStyles('textured');

// Premium only
final premium = service.getPremiumStyles();

// Free tier
final free = service.getFreeStyles();
```

**Cache statistics:**
```dart
final stats = service.getCacheStats();
print('Total styles: ${stats['totalStyles']}');
print('Premium: ${stats['premiumStyles']}');
print('Trending: ${stats['trendingStyles']}');
```

---

## UI/UX Features

### TikTok-Like Experience

**Recording Button (Center-Right):**
- Large circular recording button
- Visual feedback with color change (pink → red)
- Recording timer display (MM:SS)
- 60-second max recording

**Side Action Buttons:**
1. **Record Button** - Start/stop video recording
2. **Beauty Effects** - Toggle smooth filtering
3. **Close Button** - Exit AR camera

**Bottom Control Panel:**
- Current hairstyle display
- Filter intensity slider (0-100%)
- Recommended styles carousel
- Shuffle & Capture buttons
- Face detection statistics

**Top Status Bar:**
- Face detection indicator
- Face shape display
- Confidence percentage
- Real-time analysis

**Compatibility Info Box:**
- Best match hairstyle
- Compatibility percentage
- Live updates as face changes

### Interactivity

**Filter Intensity:**
```
0%   ├─ Invisible overlay
50%  ├─ Blended appearance
100% └─ Full hairstyle
```

**Smooth Filtering:**
- Toggle via beauty effects button
- Applies blur effect for smooth edges
- Enhanced realism for final result

**Recommended Styles Carousel:**
- Horizontally scrollable
- Shows compatibility score for each style
- Tap to select
- Auto-updates with face analysis

---

## Performance Optimization

### Face Detection
- 100ms processing interval (prevents lag)
- Efficient image stream handling
- Caching of face landmarks

### Rendering
- Conditional painting (only when needed)
- Efficient path drawing
- Limited texture calculations
- GPU-accelerated canvas operations

### Data Management
- Local caching reduces API calls
- Fallback data for offline mode
- Lazy loading of hairstyle data
- Memory-efficient image processing

---

## Hairstyle Customization

### Define New Hairstyles

Add to `HairstyleRenderingEngine.hairstyleConfigs`:

```dart
'custom_style': HairstyleRenderConfig(
  name: 'Custom Style Name',
  hairLength: HairLength.medium,
  hairstyleType: HairstyleType.fade,
  sideBlend: 0.95,
  topHeight: 0.4,
  topVolume: 0.6,
  frontHeight: 0.35,
  colors: ['#2C2C2C', '#1A1A1A'],
  shimmerIntensity: 0.15,
  textureType: TextureType.matte,
),
```

### Add to Global Data

```dart
HairstyleFilter(
  id: 'custom_style',
  name: 'Custom Style',
  description: 'Custom hairstyle description',
  category: 'custom',
  difficulty: 'medium',
  compatibleFaceShapes: ['oval', 'square'],
  compatibleHairTypes: ['straight', 'wavy'],
  primaryColor: const Color(0xFFD946A6),
  accentColor: const Color(0xFF00F5D4),
  imageUrl: 'assets/haircuts/custom.png',
  isPremium: false,
  rating: 4.8,
  trending: true,
  createdDate: DateTime.now(),
  styleCode: 'custom_style',
),
```

---

## API Integration

### Fetch from External APIs

The system supports integration with public hairstyle APIs:

```
1. https://api.hairstyledb.com/v1/styles
2. https://hairstyles-api.example.com/trending
3. https://api.barberconnect.com/styles
```

**API Response Format (Supported):**
```json
{
  "styles": [
    {
      "id": "style_123",
      "name": "Modern Fade",
      "category": "fade",
      "difficulty": "easy",
      "compatibleFaceShapes": ["oval", "square"],
      "compatibleHairTypes": ["straight", "wavy"],
      "rating": 4.8,
      "trending": true,
      "isPremium": false
    }
  ]
}
```

---

## Troubleshooting

### Camera not initializing
- Check camera permission in AndroidManifest.xml / Info.plist
- Ensure front camera is available
- Try restarting the app

### Face detection not working
- Ensure adequate lighting
- Move closer to camera
- Check if ML Kit is properly initialized
- Verify Google ML Kit Face Detection dependency

### Hairstyle overlay not showing
- Check if face detection is working
- Verify hairstyle ID exists in config
- Check canvas painting logic
- Ensure sufficient device resources

### No hairstyle data
- Check internet connection
- Verify API endpoints are accessible
- Check firewall/proxy settings
- Fallback data should load if all APIs fail

---

## Performance Metrics

**Recommended Specifications:**
- Minimum Android API: 21
- Minimum iOS: 11.0
- RAM: 2GB+
- Processing: Face detection ~100ms per frame
- Memory: Hairstyle cache ~10MB

---

## Future Enhancements

1. **Extended Hairstyle Database**
   - Connect to TikTok-like platforms
   - Community-submitted styles
   - Real-time trending detection

2. **Advanced ML Models**
   - Hair color detection
   - Hair texture analysis
   - Realistic simulation with neural networks

3. **Recording Features**
   - Video export with watermark
   - Social media sharing
   - Style history tracking

4. **Personalization**
   - User style preferences
   - Custom filter creation
   - Saved favorite styles

5. **Social Features**
   - Style recommendations from friends
   - Trending styles leaderboard
   - Barber showcase integration

---

## Dependencies

**Required Packages:**
- `camera: ^0.11.0` - Camera access
- `google_mlkit_face_detection: ^0.13.0` - Face detection
- `flutter_riverpod: ^2.6.1` - State management
- `image: ^4.1.3` - Image processing
- `http: ^1.1.0` - API calls

---

## License & Attribution

StyleSync AR Hairstyle System - Built with advanced ML and rendering technologies for realistic, real-time hairstyle previews.

