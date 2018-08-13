import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:isolate';
import 'image.dart' as util;
import 'dart:math';
import 'package:flutter/services.dart';
import 'search_books.dart';

class CameraWidget extends StatefulWidget {
  CameraWidget({Key key}) : super(key: key);

  @override
  CameraWidgetState createState() => CameraWidgetState();
}

class CameraWidgetState extends State<CameraWidget> {
  CameraController controller;

  // State variables
  bool loading = true;
  bool detecting = false;

  void _setLoading(loading) {
    setState(() {
      this.loading = loading;
    });
  }

  void _setDetecting(detecting) {
    setState(() {
      this.detecting = detecting;
    });
  }

  Future<String> getTempFilePath() async {
    var tempFilePath =
        (await getTemporaryDirectory()).createTempSync('books2go').path;
    tempFilePath = '$tempFilePath/test.jpg';
    File file = File(tempFilePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    return tempFilePath;
  }

  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      controller = CameraController(cameras[0], ResolutionPreset.high);
      controller.initialize().then((_) {
        if (mounted) {
          this._setLoading(false);
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: createBody()
    );
  }

  void detectText() async {
    try {
      String path = await getTempFilePath();
      await controller.takePicture(path);
      _setDetecting(true);
      int angle = await _getImageAngle(path);

      var receivePort = new ReceivePort();
      var map = {"path": path, "angle": angle};
      await Isolate.spawn<Map>(util.rotateImage, map,
          onExit: receivePort.sendPort);

      await receivePort.first;

      FirebaseVisionImage visionImage = FirebaseVisionImage.fromFilePath(path);
      TextDetector detector = FirebaseVision.instance.getTextDetector();
      List<TextBlock> blocks = await detector.detectInImage(visionImage);

      TextBlock largestBlock = blocks.first;
      for (TextBlock block in blocks) {
        if (rectangleArea(block.boundingBox) >
            rectangleArea(largestBlock.boundingBox)) {
          largestBlock = block;
        }
      }
      detector.close();

      String search = "";
      largestBlock.lines.forEach((line) => search += line.text.toString() + " ");
      
      print(search);

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SearchBooksWidget(initialSearch: search)
      ));
    } finally {
      _setDetecting(false);
    }
  }

  int rectangleArea(Rectangle<int> box) {
    return box.width * box.height;
  }

  /// Creates the main body to show using the state variable values
  Widget createBody() {
    if (this.loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Column(children: [
        AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller)),
        Expanded(
            child: Center(
                child: detecting
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        onPressed: detectText,
                        child: Text('SCAN'),
                      )))
      ]);
    }
  }

  static const platform = const MethodChannel('books2go');

  _getImageAngle(String path) async {
    int imageAngle = 0;
    try {
      final int result =
          await platform.invokeMethod('getImageAngle', {"path": path});
      imageAngle = result;
      print("Image angle: '$imageAngle'.");
    } on PlatformException catch (e) {
      print("Failed to get image angle: '${e.message}'.");
    }
    return imageAngle;
  }
}
