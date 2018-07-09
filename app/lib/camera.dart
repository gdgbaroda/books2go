import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'nav_drawer.dart';

class CameraWidget extends StatefulWidget {
  CameraWidget({Key key}) : super(key: key);

  @override
  CameraWidgetState createState() => CameraWidgetState();
}

class CameraWidgetState extends State<CameraWidget> {
  CameraController controller;

  // State variables
  bool loading = true;

  void _setLoading(loading) {
    setState(() {
      this.loading = loading;
    });
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
      appBar: AppBar(
        title: Text('Camera View'),
      ),
      body: Center(
        child: Column(
          children: this.createBody(),
        ),
      ),
      drawer: NavDrawer(),
    );
  }

  /// Creates the main body to show using the state variable values
  List<Widget> createBody() {
    var children = <Widget> [];
      
    if (this.loading) {
      children.add(CircularProgressIndicator());
    } else {
      children.add(AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: new CameraPreview(controller)
      ));
    }

    return children;
  }
}
