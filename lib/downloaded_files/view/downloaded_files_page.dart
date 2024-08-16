import 'dart:convert';

import 'package:fb_downloader_webview/main_development.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class DownloadedFilesScreen extends StatefulWidget {
  const DownloadedFilesScreen({super.key});

  @override
  State<DownloadedFilesScreen> createState() => _DownloadedFilesScreenState();
}

class _DownloadedFilesScreenState extends State<DownloadedFilesScreen> {
  List<String> downloadedFiles = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      downloadedFiles = prefs.getStringList(downloadedFilesPrefKey) ?? [];
    });
  }

  Future<Uint8List?> getVideoThumbnail(String filePath) async {
    final thumbnailBytes = await VideoThumbnail.thumbnailData(
      video: filePath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 25,
    );
    return thumbnailBytes;
  }

  @override
  Widget build(BuildContext context) {
    print(downloadedFiles.length);
    return Scaffold(
      appBar: AppBar(
        title: Text('Downloaded Files'),
        backgroundColor: Colors.cyan,
      ),
      body: ListView.separated(
        itemCount: downloadedFiles.length,
        itemBuilder: (context, index) {
          final element =
              (jsonDecode(downloadedFiles[index]) as Map<String, dynamic>);
          return ListTile(
            leading: FutureBuilder<Uint8List?>(
              future: getVideoThumbnail(element['path'].toString()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        image:
                            DecorationImage(image: MemoryImage(snapshot.data!)),
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            title: Text(
              element['fileName'].toString(),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.shareXFiles([XFile(element['path'].toString())]);
              },
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(
          height: 10,
        ),
      ),
    );
  }
}
