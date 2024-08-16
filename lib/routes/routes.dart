import 'package:fb_downloader_webview/downloaded_files/downloaded_files.dart';
import 'package:fb_downloader_webview/main_development.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MyApp();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'downloadedFiles',
          builder: (BuildContext context, GoRouterState state) {
            return const DownloadedFilesScreen();
          },
        ),
      ],
    ),
  ],
);
