import 'dart:io';
import 'package:image/image.dart';

rotateImage(Map map) async {
  String path = map["path"];
  int angle = map["angle"];

  File file = File(path);

  //print('decode start');
  List<int> bytes = await file.readAsBytes();
  //print('bytes : ${bytes.length}');
  Image image = decodeJpg(bytes);
  //print('decode end');

  image = copyRotate(image, angle);
  //print(' rotate end');

  await file.delete();
  await file.writeAsBytes(encodeJpg(image));
  //print(' save end');
}
