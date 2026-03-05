import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
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
