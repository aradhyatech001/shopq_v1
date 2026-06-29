import 'package:flutter/material.dart';

/// Drop-in replacement for [Image.network] that also renders on Flutter web
/// when the image server does NOT send CORS headers.
///
/// In CanvasKit (the default web renderer) Flutter fetches the image bytes
/// over HTTP and uploads them to a WebGL texture — that fetch is subject to
/// CORS, so a cross-origin image without `Access-Control-Allow-Origin` fails
/// to decode and shows up blank/garbled. [WebHtmlElementStrategy.prefer]
/// makes Flutter render the image directly with a real HTML `<img>` element on
/// web, which displays cross-origin images without needing CORS.
///
/// On mobile/desktop the strategy is ignored, so behaviour there is identical
/// to a plain [Image.network].
class AppNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('IMAGE ERROR: $url');
        debugPrint(error.toString());

        return Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        );
      },
    );

    // return Image.network(
    //   url,
    //   fit: fit,
    //   width: width,
    //   height: height,
    //   errorBuilder: errorBuilder,
    //   loadingBuilder: loadingBuilder,
    //   webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
    // );
  }
}
