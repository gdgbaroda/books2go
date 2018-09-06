import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'root_context.dart';

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
    await Auth.login();
    this._setLoading(false);

    // Redirecting to Home
    Navigator.of(context).pushNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    RootContext rootContext = context.inheritFromWidgetOfExactType(RootContext);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: this.createBody(rootContext.user),
        ),
      ),
      backgroundColor: Colors.amber,
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
        Icons.book,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 4.0),
                child: Icon(Icons.account_circle),
              ),
              Text('Sign-In with Google'),
            ],
          ),
          color: Colors.white,
          textColor: Colors.black54,
          splashColor: Color.fromARGB(255, 222, 222, 222),
          onPressed: _login,
        ),
      ),
    ];
  }
}
