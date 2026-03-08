import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../view_models/item_view_model.dart';
import '../view_models/location_view_model.dart';
import '../widgets/item_list_interactions.dart';

class LocationItemsScreen extends StatefulWidget {
  final String locationId;
  final String locationName;

  const LocationItemsScreen({
    super.key,
    required this.locationId,
    required this.locationName,
  });

  @override
  State<LocationItemsScreen> createState() => _LocationItemsScreenState();
}

class _LocationItemsScreenState extends State<LocationItemsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemViewModel = context.read<ItemViewModel>();
      itemViewModel.clearSelection();
      itemViewModel.loadItems();
      context.read<LocationViewModel>().loadLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ItemViewModel>().clearSelection();
        }
      },
      child: Consumer2<ItemViewModel, LocationViewModel>(
        builder: (context, viewModel, locationViewModel, child) {
          final isSelectionMode = viewModel.isSelectionMode;
          final items = _locationItems(viewModel);

          return Scaffold(
            appBar: AppBar(
              title: isSelectionMode ? Text('已选择 ${viewModel.selectedCount} 项') : Text(widget.locationName),
              centerTitle: true,
              leading: isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => viewModel.clearSelection(),
                    )
                  : null,
              actions: [
                if (isSelectionMode) ...[
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: () => _selectAllInLocation(viewModel, items),
                    tooltip: '全选',
                  ),
                  IconButton(
                    icon: const Icon(Icons.drive_file_move_outline),
                    onPressed: viewModel.selectedCount > 0
                        ? () => ItemListActions.showTransferSelectedDialog(
                              context,
                              itemViewModel: viewModel,
                              locations: locationViewModel.locations,
                              excludeLocationId: widget.locationId,
                            )
                        : null,
                    tooltip: '转移',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: viewModel.selectedCount > 0
                        ? () => ItemListActions.showBatchDeleteConfirmation(context, viewModel)
                        : null,
                    tooltip: '删除',
                  ),
                ],
              ],
            ),
            body: _buildBody(context, viewModel, items, isSelectionMode),
          );
        },
      ),
    );
  }

  List<Item> _locationItems(ItemViewModel viewModel) {
    final items = viewModel.items
        .where((item) =>
            item.storageLocationId == widget.locationId ||
            (item.storageLocationId.isEmpty && item.storageLocation == widget.locationName))
        .toList();
    items.sort((a, b) {
      final aDays = a.daysUntilExpiration ?? 999999;
      final bDays = b.daysUntilExpiration ?? 999999;
      return aDays.compareTo(bDays);
    });
    return items;
  }

  Widget _buildBody(
    BuildContext context,
    ItemViewModel viewModel,
    List<Item> items,
    bool isSelectionMode,
  ) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '该位置暂无物品',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      cacheExtent: 200,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final status = viewModel.getItemStatus(item);
        final isSelected = viewModel.isSelected(item.id);

        if (isSelectionMode) {
          return SelectionItemTile(
            item: item,
            status: status,
            isSelected: isSelected,
            onToggleSelection: () => viewModel.toggleSelection(item.id),
          );
        }

        return NormalItemTile(
          item: item,
          status: status,
          onConfirmDelete: () => ItemListActions.confirmDelete(context, item),
          onDeleteShortcut: () => ItemListActions.deleteItemWithConfirm(
            context,
            viewModel,
            item,
          ),
          onDeleteByDismissed: () => ItemListActions.deleteItemDirect(
            context,
            viewModel,
            item,
          ),
          onEdit: () => ItemListActions.editItem(context, item),
          onOpenDetail: () => ItemListActions.openDetail(context, item),
          onToggleSelection: () => viewModel.toggleSelection(item.id),
        );
      },
    );
  }

  void _selectAllInLocation(ItemViewModel viewModel, List<Item> items) {
    viewModel.setSelectionByIds(items.map((e) => e.id));
  }
}
