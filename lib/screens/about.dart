import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zim/widgets/icon_font.dart';

import '../utils/design_tokens.dart';
import '../utils/icon_font_helper.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var url = Uri.parse('https://github.com/Maiz27');
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.1),
                borderRadius: AppRadius.brXl,
              ),
              child: const Image(
                image: AssetImage('assets/imgs/logo/512px.png'),
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'A simple file manager made with Flutter by\n',
                style: text.bodyMedium?.copyWith(
                  letterSpacing: 1,
                  color: scheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: 'Maged Faiz Ismail',
                    style: text.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.xs,
                      ),
                      child: InkWell(
                        onTap: () async {
                          _launchInBrowser(url);
                        },
                        child: IconFont(
                          size: 18,
                          iconName: IconFontHelper.link,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.1),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Fluttertoast.showToast(msg: 'Could not launch $url');
    }
  }
}
