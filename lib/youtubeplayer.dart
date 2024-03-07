import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YouTubeVideoPlayer extends StatelessWidget {
  final String videoId;

  YouTubeVideoPlayer(this.videoId);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: WebView(
        initialUrl: 'https://www.youtube.com/embed/$videoId',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}