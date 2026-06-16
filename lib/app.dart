import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zim/providers/core_provider.dart';

import 'providers/app_provider.dart';
import 'screens/ios_error.dart';
import 'screens/splash.dart';
import 'utils/theme_config.dart';

bool? isFirst;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    isFirstLaunch();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<CoreProvider>(context, listen: false).checkSpace();
    });
  }

  Future<void> isFirstLaunch() async {
    final preferences = await SharedPreferences.getInstance();
    final first = preferences.getBool('first_time');
    isFirst = first;
    if (first == null) {
      preferences.setBool('first_time', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, appProvider, Widget? child) {
        return MaterialApp(
          key: appProvider.key,
          debugShowCheckedModeBanner: false,
          navigatorKey: appProvider.navigatorKey,
          title: 'Zim',
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          themeMode: appProvider.themeMode,
          builder: (context, child) {
            // Edge-to-edge: transparent system bars whose icons contrast the
            // resolved theme brightness (handles ThemeMode.system correctly).
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final overlay =
                (isDark
                        ? SystemUiOverlayStyle.light
                        : SystemUiOverlayStyle.dark)
                    .copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: Colors.transparent,
                      systemNavigationBarContrastEnforced: false,
                    );
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlay,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: Platform.isIOS
              ? const IosError()
              : Splash(first: isFirst ?? true),
        );
      },
    );
  }
}
