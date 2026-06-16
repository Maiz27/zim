import 'package:flutter/material.dart';
import 'package:zim/screens/categories/apps.dart';
import 'package:zim/screens/categories/archives.dart';
import 'package:zim/screens/categories/category_one.dart';
import 'package:zim/screens/categories/category_two.dart';
import 'package:zim/screens/categories/downloads.dart';
import 'package:zim/utils/icon_font_helper.dart';

import '../screens/categories/recent.dart';

/// A browseable file category shown on the home grid.
///
/// [screen] is a [WidgetBuilder] (not a pre-built widget) so category screens
/// are constructed lazily on tap rather than eagerly at app start.
class Category {
  const Category({
    required this.title,
    required this.icon,
    required this.color,
    required this.screen,
  });

  final String title;
  final String icon;
  final MaterialColor color;
  final WidgetBuilder screen;
}

class Constants {
  static final List<Category> categories = [
    Category(
      title: 'Images',
      icon: IconFontHelper.img,
      color: Colors.teal,
      screen: (_) => const CategoryOne(title: 'Images'),
    ),
    Category(
      title: 'Videos',
      icon: IconFontHelper.video,
      color: Colors.red,
      screen: (_) => const CategoryOne(title: 'Video'),
    ),
    Category(
      title: 'Documents',
      icon: IconFontHelper.document,
      color: Colors.blue,
      screen: (_) => const CategoryTwo(title: 'Documents'),
    ),
    Category(
      title: 'Audio',
      icon: IconFontHelper.audio,
      color: Colors.pink,
      screen: (_) => const CategoryTwo(title: 'Audio'),
    ),
    Category(
      title: 'Apps',
      icon: IconFontHelper.android,
      color: Colors.green,
      screen: (_) => const Apps(title: 'Apps'),
    ),
    Category(
      title: 'Downloads',
      icon: IconFontHelper.download,
      color: Colors.yellow,
      screen: (_) => const Downloads(title: 'Downloads'),
    ),
    Category(
      title: 'Archives',
      icon: IconFontHelper.archive,
      color: Colors.purple,
      screen: (_) => const Archives(title: 'Archives'),
    ),
    Category(
      title: 'Recent',
      icon: IconFontHelper.recent,
      color: Colors.orange,
      screen: (_) => const Recent(title: 'Recent'),
    ),
  ];

  static List sortList = [
    'File name (A to Z)',
    'File name (Z to A)',
    'Date (oldest first)',
    'Date (newest first)',
    'Size (largest first)',
    'Size (Smallest first)',
  ];
}
