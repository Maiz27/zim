import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../screens/folder.dart';
import '../../utils/consts.dart';
import '../../utils/file_utils.dart';
import '../../utils/navigate.dart';
import '../../utils/theme_config.dart';

class StorageItem extends StatelessWidget {
  final double percent;
  final String title;
  final String path;
  final int usedSpace;
  final int freeSpace;
  final Function onItemChange;
  final List items;

  const StorageItem({
    super.key,
    required this.percent,
    required this.title,
    required this.path,
    required this.usedSpace,
    required this.freeSpace,
    required this.onItemChange,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: (() {
        Navigate.pushPage(context, Folder(path: path, title: title));
      }),
      child: Column(
        children: [
          DropdownButton(
            value: title,
            items: Constants.map(
              items,
              (index, value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: ThemeConfig.primary,
                      )),
                );
              },
            ),
            onChanged: ((value) {
              onItemChange(value);
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CircularPercentIndicator(
              progressColor: Theme.of(context).progressIndicatorTheme.color,
              radius: deviceWidth * 0.3,
              lineWidth: 25,
              percent: percent / 100,
              animation: true,
              animationDuration: 1000,
              backgroundColor: Color(Theme.of(context)
                  .progressIndicatorTheme
                  .circularTrackColor!
                  .value),
              circularStrokeCap: CircularStrokeCap.round,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    'Used',
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: deviceHeight * 0.08,
            width: deviceWidth * 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: ThemeConfig.primary,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          'Used',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${FileUtils.formatBytes(usedSpace, 2)} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: Theme.of(context)
                              .progressIndicatorTheme
                              .circularTrackColor),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          'Free',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${FileUtils.formatBytes(freeSpace, 2)} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
