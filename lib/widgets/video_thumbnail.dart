import 'package:flutter/material.dart';

import '../utils/design_tokens.dart';

/// Edge length of the list-row video thumbnail (matches the file-icon chip).
const double _kThumbSize = 40;

class VideoThumbnail extends StatefulWidget {
  final String path;
  const VideoThumbnail({super.key, required this.path});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ClipRRect(
      borderRadius: AppRadius.brMd,
      child: Image.asset(
        'assets/imgs/video-placeholder.png',
        height: _kThumbSize,
        width: _kThumbSize,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
