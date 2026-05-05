import "package:shared_preferences/shared_preferences.dart";

class ShopSelectionRepository {
  Future<String?> getSelectedShopId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("selectedShopId");
  }

  Future<void> setSelectedShopId(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedShopId", shopId);
  }
}
