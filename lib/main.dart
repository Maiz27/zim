import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/app_provider.dart';
import 'providers/category_provider.dart';
import 'providers/core_provider.dart';
import 'providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CoreProvider()),
        // CategoryProvider follows SettingsProvider so a show-hidden change
        // invalidates its scan cache without it owning the preference.
        ChangeNotifierProxyProvider<SettingsProvider, CategoryProvider>(
          create: (_) => CategoryProvider(),
          update: (_, settings, category) =>
              category!..applyShowHidden(settings.showHidden),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
