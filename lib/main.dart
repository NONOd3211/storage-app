import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'view_models/item_view_model.dart';
import 'view_models/location_view_model.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'screens/home_screen.dart';

final SettingsService settingsService = SettingsService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings service first (required by notification service)
  await settingsService.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermission();

  runApp(const StorageApp());
}

class StorageApp extends StatelessWidget {
  const StorageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(create: (_) => LocationViewModel()),
      ],
      child: Consumer(
        builder: (context, _, child) {
          return MaterialApp(
            title: '收纳',
            debugShowCheckedModeBanner: false,
            locale: const Locale('zh', 'CN'),
            supportedLocales: const [
              Locale('zh', 'CN'),
            ],
            localizationsDelegates: const [
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
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            themeMode: settingsService.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
