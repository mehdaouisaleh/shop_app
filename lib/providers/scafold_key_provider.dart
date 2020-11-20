import 'package:flutter/material.dart';

class ScafoldKeyProvider with ChangeNotifier {
  GlobalKey<ScaffoldState> _scaffoldKey;

  GlobalKey<ScaffoldState> get scaffoldKey {
    return _scaffoldKey;
  }

  void setScaffoldKey(GlobalKey<ScaffoldState> sKey) {
    _scaffoldKey = sKey;
  }
}
