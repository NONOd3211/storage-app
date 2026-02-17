import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ItemViewModel extends ChangeNotifier {
  final DatabaseService _database = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<Item> _items = [];
  List<Item> get items => _items;

  String _searchText = '';
  String get searchText => _searchText;

  ItemCategory? _selectedCategory;
  ItemCategory? get selectedCategory => _selectedCategory;

  List<Item> get filteredItems {
    List<Item> result;

    // 搜索筛选
    if (_searchText.isEmpty) {
      result = _items;
    } else {
      result = _items
          .where((item) =>
              item.name.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }

    // 分类筛选
    if (_selectedCategory != null) {
      result = result.where((item) => item.category == _selectedCategory).toList();
    }

    // 按剩余保质期排序（短的在前），null排最后
    result.sort((a, b) {
      final aDays = a.daysUntilExpiration ?? 999999;
      final bDays = b.daysUntilExpiration ?? 999999;
      return aDays.compareTo(bDays);
    });
    return result;
  }

  Future<void> loadItems() async {
    _items = await _database.getAllItems();
    notifyListeners();
  }

  void setSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }

  void setCategory(ItemCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  Future<void> addItem(Item item) async {
    await _database.insertItem(item);
    await _notificationService.scheduleNotification(item);
    await loadItems();
  }

  Future<void> updateItem(Item item) async {
    await _database.updateItem(item);
    await _notificationService.cancelNotifications(item);
    await _notificationService.scheduleNotification(item);
    await loadItems();
  }

  Future<void> deleteItem(Item item) async {
    await _database.deleteItem(item);
    await _notificationService.cancelNotifications(item);
    await loadItems();
  }

  Future<List<Item>> searchItems(String query) async {
    return await _database.searchItems(query);
  }

  List<Item> get urgentItems {
    return _items
        .where((item) =>
            item.expirationStatus == ExpirationStatus.urgent ||
            item.expirationStatus == ExpirationStatus.expired)
        .toList();
  }

  // 获取某个位置下物品的最紧急状态
  ExpirationStatus? getLocationStatus(String locationName) {
    final locationItems = _items.where((item) => item.storageLocation == locationName);
    if (locationItems.isEmpty) return null;

    // 优先级：expired > urgent > warning > fresh
    bool hasExpired = locationItems.any((item) => item.expirationStatus == ExpirationStatus.expired);
    if (hasExpired) return ExpirationStatus.expired;

    bool hasUrgent = locationItems.any((item) => item.expirationStatus == ExpirationStatus.urgent);
    if (hasUrgent) return ExpirationStatus.urgent;

    bool hasWarning = locationItems.any((item) => item.expirationStatus == ExpirationStatus.warning);
    if (hasWarning) return ExpirationStatus.warning;

    return ExpirationStatus.fresh;
  }
}
