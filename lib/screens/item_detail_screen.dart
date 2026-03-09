import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_text_extensions.dart';
import '../models/item.dart';
import '../models/storage_location.dart';
import '../models/expiration_status_ui.dart';
import '../view_models/item_view_model.dart';
import 'add_item_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.itemDetailTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final viewModel = context.read<ItemViewModel>();
              final latestItem =
                  viewModel.items.where((i) => i.id == item.id).firstOrNull ??
                  item;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddItemScreen(editingItem: latestItem),
                ),
              );
              if (context.mounted) {
                context.read<ItemViewModel>().loadItems();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: Consumer<ItemViewModel>(
        builder: (context, viewModel, child) {
          // 从列表中获取最新的物品数据
          final latestItem =
              viewModel.items.where((i) => i.id == item.id).firstOrNull ?? item;
          // 使用 ViewModel 获取基于用户设置的状态
          final status = viewModel.getItemStatus(latestItem);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 状态卡片
              Card(
                color: status.color.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.expirationStatus,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: status.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: status.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status.localizedLabel(l10n),
                                  style: TextStyle(
                                    color: status.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (latestItem.calculatedExpirationDate != null)
                        _buildInfoRow(
                          l10n.expirationDateLabel,
                          dateFormat.format(
                            latestItem.calculatedExpirationDate!,
                          ),
                        ),
                      if (latestItem.daysUntilExpiration != null)
                        _buildInfoRow(
                          l10n.remainingDaysLabel,
                          latestItem.daysUntilExpiration! < 0
                              ? l10n.expiredDaysCompact(
                                  -latestItem.daysUntilExpiration!,
                                )
                              : l10n.remainingDays(
                                  latestItem.daysUntilExpiration!,
                                ),
                          valueColor: status.color,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.itemInfo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(l10n.nameLabel, latestItem.name),
                      _buildInfoRow(
                        l10n.categoryLabel,
                        latestItem.category.localizedLabel(l10n),
                      ),
                      _buildInfoRow(
                        l10n.storageLocationLabel,
                        StorageLocation(
                          id: latestItem.storageLocationId,
                          name: latestItem.storageLocation,
                        ).localizedName(l10n),
                      ),
                      _buildInfoRow(
                        l10n.quantityLabel,
                        latestItem.quantity.toString(),
                      ),
                      if (latestItem.expirationDate != null)
                        _buildInfoRow(
                          l10n.expirationDateLabel,
                          dateFormat.format(latestItem.expirationDate!),
                        ),
                      if (latestItem.productionDate != null)
                        _buildInfoRow(
                          l10n.productionDateLabel,
                          dateFormat.format(latestItem.productionDate!),
                        ),
                      if (latestItem.expirationDays != null)
                        _buildInfoRow(
                          l10n.shelfLifeLabel,
                          '${latestItem.expirationDays} ${l10n.daysSuffix}',
                        ),
                      if (latestItem.notes != null &&
                          latestItem.notes!.isNotEmpty)
                        _buildInfoRow(l10n.remarksLabel, latestItem.notes!),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.actionDelete),
        content: Text(l10n.confirmDeleteItemWithIrreversible(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final viewModel = context.read<ItemViewModel>();
              await viewModel.deleteItem(item);
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}
