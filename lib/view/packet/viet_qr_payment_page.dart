import 'dart:io';

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview_mobile;
import 'package:webview_windows/webview_windows.dart' as webview_windows;

import '../../constants/app_color.dart';
import '../../widget/base_page.dart';
import '../web_view/my_web_view_page.dart';

class VietQRPaymentPage extends StatefulWidget {
  final String paymentUrl;
  const VietQRPaymentPage({super.key, required this.paymentUrl});

  @override
  State<VietQRPaymentPage> createState() => _VietQRPaymentPageState();
}

class _VietQRPaymentPageState extends State<VietQRPaymentPage> {
  webview_mobile.WebViewController? _webViewControllerMobile;
  webview_windows.WebviewController? _webViewControllerWindows;

  Widget? _title;
  double _progress = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    Platform.isAndroid || Platform.isIOS ? _initMobile() : _initWindows();
  }

  void _initMobile() {
    try {
      _webViewControllerMobile = webview_mobile.WebViewController();
      _webViewControllerMobile!
        ..setJavaScriptMode(webview_mobile.JavaScriptMode.unrestricted)
        ..enableZoom(true)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          webview_mobile.NavigationDelegate(
            onProgress: (p) {
              if (mounted) {
                setState(() {
                  _progress = p / 100;
                });
              }
            },
            onPageFinished: (String url) async {
              String? titleString = await _webViewControllerMobile!.getTitle();
              if (mounted) {
                if (titleString.isNotEmptyAndNotNull) {
                  setState(() {
                    _title = Text(
                      titleString!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    );
                  });
                }
              }
            },
          ),
        );
      loadPaymentUrl();
    } catch (_) {}
  }

  Future<void> _initWindows() async {
    try {
      _webViewControllerWindows = webview_windows.WebviewController();
      await _webViewControllerWindows!.initialize();
      _webViewControllerWindows!.setBackgroundColor(const Color(0x00000000));
      await _webViewControllerWindows!
          .setPopupWindowPolicy(webview_windows.WebviewPopupWindowPolicy.deny);
      _webViewControllerWindows!.title.listen((titleString) {
        setState(() {
          if (titleString.isNotEmpty) {
            setState(() {
              _title = Text(
                titleString,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              );
            });
          }
        });
      });
      _webViewControllerWindows!.loadingState.listen((state) {
        if (state == webview_windows.LoadingState.loading) {
          setState(() => _progress = 0.2);
        } else if (state == webview_windows.LoadingState.navigationCompleted) {
          setState(() => _progress = 1);
        }
      });
      loadPaymentUrl();
    } catch (_) {}
  }

  Future<void> loadPaymentUrl() async {
    _progress = 0;
    if (Platform.isAndroid || Platform.isIOS) {
      await _webViewControllerMobile?.loadRequest(Uri.parse(widget.paymentUrl));
    } else {
      await _webViewControllerWindows?.loadUrl(widget.paymentUrl);
    }
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: _title ?? 'Đang tải...',
      body: Column(
        children: [
          if (_progress > 0 && _progress < 1)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white,
              valueColor:
                  const AlwaysStoppedAnimation(AppColor.unSelectedLabel2),
            ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: _webViewControllerMobile != null
                  ? webview_mobile.WebViewWidget(
                      controller: _webViewControllerMobile!)
                  : _webViewControllerWindows != null && _isInitialized
                      ? webview_windows.Webview(
                          _webViewControllerWindows!,
                          permissionRequested: _onPermissionRequested,
                        )
                      : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Future<webview_windows.WebviewPermissionDecision> _onPermissionRequested(
      String url,
      webview_windows.WebviewPermissionKind kind,
      bool isUserInitiated) async {
    final decision =
        await showDialog<webview_windows.WebviewPermissionDecision>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission \'$kind\''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
                context, webview_windows.WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
                context, webview_windows.WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? webview_windows.WebviewPermissionDecision.none;
  }
}
