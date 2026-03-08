import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../models/storage_location.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../main.dart';

class ItemViewModel extends ChangeNotifier {
  final DatabaseService _database = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  Timer? _rescheduleDebounce;
  int _rescheduleVersion = 0;
  static const Duration _rescheduleDebounceDuration = Duration(milliseconds: 200);
  static const int _rescheduleBatchSize = 8;

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
    await _syncItemNotifications(item);
    await loadItems();
  }

  Future<void> updateItem(Item item) async {
    await _database.updateItem(item);
    await _syncItemNotifications(item);
    await loadItems();
  }

  Future<void> deleteItem(Item item) async {
    await _database.deleteItem(item);
    try {
      await _notificationService.cancelNotifications(item);
    } catch (e) {
      debugPrint('取消通知失败（${item.id}）: $e');
    }
    await loadItems();
  }

  Future<void> _syncItemNotifications(Item item) async {
    try {
      await _notificationService.cancelNotifications(item);
      await _notificationService.scheduleNotification(item);
    } catch (e) {
      // 保存物品是主流程；通知失败不应导致 UI 提示“保存失败”。
      debugPrint('同步通知失败（${item.id}）: $e');
    }
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

  // 批量设置选中项（用于特定列表场景，如位置内列表）
  void setSelectionByIds(Iterable<String> ids) {
    _selectedIds
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  // 取消全选
  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  // 检查物品是否被选中
  bool isSelected(String itemId) => _selectedIds.contains(itemId);

  // 获取使用用户设置阈值的物品状态
  ExpirationStatus getItemStatus(Item item) {
    return item.getExpirationStatus(
      warningDays: settingsService.warningDays,
      urgentDays: settingsService.urgentDays,
    );
  }

  Future<List<Item>> searchItems(String query) async {
    return await _database.searchItems(query);
  }

  Future<int> transferSelectedItemsToLocation(StorageLocation targetLocation) async {
    final idsToTransfer = _selectedIds.toList();
    if (idsToTransfer.isEmpty) return 0;

    final updatedCount = await _database.transferItemsByIds(
      itemIds: idsToTransfer,
      toLocationId: targetLocation.id,
      toLocationName: targetLocation.name,
    );

    _selectedIds.clear();
    await loadItems();
    return updatedCount;
  }

  void refreshComputedState() {
    notifyListeners();
  }

  Future<void> rescheduleAllNotifications() async {
    final version = ++_rescheduleVersion;
    _rescheduleDebounce?.cancel();
    _rescheduleDebounce = Timer(_rescheduleDebounceDuration, () {
      unawaited(_runReschedule(version));
    });
  }

  Future<void> _runReschedule(int version) async {
    if (version != _rescheduleVersion) return;

    try {
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      debugPrint('取消全部通知失败: $e');
    }

    if (version != _rescheduleVersion) return;
    if (!settingsService.notificationEnabled) return;

    var itemsForReschedule = _items;
    if (itemsForReschedule.isEmpty) {
      itemsForReschedule = await _database.getAllItems();
      if (version != _rescheduleVersion) return;
      _items = itemsForReschedule;
      notifyListeners();
    }

    for (int i = 0; i < itemsForReschedule.length; i += _rescheduleBatchSize) {
      if (version != _rescheduleVersion) return;
      final batch = itemsForReschedule.skip(i).take(_rescheduleBatchSize).toList();
      await Future.wait(
        batch.map((item) async {
          if (version != _rescheduleVersion) return;
          try {
            await _notificationService.scheduleNotification(item);
          } catch (e) {
            debugPrint('重排通知失败（${item.id}）: $e');
          }
        }),
      );
    }
  }

  @override
  void dispose() {
    _rescheduleDebounce?.cancel();
    super.dispose();
  }

  List<Item> get urgentItems {
    final warningDays = settingsService.warningDays;
    final urgentDays = settingsService.urgentDays;
    return _items
        .where((item) {
          final status = item.getExpirationStatus(
            warningDays: warningDays,
            urgentDays: urgentDays,
          );
          return status == ExpirationStatus.urgent ||
                 status == ExpirationStatus.expired;
        })
        .toList();
  }

  // 获取某个位置下物品的最紧急状态（使用用户设置）
  ExpirationStatus? getLocationStatus(String locationId, {String? fallbackName}) {
    final warningDays = settingsService.warningDays;
    final urgentDays = settingsService.urgentDays;

    final locationItems = _items.where((item) {
      if (item.storageLocationId == locationId) return true;
      return item.storageLocationId.isEmpty &&
          fallbackName != null &&
          item.storageLocation == fallbackName;
    });
    if (locationItems.isEmpty) return null;

    // 优先级：expired > urgent > warning > fresh
    bool hasExpired = locationItems.any((item) =>
        item.getExpirationStatus(warningDays: warningDays, urgentDays: urgentDays) ==
        ExpirationStatus.expired);
    if (hasExpired) return ExpirationStatus.expired;

    bool hasUrgent = locationItems.any((item) =>
        item.getExpirationStatus(warningDays: warningDays, urgentDays: urgentDays) ==
        ExpirationStatus.urgent);
    if (hasUrgent) return ExpirationStatus.urgent;

    bool hasWarning = locationItems.any((item) =>
        item.getExpirationStatus(warningDays: warningDays, urgentDays: urgentDays) ==
        ExpirationStatus.warning);
    if (hasWarning) return ExpirationStatus.warning;

    return ExpirationStatus.fresh;
  }
}
