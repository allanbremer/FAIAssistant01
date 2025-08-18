
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<bool> checkAS9102FileExists() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('\${directory.path}/as9102.pdf');
  return await file.exists();
}
