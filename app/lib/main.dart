import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './login.dart';
import './camera.dart';

void main() => runApp(new App());

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  FirebaseUser user;

  void _setUser(FirebaseUser user) { 
    setState(() {
      this.user = user;
    });
  }

  void _logout() {
    this._setUser(null);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Books2Go',
      theme: new ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: new LoginWidget(
        user: this.user,
        onUserUpdate: _setUser,
        logout: _logout
      ),
      routes: <String, WidgetBuilder> {
        '/camera': (BuildContext context) => CameraWidget(
          user: this.user,
          logout: _logout
        )
      }
    );
  }
}