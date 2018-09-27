import 'dart:io';
import 'package:image/image.dart';

rotateImage(Map map) async {
  String path = map["path"];
  int angle = map["angle"];

  File file = File(path);

  print('decode start');
  print(path);

  try {
    List<int> bytes = await file.readAsBytes();
    print('bytes : ${bytes.length}');
    Image image = decodeImage(bytes);
    print('decode end');

    image = copyRotate(image, angle);
    print(' rotate end');

    await file.delete();
    await file.writeAsBytes(encodeJpg(image));
    print(' save end');
  } catch (e) {
    print(e);
  }
}
