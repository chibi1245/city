import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/dummy/loader.dart';
import 'package:grs/repositories/auth_repo.dart';
import 'package:grs/service/routes.dart';
import 'package:grs/service/storage_service.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/complain/citizen_complains_view_model.dart';
import 'package:grs/view_models/complain/officer_complains_view_model.dart';

class SignInViewModel with ChangeNotifier {
  bool obscureText = true;
  bool keepLoggedIn = false;
  bool loader = false;
  String selectedModule = 'citizen';
  var mobile = TextEditingController();
  var pin = TextEditingController();

  void initViewModel() => _setCredentialsData();

  void disposeViewModel() {
    // mobile.clear();
    // pin.clear();
    // loader = false;
  }

  void _setCredentialsData() {
    var credType = sl<StorageService>().getCredentialType;
    if (credType == null || selectedModule != credType) return;
    keepLoggedIn = sl<StorageService>().getRememberMe;
    var username = sl<StorageService>().getUsername;
    if (username != 'null') mobile.text = username;
    var password = sl<StorageService>().getPassword;
    if (password != 'null') pin.text = password;
    notifyListeners();
  }

  void setModule(String module) {
    selectedModule = module;
    mobile.clear();
    pin.clear();
    keepLoggedIn = false;
    notifyListeners();
    _setCredentialsData();
  }

  void updateUi() => notifyListeners();

  Future<void> officerSignIn() async {
    loader = true;
    notifyListeners();
    Map<String, dynamic> body = {'username': mobile.text, 'password': pin.text};
    var response = await sl<AuthRepository>().administrativeLogin(body: body);
    if (response != null) {
      var context = navigatorKey.currentState!.context;
      Provider.of<OfficerComplainsViewModel>(context, listen: false).loader = Loader(initial: true, common: true);
      notifyListeners();
      sl<Toasts>().successToast(message: 'Welcome to Grievance Redress System'.translate, isTop: false);
      unawaited(sl<Routes>().officerComplainsScreen().pushAndRemoveUntil());
    }
    loader = false;
    notifyListeners();
  }

  Future<void> citizenSignIn() async {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    loader = true;
    notifyListeners();
    var username = mobile.text.localizeDigits(fromZeroDigit: '\u09e6', toZeroDigit: '0');
    var password = pin.text.localizeDigits(fromZeroDigit: '\u09e6', toZeroDigit: '0');
    var body = {'username': username, 'password': password};
    var cred = {'username': mobile.text, 'password': pin.text};
    var response = await sl<AuthRepository>().citizenSignIn(body: body, cred: cred);
    if (response != null) {
      Provider.of<CitizenComplainsViewModel>(context, listen: false).loader = Loader(initial: true, common: true);
      notifyListeners();
      sl<Toasts>().successToast(message: 'Welcome to Grievance Redress System'.translate, isTop: false);
      unawaited(sl<Routes>().citizenComplainsScreen().pushAndRemoveUntil());
    }
    loader = false;
    notifyListeners();
  }

  // 01756888319 -> ০১৭৫৬৮৮৮৩১৯
  // ১২৩৪৫৬
}
