import 'package:flutter/material.dart';
import 'package:zim/utils/icon_font_helper.dart';

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
    },
    {
      'title': 'Videos',
      'icon': IconFontHelper.video,
      'path': '',
      'color': Colors.red,
    },
    {
      'title': 'Documents',
      'icon': IconFontHelper.document,
      'path': '',
      'color': Colors.blue,
    },
    {
      'title': 'Audio',
      'icon': IconFontHelper.audio,
      'path': '',
      'color': Colors.pink,
    },
    {
      'title': 'Apps',
      'icon': IconFontHelper.android,
      'path': '',
      'color': Colors.green,
    },
    {
      'title': 'Downloads',
      'icon': IconFontHelper.download,
      'path': '',
      'color': Colors.yellow,
    },
    {
      'title': 'Archive',
      'icon': IconFontHelper.archive,
      'path': '',
      'color': Colors.purple,
    },
    {
      'title': 'Recent',
      'icon': IconFontHelper.recent,
      'path': '',
      'color': Colors.orange,
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
