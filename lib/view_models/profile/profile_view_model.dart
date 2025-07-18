import 'package:flutter/cupertino.dart';

class ProfileViewModel with ChangeNotifier {
  bool loader = true;

  Future<void> initViewModel() async {
    await Future.delayed(const Duration(microseconds: 700));
    loader = false;
    notifyListeners();
  }

  void disposeViewModel() {
    loader = true;
  }

  void updateUi() => notifyListeners();
}
