import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/expiration_status_ui.dart';
import '../view_models/item_view_model.dart';
import '../widgets/item_card.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

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
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemViewModel>(
      builder: (context, viewModel, child) {
        final isSelectionMode = viewModel.isSelectionMode;

        return Scaffold(
          appBar: AppBar(
            title: isSelectionMode
                ? Text('已选择 ${viewModel.selectedCount} 项')
                : const Text('收纳'),
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
                  tooltip: '全选',
                ),
                // 批量删除按钮
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: viewModel.selectedCount > 0
                      ? () => _showDeleteConfirmation(context, viewModel)
                      : null,
                  tooltip: '删除',
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
                    decoration: InputDecoration(
                      hintText: '搜索物品',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            label: '全部',
                            isSelected: viewModel.selectedCategory == null,
                            onSelected: () => viewModel.clearCategory(),
                          ),
                          const SizedBox(width: 8),
                          ...ItemCategory.values.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildCategoryChip(
                                context,
                                label: category.label,
                                isSelected: viewModel.selectedCategory == category,
                                onSelected: () => viewModel.setCategory(category),
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
                child: _buildItemList(viewModel, isSelectionMode),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemList(ItemViewModel viewModel, bool isSelectionMode) {
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
            const Text(
              '暂无物品',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '点击右上角添加物品',
              style: TextStyle(
                fontSize: 14,
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
        final isSelected = viewModel.isSelected(item.id);
        // 使用 ViewModel 获取基于用户设置的状态
        final status = viewModel.getItemStatus(item);

        return _buildItemTile(context, viewModel, item, status, isSelectionMode, isSelected);
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
      // 选择模式：显示复选框
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: CheckboxListTile(
          value: isSelected,
          onChanged: (_) => viewModel.toggleSelection(item.id),
          title: Text(item.name),
          subtitle: Text(
            '${item.storageLocation} • ${item.category.label} • x${item.quantity}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          secondary: Container(
            width: 12,
            height: 12,
              decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      // 普通模式：显示滑动删除 + 长按进入选择模式
      return RepaintBoundary(
        child: Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
              confirmDismiss: (direction) async {
            return await _confirmDelete(context, item);
          },
          onDismissed: (direction) {
            viewModel.deleteItem(item);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} 已删除'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: GestureDetector(
            onLongPress: () {
              // 长按进入选择模式
              viewModel.toggleSelection(item.id);
            },
            child: ItemCard(
              key: ValueKey(item.id),
              item: item,
              status: status,
              onDelete: () => _deleteItemWithConfirm(context, viewModel, item),
              onEdit: () => _editItem(context, item),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen(item: item),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  Future<void> _editItem(BuildContext context, Item item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(editingItem: item),
      ),
    );
    if (context.mounted) {
      context.read<ItemViewModel>().loadItems();
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, Item item) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除物品'),
        content: Text('确定要删除 "${item.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItemWithConfirm(
    BuildContext context,
    ItemViewModel viewModel,
    Item item,
  ) async {
    final confirmed = await _confirmDelete(context, item) ?? false;
    if (!confirmed) return;
    await viewModel.deleteItem(item);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} 已删除'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ItemViewModel viewModel) {
    final countToDelete = viewModel.selectedCount;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定要删除已选择的 $countToDelete 个物品吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final deletedCount = await viewModel.deleteSelectedItems();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除 $deletedCount 个物品'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
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
