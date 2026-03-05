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

  // 批量选择状态
  final Set<String> _selectedIds = {};
  Set<String> get selectedIds => _selectedIds;
  bool get isSelectionMode => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;

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

  // 批量删除 - 优化版本
  Future<int> deleteSelectedItems() async {
    // 获取要删除的 ID 列表
    final idsToDelete = _selectedIds.toList();

    if (idsToDelete.isEmpty) {
      return 0;
    }

    // 遍历删除
    for (final id in idsToDelete) {
      try {
        final item = _items.firstWhere((i) => i.id == id);
        await _database.deleteItem(item);
        await _notificationService.cancelNotifications(item);
      } catch (e) {
        debugPrint('删除物品 $id 失败: $e');
      }
    }

    // 清空选择并重新加载
    _selectedIds.clear();
    await loadItems();

    return idsToDelete.length;
  }

  // 选择/取消选择单个物品
  void toggleSelection(String itemId) {
    if (_selectedIds.contains(itemId)) {
      _selectedIds.remove(itemId);
    } else {
      _selectedIds.add(itemId);
    }
    notifyListeners();
  }

  // 全选当前列表中的物品
  void selectAll() {
    _selectedIds.clear();
    for (final item in filteredItems) {
      _selectedIds.add(item.id);
    }
    notifyListeners();
  }

  // 取消全选
  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  // 检查物品是否被选中
  bool isSelected(String itemId) => _selectedIds.contains(itemId);

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
