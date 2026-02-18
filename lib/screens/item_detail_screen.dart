import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../view_models/item_view_model.dart';
import 'add_item_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('物品详情'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddItemScreen(editingItem: item),
                ),
              );
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
          final latestItem = viewModel.items.where((i) => i.id == item.id).firstOrNull ?? item;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 状态卡片
              Card(
                color: _getStatusColor(latestItem.expirationStatus).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '保质期状态',
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
                              color: _getStatusColor(latestItem.expirationStatus).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(latestItem.expirationStatus),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getStatusText(latestItem.expirationStatus),
                                  style: TextStyle(
                                    color: _getStatusColor(latestItem.expirationStatus),
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
                          '到期日期',
                          dateFormat.format(latestItem.calculatedExpirationDate!),
                        ),
                      if (latestItem.daysUntilExpiration != null)
                        _buildInfoRow(
                          '剩余天数',
                          latestItem.daysUntilExpiration! < 0
                              ? '${-latestItem.daysUntilExpiration!} 天（已过期）'
                              : '${latestItem.daysUntilExpiration} 天',
                          valueColor: _getStatusColor(latestItem.expirationStatus),
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
                      const Text(
                        '物品信息',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('名称', latestItem.name),
                      _buildInfoRow('分类', latestItem.category.label),
                      _buildInfoRow('存放位置', latestItem.storageLocation),
                      _buildInfoRow('份数', latestItem.quantity.toString()),
                      if (latestItem.expirationDate != null)
                        _buildInfoRow(
                          '到期日期',
                          dateFormat.format(latestItem.expirationDate!),
                        ),
                      if (latestItem.productionDate != null)
                        _buildInfoRow(
                          '生产日期',
                          dateFormat.format(latestItem.productionDate!),
                        ),
                      if (latestItem.expirationDays != null)
                        _buildInfoRow('保质期', '${latestItem.expirationDays.toString()} 天'),
                      if (latestItem.notes != null && latestItem.notes!.isNotEmpty)
                        _buildInfoRow('备注', latestItem.notes!),
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

  Color _getStatusColor(ExpirationStatus status) {
    switch (status) {
      case ExpirationStatus.fresh:
        return Colors.green;
      case ExpirationStatus.warning:
        return Colors.yellow.shade700;
      case ExpirationStatus.urgent:
        return Colors.orange;
      case ExpirationStatus.expired:
        return Colors.red;
    }
  }

  String _getStatusText(ExpirationStatus status) {
    switch (status) {
      case ExpirationStatus.fresh:
        return '新鲜';
      case ExpirationStatus.warning:
        return '注意';
      case ExpirationStatus.urgent:
        return '紧迫';
      case ExpirationStatus.expired:
        return '已过期';
    }
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除物品'),
        content: Text('确定要删除 ${item.name} 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final viewModel = context.read<ItemViewModel>();
              await viewModel.deleteItem(item);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}