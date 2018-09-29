import 'package:books2go/favourite_books.dart';
import 'package:books2go/search_books.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'login.dart';
import 'home.dart';
import 'camera.dart';
import 'root_context.dart';
import 'auth.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

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
    userUpdateSubscription =
        Auth.firebaseAuth.onAuthStateChanged.listen(_setUser);
  }

  @override
  void dispose() {
    userUpdateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return RootContext(
      user: user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
          title: 'Books2Go',
          theme: ThemeData.light().copyWith(
            accentColor: kSecondaryColor,
            primaryColor: kPrimaryColor,
            buttonColor: kPrimaryColorLight,
            buttonTheme: ThemeData.light().buttonTheme.copyWith()
          ),
          home: user == null ? new LoginWidget() : new HomeWidget(),
          routes: <String, WidgetBuilder>{
            '/camera': (BuildContext context) => CameraWidget(),
            '/search': (BuildContext context) => SearchBooksWidget(),
            '/home': (BuildContext context) => HomeWidget()
          }),
    );
  }
}
