import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grs/di.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/service/routes.dart';
import 'package:grs/repositories/auth_repo.dart';

class ForgotPinViewModel with ChangeNotifier {
  var loader = false;
  var mobile = TextEditingController();

  void initViewModel() {}

  void disposeViewModel() {
    loader = false;
    mobile.clear();
  }

  Future<void> sendCodeOnTap() async {
    _loader(true);
    var apiResponse = await sl<AuthRepository>().forgotPassword(mobile.text);
    if (apiResponse) backToPrevious();
    _loader(false);
  }

  void _loader(bool status) {
    loader = status;
    notifyListeners();
  }
  
}
