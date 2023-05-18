import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

class WebviewWrapper extends StatefulWidget {
  final String initUrl;

  const WebviewWrapper({required this.initUrl});

  @override
  State<WebviewWrapper> createState() => _WebviewWrapperState();
}

class _WebviewWrapperState extends State<WebviewWrapper> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadRequest(Uri.parse(widget.initUrl));
    controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) {
        setState(() {
          isLoading = false;
        });
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(
          controller: controller,
        ),
        isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(),
      ],
    );
  }
}
