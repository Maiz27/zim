import 'package:flutter/material.dart';
import 'package:zim/screens/categories/apps.dart';
import 'package:zim/screens/categories/archives.dart';
import 'package:zim/screens/categories/category_one.dart';
import 'package:zim/screens/categories/category_two.dart';
import 'package:zim/screens/categories/downloads.dart';
import 'package:zim/utils/icon_font_helper.dart';

import '../screens/categories/recent.dart';

class Constants {
  static List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  static List categories = [
    {
      'title': 'Images',
      'icon': IconFontHelper.img,
      'path': '',
      'color': Colors.teal,
      'screen': const CategoryOne(
        title: 'Images',
      ),
    },
    {
      'title': 'Videos',
      'icon': IconFontHelper.video,
      'path': '',
      'color': Colors.red,
      'screen': const CategoryOne(
        title: 'Video',
      ),
    },
    {
      'title': 'Documents',
      'icon': IconFontHelper.document,
      'path': '',
      'color': Colors.blue,
      'screen': const CategoryTwo(
        title: 'Documents',
      ),
    },
    {
      'title': 'Audio',
      'icon': IconFontHelper.audio,
      'path': '',
      'color': Colors.pink,
      'screen': const CategoryTwo(
        title: 'Audio',
      ),
    },
    {
      'title': 'Apps',
      'icon': IconFontHelper.android,
      'path': '',
      'color': Colors.green,
      'screen': const Apps(title: 'Apps'),
    },
    {
      'title': 'Downloads',
      'icon': IconFontHelper.download,
      'path': '',
      'color': Colors.yellow,
      'screen': const Downloads(title: 'Downloads'),
    },
    {
      'title': 'Archives',
      'icon': IconFontHelper.archive,
      'path': '',
      'color': Colors.purple,
      'screen': const Archives(title: 'Archives'),
    },
    {
      'title': 'Recent',
      'icon': IconFontHelper.recent,
      'path': '',
      'color': Colors.orange,
      'screen': const Recent(title: 'Recent'),
    },
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
