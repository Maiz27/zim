import 'package:flutter/material.dart';

import '../../widgets/app_drawer.dart';
import '../../widgets/empty_state.dart';

class Share extends StatelessWidget {
  const Share({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Share')),
      drawer: const AppDrawer(),
      body: const EmptyState(
        icon: Icons.ios_share,
        title: 'Coming soon',
        message: 'Sharing files from Zim is on the way.',
      ),
    );
  }
}
