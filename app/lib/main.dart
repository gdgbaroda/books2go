import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'login.dart';
import 'camera.dart';
import 'root_context.dart';
import 'auth.dart';

void main() => runApp(new App());

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  FirebaseUser user;
  StreamSubscription userUpdateSubscription;

  void _setUser(FirebaseUser user) {
    setState(() {
      this.user = user;
    });
  }

  @override
  void initState() {
    super.initState();
    userUpdateSubscription = Auth.firebaseAuth.onAuthStateChanged.listen(_setUser);
  }

  @override
  void dispose() {
    userUpdateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RootContext(
      user: user,
      child: MaterialApp(
          title: 'Books2Go',
          theme: new ThemeData(
            primarySwatch: Colors.amber,
          ),
          home: new LoginWidget(),
          routes: <String, WidgetBuilder>{
            '/camera': (BuildContext context) => CameraWidget()
          }),
    );
  }
}
