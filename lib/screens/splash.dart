import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/navigate.dart';
import '../utils/theme_config.dart';
import 'get_started.dart';
import 'main/browse.dart';

// ignore: must_be_immutable
class Splash extends StatefulWidget {
  final bool first;
  const Splash({super.key, required this.first});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  startTimeout() {
    return Timer(const Duration(seconds: 2), handleTimeout);
  }

  void handleTimeout() {
    changeScreen();
  }

  changeScreen() async {
    PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      requestPermission();
    } else {
      if (!mounted) return;
      if (!widget.first) {
        Navigate.pushPageReplacement(context, const Browse());
      } else {
        Navigate.pushPageReplacement(context, const GetStarted());
      }
    }
  }

  requestPermission() async {
    if (await Permission.manageExternalStorage.isDenied) {
      if (await Permission.manageExternalStorage
          .request()
          .isPermanentlyDenied) {
        // The user opted to never again see the permission request dialog for this
        // app. The only way to change the permission's status now is to let the
        // user manually enable it in the system settings.
        openAppSettings();
      } else {
        // You can request the permission again.
        requestPermission();
      }
    } else {
      if (!mounted) return;
      if (!widget.first) {
        Navigate.pushPageReplacement(context, const Browse());
      } else {
        Navigate.pushPageReplacement(context, const GetStarted());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    startTimeout();
    SchedulerBinding.instance.addPostFrameCallback((_) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Image(image: AssetImage('assets/imgs/logo/128px.png')),
            const SizedBox(height: 5),
            Text(
              'Zim',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
