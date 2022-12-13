import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatefulWidget {
  final String path;
  const VideoThumbnail({super.key, required this.path});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail>
    with AutomaticKeepAliveClientMixin {
  String thumb = '';
  bool loading = true;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            loading = false;
          }); //when your thumbnail will show.
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loading
        ? Image.asset(
            'assets/imgs/video-placeholder.png',
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          )
        : VideoPlayer(_controller);
  }

  @override
  bool get wantKeepAlive => true;
}
