import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_text_extensions.dart';
import '../models/item.dart';
import '../models/expiration_status_ui.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final ExpirationStatus? status;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ItemCard({
    super.key,
    required this.item,
    this.status,
    required this.onTap,
    this.onDelete,
    this.onEdit,
  });

  Color get _statusColor {
    // 如果传入了 status 则使用，否则使用默认值计算
    final effectiveStatus = status ?? item.expirationStatus;
    return effectiveStatus.color;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                          item.localizedStorageLocationName(l10n),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 8),
                        Text(
                          item.category.localizedLabel(l10n),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.grey)),
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
                            ? l10n.expiredDays(-days)
                            : days == 0
                            ? l10n.dueToday
                            : l10n.remainingDays(days),
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
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: l10n.actionDelete,
                  onPressed: onDelete,
                ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.actionEdit,
                  onPressed: onEdit,
                ),
              if (onDelete == null && onEdit == null)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
