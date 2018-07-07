import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './screen.dart';

class LoginWidget extends Screen {
  LoginWidget({Key key, user, logout, this.onUserUpdate}) : super(key: key, user: user, logout: logout);

  final ValueChanged<FirebaseUser> onUserUpdate;

  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // State variables
  bool loading = false;

  void _setLoading(loading) {
    setState(() {
      this.loading = loading;
    });
  }

  void _setUser(user) {
    this.widget.onUserUpdate(user);
    Navigator.pushNamed(context, '/camera');
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
      drawer: this.widget.createDrawer(context),
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

  /// Creates the main body to show using the state variable values
  List<Widget> createBody() {
    var children = <Widget> [];
      
    if (this.loading) {
      children.add(new CircularProgressIndicator());
    } else if (this.widget.user == null) {
      children.add(this.createSignInButton());
    } else {
      children.add(Text('Welcome !'));
    }

    return children;
  }

  Widget createSignInButton() {
    return RaisedButton(
      child: Text('SIGN IN'),
      onPressed: _login
    );
  }
}
