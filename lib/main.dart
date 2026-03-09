import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'view_models/item_view_model.dart';
import 'view_models/location_view_model.dart';
import 'view_models/settings_view_model.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'screens/home_screen.dart';

final SettingsService settingsService = SettingsService();

// 全局访问 key，用于在非 Provider 上下文中获取 SettingsService
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings service first (required by notification service)
  await settingsService.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize(settingsService: settingsService);
  await notificationService.requestPermission();

  runApp(const StorageApp());
}

class StorageApp extends StatelessWidget {
  const StorageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SettingsService>.value(value: settingsService),
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(settingsService),
        ),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(create: (_) => LocationViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            locale: settingsViewModel.appLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            ),
            themeMode: settingsViewModel.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
