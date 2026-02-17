import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/item_view_model.dart';
import '../widgets/item_card.dart';
import 'item_detail_screen.dart';

class LocationItemsScreen extends StatefulWidget {
  final String locationName;

  const LocationItemsScreen({super.key, required this.locationName});

  @override
  State<LocationItemsScreen> createState() => _LocationItemsScreenState();
}

class _LocationItemsScreenState extends State<LocationItemsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemViewModel>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        centerTitle: true,
      ),
      body: Consumer<ItemViewModel>(
        builder: (context, viewModel, child) {
          var items = viewModel.items
              .where((item) => item.storageLocation == widget.locationName)
              .toList();

          // 按剩余保质期排序（短的在前）
          items.sort((a, b) {
            final aDays = a.daysUntilExpiration ?? 999999;
            final bDays = b.daysUntilExpiration ?? 999999;
            return aDays.compareTo(bDays);
          });

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
                    return await showDialog<bool>(
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
                  },
                  onDismissed: (direction) {
                    context.read<ItemViewModel>().deleteItem(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} 已删除'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: ItemCard(
                    key: ValueKey(item.id),
                    item: item,
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
              );
            },
          );
        },
      ),
    );
  }
}