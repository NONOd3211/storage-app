import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_text_extensions.dart';
import '../view_models/item_view_model.dart';
import '../view_models/location_view_model.dart';
import '../models/item.dart';
import 'settings_screen.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statisticsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: const StatisticsBody(),
    );
  }
}

class StatisticsBody extends StatelessWidget {
  const StatisticsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer2<ItemViewModel, LocationViewModel>(
      builder: (context, itemVM, locationVM, child) {
        final items = itemVM.items;
        final locations = locationVM.locations;

        // 统计各类数据（使用用户设置的状态阈值）
        final totalItems = items.length;
        final expiredCount = items
            .where((i) => itemVM.getItemStatus(i) == ExpirationStatus.expired)
            .length;
        final urgentCount = items
            .where((i) => itemVM.getItemStatus(i) == ExpirationStatus.urgent)
            .length;
        final warningCount = items
            .where((i) => itemVM.getItemStatus(i) == ExpirationStatus.warning)
            .length;
        final freshCount = items
            .where((i) => itemVM.getItemStatus(i) == ExpirationStatus.fresh)
            .length;

        // 分类统计
        final categoryCount = <ItemCategory, int>{};
        for (final category in ItemCategory.values) {
          categoryCount[category] = items
              .where((i) => i.category == category)
              .length;
        }

        // 位置统计
        final locationCount = <String, int>{};
        for (final location in locations) {
          final displayName = location.localizedName(l10n);
          locationCount[displayName] = items
              .where(
                (i) =>
                    i.storageLocationId == location.id ||
                    (i.storageLocationId.isEmpty &&
                        i.storageLocation == location.name),
              )
              .length;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 物品概览卡片
              _buildOverviewCard(
                context,
                totalItems: totalItems,
                expiredCount: expiredCount,
                urgentCount: urgentCount,
                warningCount: warningCount,
                freshCount: freshCount,
              ),
              const SizedBox(height: 24),

              // 分类统计
              Text(
                l10n.categoryStatistics,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildCategoryStats(context, categoryCount, totalItems),
              const SizedBox(height: 24),

              // 位置统计
              Text(
                l10n.locationStatistics,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildLocationStats(context, locationCount, totalItems),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required int totalItems,
    required int expiredCount,
    required int urgentCount,
    required int warningCount,
    required int freshCount,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.itemOverview,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  l10n.totalLabel,
                  totalItems.toString(),
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  l10n.freshLabel,
                  freshCount.toString(),
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  l10n.warningLabel,
                  warningCount.toString(),
                  Colors.yellow.shade700,
                ),
                _buildStatItem(
                  context,
                  l10n.urgentLabel,
                  urgentCount.toString(),
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  l10n.expiredLabel,
                  expiredCount.toString(),
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 过期进度条
            if (totalItems > 0) ...[
              const Divider(),
              const SizedBox(height: 8),
              _buildExpirationProgress(
                context: context,
                expiredCount: expiredCount,
                urgentCount: urgentCount,
                warningCount: warningCount,
                freshCount: freshCount,
                total: totalItems,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildExpirationProgress({
    required BuildContext context,
    required int expiredCount,
    required int urgentCount,
    required int warningCount,
    required int freshCount,
    required int total,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final expiredPercent = total > 0 ? expiredCount / total : 0.0;
    final urgentPercent = total > 0 ? urgentCount / total : 0.0;
    final warningPercent = total > 0 ? warningCount / total : 0.0;
    final freshPercent = total > 0
        ? freshCount / total
        : 1.0 - expiredPercent - urgentPercent - warningPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                if (freshPercent > 0)
                  Expanded(
                    flex: (freshPercent * 100).round(),
                    child: Container(color: Colors.green),
                  ),
                if (warningPercent > 0)
                  Expanded(
                    flex: (warningPercent * 100).round(),
                    child: Container(color: Colors.yellow.shade700),
                  ),
                if (urgentPercent > 0)
                  Expanded(
                    flex: (urgentPercent * 100).round(),
                    child: Container(color: Colors.orange),
                  ),
                if (expiredPercent > 0)
                  Expanded(
                    flex: (expiredPercent * 100).round(),
                    child: Container(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            _buildLegendItem(l10n.freshLabel, Colors.green),
            _buildLegendItem(l10n.warningLabel, Colors.yellow.shade700),
            _buildLegendItem(l10n.urgentLabel, Colors.orange),
            _buildLegendItem(l10n.expiredLabel, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryStats(
    BuildContext context,
    Map<ItemCategory, int> categoryCount,
    int total,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (categoryCount.values.every((v) => v == 0)) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              l10n.noItemData,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: ItemCategory.values.map((category) {
            final count = categoryCount[category] ?? 0;
            final percent = total > 0 ? count / total : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildProgressRow(
                context,
                label: category.localizedLabel(l10n),
                count: count,
                percent: percent,
                color: _getCategoryColor(category),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLocationStats(
    BuildContext context,
    Map<String, int> locationCount,
    int total,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (locationCount.isEmpty || locationCount.values.every((v) => v == 0)) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              l10n.noLocationData,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    // 按数量排序
    final sortedLocations = locationCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedLocations.map((entry) {
            final percent = total > 0 ? entry.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildProgressRow(
                context,
                label: entry.key,
                count: entry.value,
                percent: percent,
                color: Colors.blue,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProgressRow(
    BuildContext context, {
    required String label,
    required int count,
    required double percent,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            count.toString(),
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(ItemCategory category) {
    switch (category) {
      case ItemCategory.food:
        return Colors.orange;
      case ItemCategory.medicine:
        return Colors.red;
      case ItemCategory.cosmetics:
        return Colors.pink;
      case ItemCategory.daily:
        return Colors.blue;
      case ItemCategory.other:
        return Colors.grey;
    }
  }
}
