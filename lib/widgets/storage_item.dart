import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../screens/folder/folder.dart';
import '../utils/consts.dart';
import '../utils/file_utils.dart';

class StorageItem extends StatelessWidget {
  final double percent;
  final String title;
  final String path;
  final int usedSpace;
  final int totalSpace;
  final Function onItemChange;
  final List items;

  const StorageItem({
    super.key,
    required this.percent,
    required this.title,
    required this.path,
    required this.usedSpace,
    required this.totalSpace,
    required this.onItemChange,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: (() {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return Folder(
            path: path,
            title: 'Device',
          );
        }));
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
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
              radius: deviceWidth * 0.3,
              lineWidth: 25,
              percent: percent / 100,
              animation: true,
              animationDuration: 1000,
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
                      fontWeight: FontWeight.bold,
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
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: Colors.red,
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
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${FileUtils.formatBytes(totalSpace, 2)} ',
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
