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

  /// Sets progressbar visibility.
  void _setLoading(loading) {
    setState(() {
      this.loading = loading;
    });
  }

  /// Changes state to detecting.
  void _setDetecting(detecting) {
    setState(() {
      this.detecting = detecting;
    });
  }

  /// Returns image path where captured image will be stored.
  Future<String> getTempFilePath() async {
    var tempFilePath =
        (await getTemporaryDirectory()).createTempSync('books2go').path;
    tempFilePath = '$tempFilePath/test.jpg';

    File file = File(tempFilePath);

    // Deletes existing file (if available)
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
    return Scaffold(body: createBody());
  }

  /// Captures image and detects text from it.
  void detectText() async {
    try {
      // Capturing image and storing it at specified path.
      String path = await getTempFilePath();
      await controller.takePicture(path);

      _setDetecting(true);

      // Getting image angle.
      int angle = await _getImageAngle(path);

      var receivePort = new ReceivePort();
      var map = {"path": path, "angle": angle};

      // Rotating image in correct orientation (if rotated).
      await Isolate.spawn<Map>(util.rotateImage, map,
          onExit: receivePort.sendPort);

      await receivePort.first;

      // Reading text from image.
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
      largestBlock.lines
          .forEach((line) => search += line.text.toString() + " ");

      // Redirecting to Search Book screen with found text.
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SearchBooksWidget(initialSearch: search)));
    } finally {
      _setDetecting(false);
    }
  }

  int rectangleArea(Rectangle<int> box) {
    return box.width * box.height;
  }

  /// Creates the main body to show using the state variable values.
  Widget createBody() {
    if (this.loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Stack(
        children: <Widget>[
          SizedBox.expand(
              child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              height: controller.value.previewSize.width,
              width: controller.value.previewSize.height,
              child: CameraPreview(controller),
            ),
          )),
          Align(
            alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white,
            constraints: BoxConstraints.expand(height: 100.0),
            child: Center(
                child: detecting
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        onPressed: detectText,
                        child: Text('Scan'),
                        textColor: Colors.white,
                      )),
          ))
        ],
      );
    }
  }

  static const platform = const MethodChannel('books2go');

  /// Calls native method to get image angle.
  _getImageAngle(String path) async {
    int imageAngle = 0;
    try {
      final int result =
          await platform.invokeMethod('getImageAngle', {"path": path});
      imageAngle = result;
    } on PlatformException catch (e) {
      print("Failed to get image angle: '${e.message}'.");
    }
    return imageAngle;
  }
}
