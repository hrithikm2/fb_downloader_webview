import 'package:equatable/equatable.dart';

sealed class DownloadedFilesState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class DownloadedFilesInitial extends DownloadedFilesState {}
