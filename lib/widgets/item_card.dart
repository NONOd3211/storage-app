import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final Function(Item)? onRenew;

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

  bool get _needsRenew {
    return item.expirationStatus != ExpirationStatus.fresh;
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
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (onRenew != null) {
                onRenew!(item.copyWith(
                  expirationDate: DateTime.now().add(const Duration(days: 30)),
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('+30 天'),
          ),
          FilledButton(
            onPressed: () {
              if (onRenew != null) {
                onRenew!(item.copyWith(
                  expirationDate: DateTime.now().add(const Duration(days: 60)),
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('+60 天'),
          ),
          FilledButton(
            onPressed: () {
              if (onRenew != null) {
                onRenew!(item.copyWith(
                  expirationDate: DateTime.now().add(const Duration(days: 90)),
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('+90 天'),
          ),
          FilledButton(
            onPressed: () {
              if (onRenew != null) {
                onRenew!(item.copyWith(
                  expirationDate: DateTime.now().add(const Duration(days: 180)),
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('+180 天'),
          ),
          FilledButton(
            onPressed: () {
              if (onRenew != null) {
                onRenew!(item.copyWith(
                  expirationDate: DateTime.now().add(const Duration(days: 365)),
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('+365 天'),
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
                          'x${item.quantity}',
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
              if (_needsRenew && onRenew != null)
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
