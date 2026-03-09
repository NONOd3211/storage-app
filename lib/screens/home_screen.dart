import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../view_models/item_view_model.dart';
import 'item_list_screen.dart';
import 'location_list_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    if (index == 0 && _selectedIndex != 0) {
      // 切换回物品页面时刷新数据
      context.read<ItemViewModel>().loadItems();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ItemListScreen(),
          LocationListScreen(),
          StatisticsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: l10n.tabItems,
          ),
          NavigationDestination(
            icon: const Icon(Icons.place_outlined),
            selectedIcon: const Icon(Icons.place),
            label: l10n.tabLocations,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.tabStatistics,
          ),
        ],
      ),
    );
  }
}
