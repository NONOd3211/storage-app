import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final Future<void> Function(Item)? onRenew;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onRenew,
  });

  Color get _statusColor {
    switch (item.expirationStatus) {
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

  void _showRenewDialog(BuildContext context) {
    if (item.expirationDays == null && item.expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该物品未设置保质期，无法重置')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('重置保质期'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('为 "${item.name}" 重置保质期'),
            const SizedBox(height: 16),
            const Text('选择增加天数：'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => _renew(dialogContext, 30),
            child: const Text('+30 天'),
          ),
          FilledButton(
            onPressed: () => _renew(dialogContext, 90),
            child: const Text('+90 天'),
          ),
          FilledButton(
            onPressed: () => _renew(dialogContext, 180),
            child: const Text('+180 天'),
          ),
          FilledButton(
            onPressed: () => _renew(dialogContext, 365),
            child: const Text('+365 天'),
          ),
          TextButton(
            onPressed: () => _showCustomDaysDialog(dialogContext),
            child: const Text('自定义天数'),
          ),
        ],
      ),
    );
  }

  void _renew(BuildContext dialogContext, int days) async {
    if (onRenew != null) {
      // 直接创建新对象，清除生产日期和保质期天数，只保留到期日期
      final renewedItem = Item(
        id: item.id,
        name: item.name,
        category: item.category,
        storageLocation: item.storageLocation,
        quantity: item.quantity,
        productionDate: null,
        expirationDays: null,
        expirationDate: DateTime.now().add(Duration(days: days)),
        notes: item.notes,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
      );
      await onRenew!(renewedItem);
    }
    Navigator.pop(dialogContext);
  }

  void _showCustomDaysDialog(BuildContext dialogContext) {
    final controller = TextEditingController();
    showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('自定义天数'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '天数',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final days = int.tryParse(controller.text);
              if (days != null && days > 0) {
                Navigator.pop(context);
                _renew(dialogContext, days);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiration;
    final statusColor = _statusColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.storageLocation,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '•',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.category.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '•',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'x${item.quantity.toString()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (days != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        days < 0
                            ? '已过期 ${-days} 天'
                            : days == 0
                                ? '今天到期'
                                : '剩余 $days 天',
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onRenew != null && (item.expirationDays != null || item.expirationDate != null))
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: statusColor,
                    size: 20,
                  ),
                  tooltip: '重置保质期',
                  onPressed: () => _showRenewDialog(context),
                ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
