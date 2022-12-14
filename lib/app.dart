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

// ignore: prefer_typing_uninitialized_variables
var isFirst;

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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoreProvider>(context, listen: false).checkSpace();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).primaryColor,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness:
            Theme.of(context).primaryColor == ThemeConfig.darkTheme.primaryColor
                ? Brightness.light
                : Brightness.dark,
      ));
    });
  }

  isFirstLaunch() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var first = preferences.getBool('first_time');
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
          theme: appProvider.theme,
          darkTheme: ThemeConfig.darkTheme,
          // home: const GetStarted(),
          home: Platform.isIOS
              ? const IosError()
              : Splash(
                  first: isFirst ?? true,
                ),
        );
      },
    );
  }
}
