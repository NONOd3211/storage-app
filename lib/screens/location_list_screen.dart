import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../models/storage_location.dart';
import '../view_models/item_view_model.dart';
import '../view_models/location_view_model.dart';
import 'location_items_screen.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationViewModel>().loadLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('位置管理'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: Consumer2<LocationViewModel, ItemViewModel>(
        builder: (context, locationVM, itemVM, child) {
          final locations = locationVM.locations;

          if (locations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无位置',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              final locationStatus = itemVM.getLocationStatus(location.name);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      _getIconData(location.icon),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(location.name),
                      if (locationStatus != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getStatusColor(locationStatus),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: location.isPreset
                      ? const Text(
                          '预设位置',
                          style: TextStyle(fontSize: 12),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
                      ),
                      if (!location.isPreset)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, location),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationItemsScreen(
                          locationName: location.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'kitchen':
        return Icons.kitchen;
      case 'door_sliding':
        return Icons.door_sliding;
      case 'draw':
        return Icons.draw;
      case 'inventory_2':
        return Icons.inventory_2;
      case 'shelves':
        return Icons.shelves;
      default:
        return Icons.place;
    }
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加位置'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '位置名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<LocationViewModel>().addLocation(
                      StorageLocation(
                        id: const Uuid().v4(),
                        name: controller.text,
                        icon: 'place',
                        isPreset: false,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, StorageLocation location) {
    final itemVM = context.read<ItemViewModel>();
    final relatedItems = itemVM.items
        .where((item) => item.storageLocation == location.name)
        .toList();

    if (relatedItems.isNotEmpty) {
      // 有关联物品，提示将同时删除所有物品
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('确认删除'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('位置 "${location.name}" 下有 ${relatedItems.length} 个物品。'),
              const SizedBox(height: 12),
              const Text(
                '删除该位置将同时删除以下所有物品：',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: relatedItems.length > 5 ? 5 : relatedItems.length,
                  itemBuilder: (context, index) {
                    final item = relatedItems[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.inventory_2, size: 20),
                      title: Text(item.name),
                      subtitle: Text('x${item.quantity.toString()}'),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
              if (relatedItems.length > 5)
                Text(
                  '...等共 ${relatedItems.length} 个物品',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 删除所有关联物品
                for (final item in relatedItems) {
                  itemVM.deleteItem(item);
                }
                // 删除位置
                context.read<LocationViewModel>().deleteLocation(location);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除位置 "${location.name}" 及 ${relatedItems.length} 个物品'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('确认删除'),
            ),
          ],
        ),
      );
    } else {
      // 无关联物品，直接删除
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('删除位置'),
          content: Text('确定要删除位置 "${location.name}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                context.read<LocationViewModel>().deleteLocation(location);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除位置 "${location.name}"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        ),
      );
    }
  }
}