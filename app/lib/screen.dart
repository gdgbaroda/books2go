import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class Screen extends StatefulWidget {
  Screen({Key key, @required this.user, @required this.logout}) : super(key: key);

  final FirebaseUser user;
  final Function logout;

  void _logout (BuildContext context) {
    this.logout();
    Navigator.of(context).pop();
    Navigator.of(context, rootNavigator: true).pop();
  }

  Widget createDrawer(BuildContext context) {
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
                  onTap: () => _logout(context),
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
}