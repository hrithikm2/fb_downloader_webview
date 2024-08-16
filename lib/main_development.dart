import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fb_downloader_webview/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const downloadedFilesPrefKey = 'downloadedFilesList';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await InAppWebViewController.setWebContentsDebuggingEnabled(false);

  // Plugin must be initialized before usingy
  await FlutterDownloader.initialize();

  runApp(MaterialApp.router(
    routerConfig: router,
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  late String fileName;
  String downloadPath = '';
  late bool hasStoragePermission, hasNotificationPermission;
  late SharedPreferences prefs;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    _getPermissions();
    _bindBackgroundIsolate();
  }

  Future<void> _getPermissions() async {
    prefs = await SharedPreferences.getInstance();
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    final androidInfo = await plugin.androidInfo;

    if (androidInfo.version.sdkInt < 33) {
      hasStoragePermission = await Permission.storage.isGranted;
      if (!hasStoragePermission) {
        final status = await Permission.storage.request();
        hasStoragePermission = status.isGranted;
      }
    } else {
      hasStoragePermission = await Permission.manageExternalStorage.isGranted;
      if (!hasStoragePermission) {
        final status = await Permission.manageExternalStorage.request();
        hasStoragePermission = status.isGranted;
      }
    }

    hasNotificationPermission = await Permission.notification.isGranted;
    if (!hasNotificationPermission) {
      final status = await Permission.notification.request();
      hasNotificationPermission = status.isGranted;
    }

    if (!hasStoragePermission) {
      final status = await Permission.manageExternalStorage.request();
      hasStoragePermission = status.isGranted;
    }
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port.close();
  }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) {
      setState(() {
        String id = data[0] as String;
        DownloadTaskStatus status = DownloadTaskStatus.values[data[1] as int];
        int progress = data[2] as int;
        downloadProgress = progress / 100;
        if (status == DownloadTaskStatus.complete) {
          //var downloadedFiles = prefs.getStringList(downloadedFilesPrefKey) ?? [];
          print(downloadPath + '/' + fileName);

          try {
            Share.shareXFiles([XFile(downloadPath + '/' + fileName)]);
          } catch (e, s) {
            log('cannot share file', error: e, stackTrace: s);
          }

          hasDownloadStarted = false;

          // final downloadedFileJson = jsonEncode(
          //         {'fileName': fileName, 'path': downloadPath + '/' + fileName})
          //     .toString();
          // downloadedFiles.add(downloadedFileJson);
          // print("DOWNLOADED FILES LIST YE RAHI:: $downloadedFiles");
          // prefs
          //     .setStringList(downloadedFilesPrefKey, downloadedFiles)
          //     .then((value) {
          //   print("HORA NAHI KYA GOO");
          //   context.go('/downloadedFiles');
          // });
        }
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  bool hasDownloadStarted = false;

  double downloadProgress = 0;

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    log('Download progress :: $progress');

    send?.send([id, status, progress]);
  }

  void shareFile() {
    print(downloadPath + "/" + fileName + ".mp4");
  }

  void handleClick(int item) async {
    switch (item) {
      case 0:
        await webViewController?.loadUrl(
            urlRequest: URLRequest(
                url: WebUri("https://proof.ovh.net/files/10Mb.dat")));
        break;
      case 1:
        await webViewController?.loadUrl(
            urlRequest: URLRequest(
                url: WebUri(
                    "https://www.w3schools.com/tags/tryit.asp?filename=tryhtml5_a_download")));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {},
        child: Scaffold(
            body: Column(children: <Widget>[
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri("https://fdown.net")),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              shouldInterceptRequest: (controller, request) async {
                // Check if the URL is an ad
                if (_isAd(request.url.toString())) {
                  // Block ad requests by returning a WebResourceResponse with an empty response
                  return WebResourceResponse(
                    statusCode: 200,
                    data: Uint8List.fromList([]),
                    headers: {"Content-Type": "text/html"},
                  );
                }
                // Allow non-ad requests
                return null;
              },
              onDownloadStartRequest: (controller, downloadStartRequest) async {
                fileName = downloadStartRequest.suggestedFilename ??
                    Uuid().v4.toString() + '.mp4';

                await downloadFile(
                    downloadStartRequest.url.toString(), fileName);
              },
            ),
          ),
          if (hasDownloadStarted) ...[
            Container(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  'Download Started',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                subtitle: LinearProgressIndicator(
                  value: downloadProgress,
                ),
                trailing: Text(
                  (downloadProgress * 100).toStringAsFixed(0) + '%',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          ]
        ])),
      ),
    );
  }

  Future<void> downloadFile(String url, [String? filename]) async {
    await getExternalStorageDirectory().then((extDir) {
      print(extDir);
      if (extDir != null && downloadPath.isEmpty) {
        final extDirIterable = extDir.path.split('/');
        print(extDirIterable);
        for (int i = 0; i < extDirIterable.length; i++) {
          var item = extDirIterable[i];
          if (item.trim() == 'Android') {
            downloadPath = downloadPath + '/Download';
            return;
          }
          if (i == 0) {
            continue;
          }
          downloadPath = downloadPath + '/$item';
        }
      }
    });

    print(downloadPath);

    if (hasStoragePermission) {
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: downloadPath,
        saveInPublicStorage: true,
        showNotification: hasNotificationPermission,
        fileName: filename,
      );
    }
    if (mounted) {
      setState(() {
        hasDownloadStarted = true;
      });
    }

    return;
  }

  bool _isAd(String url) {
    // Implement your ad detection logic here
    // This is just a placeholder implementation
    if (url.contains('adserver') ||
        url.contains('doubleclick') ||
        url.contains('googleads')) {
      return true;
    }
    return false;
  }
}
