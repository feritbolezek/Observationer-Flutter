import 'dart:io';

extension FileExtention on FileSystemEntity {
  String get name {
    String filename = this?.path?.split("/")?.last;
    return filename.substring(0, filename.length - 4);
  }
}
