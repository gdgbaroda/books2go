import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'nav_drawer.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image/image.dart' as ImageLibrary;
import 'dart:isolate';
import 'image.dart' as util;
import 'dart:math';

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
  Widget detectingImage;
  String detectedText;

  void _setLoading(loading) {
    setState(() {
      this.loading = loading;
    });
  }

  void _setDetecting(detecting, Widget image, String detected) {
    setState(() {
      this.detecting = detecting;
      this.detectingImage = image;
      this.detectedText = detected;
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
      controller = CameraController(cameras[0], ResolutionPreset.low);
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
      appBar: AppBar(
        title: Text('Camera View'),
      ),
      body: createBody(),
      drawer: NavDrawer(),
    );
  }

  void detectText() async {
    try {
      String path = await getTempFilePath();
      await controller.takePicture(path);
      _setDetecting(true, CircularProgressIndicator(), 'Detecting...');
      List<int> bytes = await (File(path)).readAsBytes();
      Widget image = Image.memory(bytes);
      _setDetecting(true, image, 'Detecting...');

      var receivePort = new ReceivePort();
      await Isolate.spawn<String>(util.rotateImage, path,
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
      _setDetecting(true, image, largestBlock?.text);
    } catch (e) {
      _setDetecting(false, null, null);
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
        detectingImage ??
            AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller)),
        Expanded(
            child: Center(
                child: detectedText != null
                    ? Text(detectedText)
                    : RaisedButton(
                        onPressed: detectText, child: Text('Detect'))))
      ]);
    }
  }
}
