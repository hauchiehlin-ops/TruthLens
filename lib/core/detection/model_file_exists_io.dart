import 'dart:io';

Future<bool> modelFileExists(String path) async => File(path).existsSync();
