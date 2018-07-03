import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

class LoginWidget extends StatefulWidget {
  LoginWidget({Key key}) : super(key: key);

  @override
  LoginWidgetState createState() => new LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // State variables
  bool loading = false;
  FirebaseUser user;

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: this.createBody(),
        ),
      ),
      drawer: this.createDrawer(),
    );
  }

  /// This method attempts to invoke the user login flow, 
  /// if any failure happens, loading is set to false, hence 
  /// hiding the progress bar and allowing the user to try again.
  void _login() async {
    this._setLoading(true);
    try {
      await _googleSignIn.disconnect();
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      FirebaseUser user = await _auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      this._setUser(user);
    } finally {
      this._setLoading(false);
    }
  }

  /// This method logs user out, allowing him to login again with some other account.
  void _logout() async {
    Navigator.pop(context); // Close the navigation drawer
    this._setLoading(true);
    try {
      this._setUser(null);
      await _googleSignIn.signOut();
    } finally {
      this._setLoading(false);
    }
  }

  /// Creates the main body to show using the state variable values
  List<Widget> createBody() {
    var children = <Widget> [];
      
    if (this.loading) {
      children.add(new CircularProgressIndicator());
    } else if (this.user == null) {
      children.add(this.createSignInButton());
    } else {
      children.add(Text('Welcome !'));
    }

    return children;
  }

  Widget createDrawer() {
    if (this.user != null) {
      return Drawer(
        child: Column(
          children: <Widget>[
            /// This is a widget that can show the material design nav drawer header properly
            UserAccountsDrawerHeader(
              accountEmail: Text(this.user.email),
              accountName: Text(this.user.displayName),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(this.user.photoUrl),
              ),
            ),
            /// We've used a ListBody so that we can add more buttons later on
            ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                  onTap: _logout,
                )
              ],
            ),
          ],
        ),
      );
    } else {
      return null;
    }
  }

  Widget createSignInButton() {
    return RaisedButton(
      child: Text('SIGN IN'),
      onPressed: _login
      );
  }
}
