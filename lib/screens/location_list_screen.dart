import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_text_extensions.dart';
import '../models/storage_location.dart';
import '../models/expiration_status_ui.dart';
import '../view_models/item_view_model.dart';
import '../view_models/location_view_model.dart';
import '../widgets/limited_text_context_menu.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.locationManagementTitle),
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
                    l10n.emptyNoLocations,
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              final locationStatus = itemVM.getLocationStatus(
                location.id,
                fallbackName: location.name,
              );
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      _getIconData(location.icon),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(location.localizedName(l10n)),
                      if (locationStatus != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: locationStatus.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: location.isPreset
                      ? Text(
                          l10n.presetLocation,
                          style: TextStyle(fontSize: 12),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
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
                          locationId: location.id,
                          locationName: location.name,
                          displayName: location.localizedName(l10n),
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
      case 'help_outline':
        return Icons.help_outline;
      default:
        return Icons.place;
    }
  }

  void _showAddDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addLocationTitle),
        content: TextField(
          controller: controller,
          contextMenuBuilder: buildLimitedTextContextMenu,
          decoration: InputDecoration(
            labelText: l10n.locationNameLabel,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
            child: Text(l10n.actionAdd),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, StorageLocation location) {
    final l10n = AppLocalizations.of(context)!;
    final itemVM = context.read<ItemViewModel>();
    final relatedItems = itemVM.items
        .where(
          (item) =>
              item.storageLocationId == location.id ||
              (item.storageLocationId.isEmpty &&
                  item.storageLocation == location.name),
        )
        .toList();

    if (relatedItems.isNotEmpty) {
      // 有关联物品，提示将同时删除所有物品
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.confirmDelete),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.locationHasItems(location.name, relatedItems.length)),
              const SizedBox(height: 12),
              Text(
                l10n.deleteLocationAlsoDeleteItems,
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
                  l10n.andMoreItems(relatedItems.length),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final locationVM = context.read<LocationViewModel>();
                // 删除所有关联物品
                for (final item in relatedItems) {
                  await itemVM.deleteItem(item);
                }
                // 删除位置
                await locationVM.deleteLocation(location);
                if (!context.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.deletedLocationAndItems(
                        location.name,
                        relatedItems.length,
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.confirmDelete),
            ),
          ],
        ),
      );
    } else {
      // 无关联物品，直接删除
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.deleteLocationTitle),
          content: Text(l10n.confirmDeleteLocation(location.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                await context.read<LocationViewModel>().deleteLocation(
                  location,
                );
                if (!context.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.deletedLocation(location.name)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.actionDelete),
            ),
          ],
        ),
      );
    }
  }
}
