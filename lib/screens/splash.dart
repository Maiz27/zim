import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/design_tokens.dart';
import '../utils/navigate.dart';
import 'get_started.dart';
import 'main/browse.dart';

class Splash extends StatefulWidget {
  final bool first;
  const Splash({super.key, required this.first});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _shown = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), changeScreen);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> changeScreen() async {
    final PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      requestPermission();
    } else {
      _goNext();
    }
  }

  Future<void> requestPermission() async {
    if (await Permission.manageExternalStorage.isDenied) {
      if (await Permission.manageExternalStorage
          .request()
          .isPermanentlyDenied) {
        // The user opted to never again see the permission request dialog for
        // this app. The only way to change the permission's status now is to let
        // the user manually enable it in the system settings.
        openAppSettings();
      } else {
        // You can request the permission again.
        requestPermission();
      }
    } else {
      _goNext();
    }
  }

  void _goNext() {
    if (!mounted) return;
    Navigate.pushPageReplacement(
      context,
      widget.first ? const GetStarted() : const Browse(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _shown ? 1 : 0,
            duration: AppMotion.slow,
            curve: AppMotion.enter,
            child: AnimatedScale(
              scale: _shown ? 1 : 0.92,
              duration: AppMotion.slow,
              curve: AppMotion.emphasized,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Image(
                    image: AssetImage('assets/imgs/logo/128px.png'),
                    width: 96,
                    height: 96,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Zim',
                    style: text.headlineSmall?.copyWith(
                      color: scheme.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
