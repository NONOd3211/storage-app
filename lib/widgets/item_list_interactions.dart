import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_text_extensions.dart';
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
      MaterialPageRoute(builder: (context) => AddItemScreen(editingItem: item)),
    );
    if (context.mounted) {
      context.read<ItemViewModel>().loadItems();
    }
  }

  static void openDetail(BuildContext context, Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
    );
  }

  static Future<bool?> confirmDelete(BuildContext context, Item item) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.actionDelete),
        content: Text(l10n.confirmDeleteItem(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.actionDelete),
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
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.deletedItem(itemName)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  static void showBatchDeleteConfirmation(
    BuildContext context,
    ItemViewModel viewModel,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final countToDelete = viewModel.selectedCount;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.batchDeleteTitle),
        content: Text(l10n.batchDeleteConfirm(countToDelete)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final deletedCount = await viewModel.deleteSelectedItems();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.batchDeleted(deletedCount)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.actionDelete),
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
    final l10n = AppLocalizations.of(context)!;
    final targetLocations = locations
        .where((location) => location.id != excludeLocationId)
        .toList();

    if (targetLocations.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noTransferTargetLocation)));
      return;
    }

    StorageLocation selectedLocation = targetLocations.first;
    final transferredCount = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.batchTransferTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.selectedItemsCount(itemViewModel.selectedCount)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedLocation.id,
                decoration: InputDecoration(
                  labelText: l10n.targetLocation,
                  border: OutlineInputBorder(),
                ),
                items: targetLocations
                    .map(
                      (location) => DropdownMenuItem<String>(
                        value: location.id,
                        child: Text(location.localizedName(l10n)),
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
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final count = await itemViewModel
                    .transferSelectedItemsToLocation(selectedLocation);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext, count);
              },
              child: Text(l10n.confirmTransfer),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || transferredCount == null || transferredCount == 0) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.transferredItemsToLocation(
            transferredCount,
            selectedLocation.localizedName(l10n),
          ),
        ),
      ),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) => onToggleSelection(),
        title: Text(item.name),
        subtitle: Text(
          '${item.localizedStorageLocationName(l10n)} • ${item.category.localizedLabel(l10n)} • x${item.quantity}',
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
          child: const Icon(Icons.delete, color: Colors.white),
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
