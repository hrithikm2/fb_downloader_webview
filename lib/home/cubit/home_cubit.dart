// import 'dart:ui';

// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';

// part 'home_state.dart';

// class HomeCubit extends Cubit<HomeState> {
//   HomeCubit() : super(HomeInitial()) {
//     setup(); // Setup Using Initial Method Calls.
//   }


//   void _bindBackgroundIsolate() {
//     final isSuccess = IsolateNameServer.registerPortWithName(
//       _port.sendPort,
//       'downloader_send_port',
//     );
//     if (!isSuccess) {
//       _unbindBackgroundIsolate();
//       _bindBackgroundIsolate();
//       return;
//     }

//     _port.listen((dynamic data) async {
//       String id = data[0] as String;
//       DownloadTaskStatus status = DownloadTaskStatus.values[data[1] as int];
//       int progress = data[2] as int;

//       if (status == DownloadTaskStatus.complete) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         var downloadedFiles = await prefs.getStringList(downloadedFilesList);
//         if (downloadedFiles != null) {
//           downloadedFiles.add(downloadPath + '/' + fileName);
//           await prefs.setStringList(downloadedFilesList, downloadedFiles);
//         }
//         context.go
//       }
//     });

//     FlutterDownloader.registerCallback(downloadCallback);
//   }

//   Future<void> setup() async {
//     await _bindBackgroundIsolate();
//   }


// }
