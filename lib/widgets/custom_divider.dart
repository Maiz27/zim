import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 1,
            color: Theme.of(context).dividerColor,
            width: size.width,
          ),
        ),
      ],
    );
  }
}
