import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';

import '../../repositories/officer_action_repo.dart';

class GivePermissionViewModel with ChangeNotifier {
  bool loader = false;
  var note = TextEditingController();

  void initViewModel() {}

  void disposeViewModel() {
    note.clear();
    loader = false;
  }

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  void updateUi() => notifyListeners();

  void sendOnTap(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) {
    minimizeKeyboard();
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write a note to give permission'.translate, isTop: true);
    _givePermissionApi(complain, typePref, viewPref);
  }

  Future<void> _givePermissionApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var body = _givePermissionBody(complain);
    var response = await sl<OfficerActionRepository>().givePermission(body: body);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, dynamic> _givePermissionBody(Complain complain) {
    Map<String, dynamic> body = {
      'grievanceId': complain.id,
      'note': note.text,
    };
    return body;
  }
}
