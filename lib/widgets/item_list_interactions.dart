import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/storage_location.dart';
import '../models/expiration_status_ui.dart';
import '../screens/add_item_screen.dart';
import '../screens/item_detail_screen.dart';
import '../view_models/item_view_model.dart';
import 'item_card.dart';

class ItemListActions {
  static Future<void> editItem(BuildContext context, Item item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(editingItem: item),
      ),
    );
    if (context.mounted) {
      context.read<ItemViewModel>().loadItems();
    }
  }

  static void openDetail(BuildContext context, Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(item: item),
      ),
    );
  }

  static Future<bool?> confirmDelete(BuildContext context, Item item) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除物品'),
        content: Text('确定要删除 "${item.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  static Future<void> deleteItemWithConfirm(
    BuildContext context,
    ItemViewModel viewModel,
    Item item,
  ) async {
    final confirmed = await confirmDelete(context, item) ?? false;
    if (!confirmed || !context.mounted) return;
    await deleteItem(context, viewModel, item);
  }

  static void deleteItemDirect(
    BuildContext context,
    ItemViewModel viewModel,
    Item item,
  ) {
    unawaited(deleteItem(context, viewModel, item));
  }

  static Future<void> deleteItem(
    BuildContext context,
    ItemViewModel viewModel,
    Item item,
  ) async {
    await viewModel.deleteItem(item);
    if (!context.mounted) return;
    showDeletedSnackBar(context, item.name);
  }

  static void showDeletedSnackBar(BuildContext context, String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName 已删除'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  static void showBatchDeleteConfirmation(
    BuildContext context,
    ItemViewModel viewModel,
  ) {
    final countToDelete = viewModel.selectedCount;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定要删除已选择的 $countToDelete 个物品吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final deletedCount = await viewModel.deleteSelectedItems();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除 $deletedCount 个物品'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  static Future<void> showTransferSelectedDialog(
    BuildContext context, {
    required ItemViewModel itemViewModel,
    required List<StorageLocation> locations,
    String? excludeLocationId,
  }) async {
    final targetLocations = locations
        .where((location) => location.id != excludeLocationId)
        .toList();

    if (targetLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有可转移的目标位置')),
      );
      return;
    }

    StorageLocation selectedLocation = targetLocations.first;
    final transferredCount = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('批量转移物品'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('已选择 ${itemViewModel.selectedCount} 个物品'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedLocation.id,
                decoration: const InputDecoration(
                  labelText: '目标位置',
                  border: OutlineInputBorder(),
                ),
                items: targetLocations
                    .map(
                      (location) => DropdownMenuItem<String>(
                        value: location.id,
                        child: Text(location.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedLocation = targetLocations.firstWhere(
                      (location) => location.id == value,
                    );
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final count = await itemViewModel.transferSelectedItemsToLocation(
                  selectedLocation,
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext, count);
              },
              child: const Text('确认转移'),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || transferredCount == null || transferredCount == 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已转移 $transferredCount 个物品到 ${selectedLocation.name}')),
    );
  }
}

class SelectionItemTile extends StatelessWidget {
  final Item item;
  final ExpirationStatus status;
  final bool isSelected;
  final VoidCallback onToggleSelection;

  const SelectionItemTile({
    super.key,
    required this.item,
    required this.status,
    required this.isSelected,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) => onToggleSelection(),
        title: Text(item.name),
        subtitle: Text(
          '${item.storageLocation} • ${item.category.label} • x${item.quantity}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        secondary: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class NormalItemTile extends StatelessWidget {
  final Item item;
  final ExpirationStatus status;
  final Future<bool?> Function() onConfirmDelete;
  final VoidCallback onDeleteShortcut;
  final VoidCallback onDeleteByDismissed;
  final VoidCallback onEdit;
  final VoidCallback onOpenDetail;
  final VoidCallback onToggleSelection;

  const NormalItemTile({
    super.key,
    required this.item,
    required this.status,
    required this.onConfirmDelete,
    required this.onDeleteShortcut,
    required this.onDeleteByDismissed,
    required this.onEdit,
    required this.onOpenDetail,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        confirmDismiss: (direction) => onConfirmDelete(),
        onDismissed: (direction) => onDeleteByDismissed(),
        child: GestureDetector(
          onLongPress: onToggleSelection,
          child: ItemCard(
            key: ValueKey(item.id),
            item: item,
            status: status,
            onDelete: onDeleteShortcut,
            onEdit: onEdit,
            onTap: onOpenDetail,
          ),
        ),
      ),
    );
  }
}
