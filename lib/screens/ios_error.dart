import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

class IosError extends StatelessWidget {
  const IosError({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyState(
        icon: Icons.desktop_access_disabled_outlined,
        title: 'Android only',
        message:
            'This app only works on Android. Please run on an android device!',
      ),
    );
  }
}
