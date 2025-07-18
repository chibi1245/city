import 'package:flutter/material.dart';

import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';

import '../../repositories/officer_action_repo.dart';

class ToAppealOfficerViewModel with ChangeNotifier {
  bool loader = false;
  var note = TextEditingController();

  void initViewModel() {
    note.text = 'service_related_complaint_note'.translate;
  }

  void disposeViewModel() {
    loader = false;
    note.clear();
  }

  void updateUi() => notifyListeners();

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  void sendOnTap(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) {
    minimizeKeyboard();
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write your reason'.translate, isTop: true);
    _toAppealOfficerApi(complain, typePref, viewPref);
  }

  Future<void> _toAppealOfficerApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var body = _toAppealOfficerBody(complain);
    var response = await sl<OfficerActionRepository>().sendToAppealOfficer(body);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _toAppealOfficerBody(Complain complain){
    Map<String, String> bodyInformation = {};
    if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
    bodyInformation['note'] = note.text;
    return bodyInformation;
  }
}
