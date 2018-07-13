import 'dart:io';
import 'package:image/image.dart';

rotateImage(String path) async {
    File file = File(path);
    print('decode start');
    List<int> bytes = await file.readAsBytes();
    print('bytes : ${bytes.length}');
    Image image = decodeJpg(bytes);
    print('decode end');
    image = copyRotate(image, 90.0);
    print(' rotate end');

    await file.delete();
    await file.writeAsBytes(encodeJpg(image));
    print(' save end');

  }