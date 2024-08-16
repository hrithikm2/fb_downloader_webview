import 'package:bloc/bloc.dart';
import 'package:fb_downloader_webview/downloaded_files/cubit/downloaded_files_state.dart';

class CounterCubit extends Cubit<DownloadedFilesState> {
  CounterCubit() : super(DownloadedFilesInitial());
}
