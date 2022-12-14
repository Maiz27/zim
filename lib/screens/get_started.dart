import 'package:flutter/material.dart';
import 'package:zim/screens/main/browse.dart';
import 'package:zim/utils/icon_font_helper.dart';
import 'package:zim/widgets/icon_font.dart';

import '../utils/navigate.dart';
import '../utils/theme_config.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: deviceWidth,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned(
              top: deviceHeight * 0.1,
              left: deviceWidth * 0.05,
              child: const Text(
                'Zim',
                style: TextStyle(
                  // color: ThemeConfig.primary,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ),
            Positioned(
              top: deviceHeight * 0.12,
              left: -20,
              child: IconFont(
                iconName: IconFontHelper.folder,
                color: ThemeConfig.accent,
                size: deviceWidth + 35,
              ),
            ),
            Positioned(
              top: deviceHeight * 0.27,
              left: -20,
              child: IconFont(
                iconName: IconFontHelper.folder,
                color: ThemeConfig.secondary,
                size: deviceWidth + 35,
              ),
            ),
            Positioned(
              top: deviceHeight * 0.42,
              left: -20,
              child: IconFont(
                iconName: IconFontHelper.folder,
                color: ThemeConfig.primary,
                size: deviceWidth + 35,
              ),
            ),
            Positioned(
              top: deviceHeight * 0.57,
              left: -20,
              child: IconFont(
                iconName: IconFontHelper.folder,
                color: ThemeConfig.accent2,
                size: deviceWidth + 35,
              ),
            ),
            Positioned(
              bottom: deviceHeight * 0.15,
              child: SizedBox(
                width: deviceWidth * 0.9,
                child: Column(children: [
                  Text(
                    'The easiest way to manage your data.',
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ThemeConfig.lightBg,
                      fontSize: 30,
                      letterSpacing: 3,
                      wordSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'A file manager to make your life easier.',
                    softWrap: true,
                    style: TextStyle(
                      color: ThemeConfig.lightBg.withOpacity(0.8),
                      fontSize: 15,
                      letterSpacing: 1,
                      wordSpacing: 1,
                    ),
                  ),
                ]),
              ),
            ),
            Positioned(
              bottom: deviceHeight * 0.04,
              right: deviceWidth * 0.1,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => ThemeConfig.lightBg),
                  padding: MaterialStateProperty.resolveWith(
                      (states) => const EdgeInsets.all(20)),
                  shape: MaterialStateProperty.resolveWith(
                    (states) => const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                ),
                onPressed: () {
                  Navigate.pushPageReplacement(context, const Browse());
                },
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    color: ThemeConfig.darkBg,
                    fontSize: 20,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
