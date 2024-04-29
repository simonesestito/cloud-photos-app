import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';

///
/// Abstraction for both [XFile] and [PlatformFile] to be used in the app.
///
abstract class AppFile {
  String get name;

  Future<List<int>> readBytes();

  factory AppFile.fromXFile(XFile xFile) => _XFileAppFile(xFile);

  factory AppFile.fromPlatformFile(PlatformFile platformFile) =>
      _PlatformFileAppFile(platformFile);
}

class _XFileAppFile implements AppFile {
  final XFile _xFile;

  _XFileAppFile(this._xFile);

  @override
  String get name => _xFile.name;

  @override
  Future<List<int>> readBytes() => _xFile.readAsBytes();
}

class _PlatformFileAppFile implements AppFile {
  final PlatformFile _platformFile;

  _PlatformFileAppFile(this._platformFile);

  @override
  String get name => _platformFile.name;

  @override
  Future<List<int>> readBytes() => Future.value(_platformFile.bytes!);
}
