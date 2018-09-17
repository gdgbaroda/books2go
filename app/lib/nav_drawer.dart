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

  /// Logs out user from app.
  void _logout() {
    _popToRoot();
    Auth.logout();
  }

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
        accountEmail: Text(user?.email ?? ''),
        accountName: Text(user?.displayName ?? ''),
        currentAccountPicture: picture);
  }

  List<Widget> createDrawerBody(FirebaseUser user) {
    List<Widget> widgets = [];

    widgets.addAll(<Widget>[
      ListTile(
        leading: Icon(Icons.exit_to_app),
        title: const Text('Logout'),
        onTap: _logout,
      ),
    ]);

    return widgets;
  }
}
