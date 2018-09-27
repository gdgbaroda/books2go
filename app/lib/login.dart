import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'root_context.dart';
import 'colors.dart';
import 'package:flutter/services.dart';

class LoginWidget extends StatefulWidget {
  LoginWidget({Key key}) : super(key: key);

  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  // State variables
  bool loading = false;

  /// Sets progressbar visibility.
  void _setLoading(loading) {
    if (this.mounted) {
      setState(() {
        this.loading = loading;
      });
    }
  }

  /// Completes login process and redirects to Home screen.
  void _login() async {
    this._setLoading(true);
    bool loggedIn = await Auth.login();

    if (loggedIn) {
      // Redirecting to Home
      Navigator.of(context).pushNamed('/home');
    } else {
      this._setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    RootContext rootContext = context.inheritFromWidgetOfExactType(RootContext);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: this.createBody(rootContext.user),
        ),
      ),
      backgroundColor: kPrimaryColor,
    );
  }

  /// Creates the main body to show using the state variable values
  List<Widget> createBody(FirebaseUser user) {
    var children = <Widget>[];

    if (this.loading) {
      children.add(new CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
      ));
    } else if (user == null) {
      children.addAll(this.createLoginScreen());
    }

    return children;
  }

  List<Widget> createLoginScreen() {
    return <Widget>[
      Icon(
        Icons.bookmark_border,
        size: 80.0,
        color: Colors.white,
      ),
      Container(
        margin: const EdgeInsets.only(top: 10.0),
        child: Text('Books2Go',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
                color: Colors.white)),
      ),
      Container(
        margin: const EdgeInsets.only(top: 32.0),
        child: RaisedButton(
          color: Theme.of(context).accentColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 4.0),
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
              ),
              Text(
                'Sign-In with Google',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          onPressed: _login,
        ),
      ),
    ];
  }
}
