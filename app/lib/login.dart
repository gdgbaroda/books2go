import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'nav_drawer.dart';
import 'root_context.dart';

class LoginWidget extends StatefulWidget {
  LoginWidget({Key key}) : super(key: key);

  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  // State variables
  bool loading = false;

  void _setLoading(loading) {
    setState(() {
      this.loading = loading;
    });
  }

  void _login() async {
    this._setLoading(true);
    await Auth.login();
    this._setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    RootContext rootContext = context.inheritFromWidgetOfExactType(RootContext);

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: this.createBody(rootContext.user),
        ),
      ),
      drawer: NavDrawer(),
    );
  }

  /// Creates the main body to show using the state variable values
  List<Widget> createBody(FirebaseUser user) {
    var children = <Widget>[];

    if (this.loading) {
      children.add(new CircularProgressIndicator());
    } else if (user == null) {
      children.add(this.createSignInButton());
    } else {
      children.add(Text("Welcome ${user.displayName} !"));
    }

    return children;
  }

  Widget createSignInButton() {
    return RaisedButton(child: Text('SIGN IN'), onPressed: _login);
  }
}
