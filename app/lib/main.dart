import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;
  FirebaseUser user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignIn _googleSignIn = new GoogleSignIn(
      scopes: ['email'],
    );
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return user;
  }

  void _setLoading(loading) {
    setState(() {
      this.loading = loading;
    });
  }

  void _setUser(user) {
    setState(() {
      this.user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    var signInBtn = RaisedButton(
      child: Text('SIGN IN'),
      onPressed: () {
        this._setLoading(true);
        _handleSignIn()
          .then((FirebaseUser user) {
            this._setUser(user);
            this._setLoading(false);
          })
          .catchError((e) {
            print(e);
            this._setLoading(false);
          });
    });

    var loadingBtn = RaisedButton(
      child: Text('LOADING...'),
      onPressed: null,
    );

    var children = <Widget> [];
    if (loading) {
      children.add(loadingBtn);
    } else {
      children.add(signInBtn);
    }

    if (this.user != null) {
      children.add(Padding(
        padding: EdgeInsets.only(
          top: 50.0, 
          bottom: 50.0
        ),
        child: Text(
          user.email, 
          style: TextStyle(
            fontSize: 18.0
          )
        )
      ));
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: children,
        ),
      )
    );
  }
}
