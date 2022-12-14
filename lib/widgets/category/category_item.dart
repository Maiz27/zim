import 'package:flutter/material.dart';
import 'package:zim/utils/navigate.dart';

import '../icon_font.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String icon;
  final MaterialColor color;
  final Widget screen;

  const CategoryItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.screen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    // var deviceWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Navigate.pushPage(context, screen);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: deviceHeight * 0.08,
            decoration: BoxDecoration(
              color: color[200],
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Center(
              child: IconFont(
                iconName: icon,
                size: 30,
                color: color[700],
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
