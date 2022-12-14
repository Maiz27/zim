import 'package:flutter/material.dart';

import '../../utils/consts.dart';
import 'category_item.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        height: deviceHeight * 0.3,
        width: deviceWidth * 0.9,
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor.withOpacity(0.1),
          borderRadius: const BorderRadius.all(
            Radius.circular(40),
          ),
        ),
        child: GridView.count(
          crossAxisCount: 4,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 7 / 10,
          children: List.generate(
            Constants.categories.length,
            (index) => CategoryItem(
              title: Constants.categories[index]['title'],
              color: Constants.categories[index]['color'],
              icon: Constants.categories[index]['icon'],
              screen: Constants.categories[index]['screen'],
            ),
          ),
        ),
      ),
    );
  }
}
