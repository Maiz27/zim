import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zim/widgets/icon_font.dart';

import '../utils/icon_font_helper.dart';
import '../utils/theme_config.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var url = Uri.parse('https://github.com/Maiz27');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor.withOpacity(0.1),
                borderRadius: const BorderRadius.all(
                  Radius.circular(40),
                ),
              ),
              child: const Image(
                image: AssetImage('assets/imgs/logo/512px.png'),
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'A simple file manager made with Flutter by\n',
                  style: TextStyle(
                    fontSize: 15,
                    letterSpacing: 1,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                  children: [
                    TextSpan(
                      text: 'Maged Faiz Ismail',
                      style: TextStyle(
                        color: ThemeConfig.accent,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 5.0,
                        ),
                        child: InkWell(
                          onTap: () async {
                            _launchInBrowser(url);
                          },
                          child: IconFont(
                            size: 18,
                            iconName: IconFontHelper.link,
                            color: ThemeConfig.accent,
                          ),
                        ),
                      ),
                    )
                  ]),
            ),
            SizedBox(
              height: height * 0.1,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      Fluttertoast.showToast(msg: 'Could not launch $url');
    }
  }
}
