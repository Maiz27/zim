import 'package:flutter/material.dart';

import '../../utils/consts.dart';
import 'category_item.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: Constants.categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final category = Constants.categories[index];
            return CategoryItem(
              title: category['title'],
              color: category['color'],
              icon: category['icon'],
              screen: category['screen'],
            );
          },
        ),
      ),
    );
  }
}
