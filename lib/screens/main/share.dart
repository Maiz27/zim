import 'package:flutter/material.dart';

import '../../widgets/app_drawer.dart';

class Share extends StatelessWidget {
  const Share({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Share',
        ),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          'Coming Soon!!!',
        ),
      ),
    );
  }
}
