import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../utils/consts.dart';

class SortSheet extends StatefulWidget {
  const SortSheet({super.key});

  @override
  State<SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<SortSheet> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 15,
            ),
            Text(
              'Sort by'.toUpperCase(),
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Flexible(
              child: ListView.builder(
                itemCount: Constants.sortList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () async {
                      await Provider.of<CategoryProvider>(context,
                              listen: false)
                          .setSort(index);
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    trailing: index ==
                            Provider.of<CategoryProvider>(context,
                                    listen: false)
                                .sort
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          )
                        : const SizedBox(),
                    title: Text(
                      '${Constants.sortList[index]}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: index ==
                                Provider.of<CategoryProvider>(context,
                                        listen: false)
                                    .sort
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.headline6!.color,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
