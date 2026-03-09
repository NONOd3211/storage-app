import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_text_extensions.dart';
import '../models/item.dart';
import '../view_models/location_view_model.dart';
import '../view_models/item_view_model.dart';
import '../widgets/item_list_interactions.dart';
import '../widgets/limited_text_context_menu.dart';
import 'add_item_screen.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemViewModel>().loadItems();
      context.read<LocationViewModel>().loadLocations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ItemViewModel>(
      builder: (context, viewModel, child) {
        final isSelectionMode = viewModel.isSelectionMode;

        return PopScope(
          canPop: !isSelectionMode,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && isSelectionMode) {
              viewModel.clearSelection();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: isSelectionMode
                  ? Text(l10n.selectionCount(viewModel.selectedCount))
                  : Text(l10n.appTitle),
              centerTitle: true,
              leading: isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => viewModel.clearSelection(),
                    )
                  : null,
              actions: [
                if (isSelectionMode) ...[
                  // 全选按钮
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: () => viewModel.selectAll(),
                    tooltip: l10n.actionSelectAll,
                  ),
                  IconButton(
                    icon: const Icon(Icons.drive_file_move_outline),
                    onPressed: viewModel.selectedCount > 0
                        ? () async {
                            final locationViewModel = context
                                .read<LocationViewModel>();
                            if (locationViewModel.locations.isEmpty) {
                              await locationViewModel.loadLocations();
                            }
                            if (!context.mounted) return;
                            await ItemListActions.showTransferSelectedDialog(
                              context,
                              itemViewModel: viewModel,
                              locations: locationViewModel.locations,
                            );
                          }
                        : null,
                    tooltip: l10n.actionTransfer,
                  ),
                  // 批量删除按钮
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: viewModel.selectedCount > 0
                        ? () => _showDeleteConfirmation(context, viewModel)
                        : null,
                    tooltip: l10n.actionDelete,
                  ),
                ] else ...[
                  // 添加按钮
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddItemScreen(),
                        ),
                      );
                      if (context.mounted) {
                        context.read<ItemViewModel>().loadItems();
                      }
                    },
                  ),
                ],
              ],
            ),
            body: Column(
              children: [
                // 搜索栏
                if (!isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      contextMenuBuilder: buildLimitedTextContextMenu,
                      decoration: InputDecoration(
                        hintText: l10n.searchItemsHint,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        context.read<ItemViewModel>().setSearchText(value);
                      },
                    ),
                  ),
                // 分类筛选
                if (!isSelectionMode)
                  Consumer<ItemViewModel>(
                    builder: (context, viewModel, child) {
                      return SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildCategoryChip(
                              context,
                              label: l10n.categoryAll,
                              isSelected: viewModel.selectedCategory == null,
                              onSelected: () => viewModel.clearCategory(),
                            ),
                            const SizedBox(width: 8),
                            ...ItemCategory.values.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildCategoryChip(
                                  context,
                                  label: category.localizedLabel(l10n),
                                  isSelected:
                                      viewModel.selectedCategory == category,
                                  onSelected: () =>
                                      viewModel.setCategory(category),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                if (!isSelectionMode) const SizedBox(height: 8),
                Expanded(
                  child: _buildItemList(viewModel, isSelectionMode, l10n),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemList(
    ItemViewModel viewModel,
    bool isSelectionMode,
    AppLocalizations l10n,
  ) {
    final items = viewModel.filteredItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.emptyNoItems,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyTapAddItem,
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
        final isSelected = viewModel.isSelected(item.id);
        // 使用 ViewModel 获取基于用户设置的状态
        final status = viewModel.getItemStatus(item);

        return _buildItemTile(
          context,
          viewModel,
          item,
          status,
          isSelectionMode,
          isSelected,
        );
      },
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    ItemViewModel viewModel,
    Item item,
    ExpirationStatus status,
    bool isSelectionMode,
    bool isSelected,
  ) {
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
      onDeleteShortcut: () =>
          ItemListActions.deleteItemWithConfirm(context, viewModel, item),
      onDeleteByDismissed: () =>
          ItemListActions.deleteItemDirect(context, viewModel, item),
      onEdit: () => ItemListActions.editItem(context, item),
      onOpenDetail: () => ItemListActions.openDetail(context, item),
      onToggleSelection: () => viewModel.toggleSelection(item.id),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ItemViewModel viewModel) {
    ItemListActions.showBatchDeleteConfirmation(context, viewModel);
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}
