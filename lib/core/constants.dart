/// StyleSync core constants and app-wide defaults
/// This file contains all hardcoded configuration values for the MVP
library;

// Shop Configuration
const String kShopId = "kings_cut_studio";
const String kShopName = "Kings Cut Studio";
const String kShopAddr = "123 Makati Ave, Makati City";

// Barber Names (placeholder)
const List<String> kBarbers = [
  "Jay Barber",
  "Mike Santos",
  "Carlo Reyes",
  "Dan Cruz",
];

// Services and Pricing
const Map<String, Map<String, dynamic>> kServices = {
  "fade_design": {
    "name": "Fade + Design",
    "price": 550,
    "minutes": 60,
  },
  "clean_fade": {
    "name": "Clean Fade",
    "price": 400,
    "minutes": 40,
  },
  "beard_trim": {
    "name": "Beard Trim",
    "price": 200,
    "minutes": 20,
  },
  "classic_cut": {
    "name": "Classic Cut",
    "price": 350,
    "minutes": 30,
  },
};

// Hair Styles for AR
const List<Map<String, dynamic>> kFreeStyles = [
  {
    "id": "skin_fade",
    "name": "Skin Fade",
    "desc": "Smooth low taper fade",
    "faces": ["oval", "round", "square"],
    "hair": ["straight", "wavy"]
  },
  {
    "id": "low_drop",
    "name": "Low Drop Fade",
    "desc": "Low fade with drop curve",
    "faces": ["oval", "heart", "diamond"],
    "hair": ["straight", "coily"]
  },
  {
    "id": "textured_crop",
    "name": "Textured Crop",
    "desc": "Soft fringe, matte finish",
    "faces": ["oval", "square", "round"],
    "hair": ["wavy", "straight"]
  },
  {
    "id": "modern_undercut",
    "name": "Modern Undercut",
    "desc": "Sharp sides, long top",
    "faces": ["oval", "heart"],
    "hair": ["straight"]
  },
  {
    "id": "pompadour",
    "name": "Classic Pompadour",
    "desc": "Volume and shine",
    "faces": ["oval", "square"],
    "hair": ["straight", "wavy"]
  },
  {
    "id": "burst_fade",
    "name": "Burst Fade",
    "desc": "Burst pattern around ear",
    "faces": ["round", "oval"],
    "hair": ["coily", "wavy"]
  },
  {
    "id": "afro_shaped",
    "name": "Afro Shaped",
    "desc": "Natural volume, shaped",
    "faces": ["oval", "round"],
    "hair": ["coily"]
  },
  {
    "id": "beard_blend",
    "name": "Beard Blend",
    "desc": "Clean jawline fade",
    "faces": ["square", "diamond"],
    "hair": ["straight", "wavy"]
  },
];

const List<String> kPremiumStyles = [
  "360 Wave",
  "Caesar Cut",
  "Quiff",
  "Blowout",
  "French Crop"
];

// Face shapes for filtering
const List<String> kFaceShapes = [
  "Oval",
  "Round",
  "Square",
  "Heart",
  "Diamond",
];

// Hair types for filtering
const List<String> kHairTypes = [
  "Straight",
  "Wavy",
  "Coily",
];

// App metadata
const String kAppName = "StyleSync";
const String kAppVersion = "1.0.0";
const String kSupportEmail = "support@stylesync.ph";

// Development flags
// When true, barber-related screens use static demo data and
// some live Firestore listeners are disabled to avoid permission
// errors during local UI preview.
// Set to false to enable live Firestore-driven booking lists.
const bool kUseDemoBarberUI = false;
