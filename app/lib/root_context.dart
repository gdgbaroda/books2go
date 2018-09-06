import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RootContext extends InheritedWidget {
  RootContext({@required this.user, Widget child}) : super(child: child);

  final FirebaseUser user;

  @override
  bool updateShouldNotify(RootContext old) {
    return user?.email != old.user?.email;
  }
}
