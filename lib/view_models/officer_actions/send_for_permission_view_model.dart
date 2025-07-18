import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';

import '../../repositories/officer_action_repo.dart';

class SendForPermissionViewModel with ChangeNotifier {
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
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write a note for permission'.translate, isTop: true);
    _sendForPermissionApi(complain, typePref, viewPref);
  }

  Future<void> _sendForPermissionApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var body = _sendForPermissionBody( complain);
    var response = await sl<OfficerActionRepository>().sendForPermission(body);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _sendForPermissionBody(Complain complain) {
    Map<String, String> bodyInformation = {};

    var noteText = note.text;

    if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
    if (noteText.isNotEmpty) bodyInformation['note'] = noteText;

    return bodyInformation;
  }
}
