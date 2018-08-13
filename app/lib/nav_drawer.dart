import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'root_context.dart';

class NavDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  void _popToRoot() {
    Navigator.of(context).popUntil((_) => !Navigator.of(context).canPop());
  }
  
  void _openCamera() {
    Navigator.of(context).pushNamed('/camera');
  }
  void _searchbook(){
    Navigator.of(context).pushNamed('/search_books');
  }

  void _logout() {
    _popToRoot();
    Auth.logout();
  }

  void _login() async {
    this._setLoading(true);
    await Auth.login();
    this._setLoading(false);
  }

  void _setLoading(value) {
    setState(() {
      this.loading = value;
    });
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    RootContext rootContext = context.inheritFromWidgetOfExactType(RootContext);

    return Drawer(
      child: Column(
        children: <Widget>[
          createDrawerHeader(rootContext.user),
          ListBody(children: createDrawerBody(rootContext.user)),
        ],
      ),
    );
  }

  /// This is a widget that can show the material design nav drawer header properly
  UserAccountsDrawerHeader createDrawerHeader(FirebaseUser user) {
    Widget picture = const CircleAvatar(
        backgroundColor: Colors.transparent,
        child:
            const Icon(Icons.account_circle, size: 70.0, color: Colors.white));

    if (user != null) {
      picture = CircleAvatar(backgroundImage: NetworkImage(user.photoUrl));
    }

    return UserAccountsDrawerHeader(
        accountEmail: user?.email == null ? null : Text(user.email),
        accountName: Text(user?.displayName ?? 'Signed Out'),
        currentAccountPicture: picture);
  }

  List<Widget> createDrawerBody(FirebaseUser user) {
    List<Widget> widgets = [];

    if (user != null) {
      widgets.addAll(<Widget>[
        ListTile(
          leading: Icon(Icons.photo_camera),
          title: const Text('Open Camera'),
          onTap: _openCamera,
        ),
        ListTile(
          leading: Icon(Icons.book),
          title: const Text('Search Books'),
          onTap: _searchbook,
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: const Text('Logout'),
          onTap: _logout,
        ),

      ]);
    } else {
      widgets.add(ListTile(
        leading: loading ? CircularProgressIndicator() : Icon(Icons.launch),
        title: Text(loading ? 'Please wait...' : 'Login'),
        onTap: _login,
        enabled: !loading,
        selected: loading,
      ));
    }

    return widgets;
  }
}
