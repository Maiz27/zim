import 'package:flutter/material.dart';

/// Brand palette anchors. Single source of truth for the seed + accents.
///
/// Zim's identity is teal. Every neutral in the themes is tinted toward this
/// hue so the app never reads as flat grey.
class AppPalette {
  AppPalette._();

  /// Brand / seed colour.
  static const Color teal = Color(0xFF11999E);

  /// Bright accent used for brand moments (hero, highlights).
  static const Color tealBright = Color(0xFF30E3CA);

  /// Cool secondary.
  static const Color blue = Color(0xFF406882);

  /// Deep brand shade for layered backdrops.
  static const Color navy = Color(0xFF1A374D);

  /// Tinted near-black surface for dark theme.
  static const Color ink = Color(0xFF11181C);

  /// Tinted near-white surface for light theme.
  static const Color mist = Color(0xFFE7F6F3);
}

/// 4pt spacing scale. Use these instead of ad-hoc EdgeInsets numbers.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Default horizontal page inset.
  static const double page = 16;

  static const EdgeInsets pageInsets = EdgeInsets.symmetric(horizontal: page);
}

/// Corner radii. Calm, slightly friendly rounding aligned to Material 3 shapes.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 28;

  static const Radius rSm = Radius.circular(sm);
  static const Radius rMd = Radius.circular(md);
  static const Radius rLg = Radius.circular(lg);
  static const Radius rXl = Radius.circular(xl);
  static const Radius rXxl = Radius.circular(xxl);

  static const BorderRadius brSm = BorderRadius.all(rSm);
  static const BorderRadius brMd = BorderRadius.all(rMd);
  static const BorderRadius brLg = BorderRadius.all(rLg);
  static const BorderRadius brXl = BorderRadius.all(rXl);
  static const BorderRadius brXxl = BorderRadius.all(rXxl);
}

/// Motion tokens. The whole app shares one rhythm: calm ease-out, no bounce.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);

  /// Per-item delay when staggering list/grid entrances.
  static const Duration stagger = Duration(milliseconds: 45);

  /// Entering elements decelerate; calm, never springy.
  static const Curve enter = Curves.easeOutCubic;

  /// Exiting elements accelerate away (shorter than enter).
  static const Curve exit = Curves.easeInCubic;

  /// Emphasised easing for hero / shared transitions.
  static const Curve emphasized = Curves.easeOutQuart;
}

/// Semantic file categories used to colour and icon file rows/tiles.
enum FileKind {
  image,
  video,
  audio,
  document,
  pdf,
  archive,
  apk,
  code,
  text,
  download,
  folder,
  generic,
}

/// A brightness-aware icon + tinted-container colour pair for a file kind.
class FileColors {
  const FileColors({required this.icon, required this.container});

  final Color icon;
  final Color container;
}

/// Resolves calm, theme-aware colours for each [FileKind].
///
/// Each kind has one base hue; the icon is darkened slightly in light mode and
/// lightened in dark mode for contrast, and the container is the same hue at a
/// low alpha so glyphs sit on a soft tonal chip rather than a raw colour.
class FilePalette {
  FilePalette._();

  static const Map<FileKind, Color> _base = {
    FileKind.image: Color(0xFF11999E), // brand teal
    FileKind.video: Color(0xFFE0567B), // calm rose
    FileKind.audio: Color(0xFFC2569C), // muted magenta
    FileKind.document: Color(0xFF3E7CB1), // slate blue
    FileKind.pdf: Color(0xFFD2544B), // soft red
    FileKind.archive: Color(0xFF8A6FC4), // muted violet
    FileKind.apk: Color(0xFF4FA972), // calm green
    FileKind.code: Color(0xFF5E83A6), // blue-grey
    FileKind.text: Color(0xFF4F8DA8), // dusty cyan-blue
    FileKind.download: Color(0xFF3FA7C4), // sky
    FileKind.folder: Color(0xFF11999E), // brand teal
    FileKind.generic: Color(0xFF6B7C85), // tinted neutral
  };

  static FileColors of(FileKind kind, Brightness brightness) {
    final base = _base[kind] ?? _base[FileKind.generic]!;
    final isDark = brightness == Brightness.dark;
    final icon = isDark
        ? Color.lerp(base, Colors.white, 0.34)!
        : Color.lerp(base, Colors.black, 0.12)!;
    final container = base.withValues(alpha: isDark ? 0.24 : 0.14);
    return FileColors(icon: icon, container: container);
  }
}
