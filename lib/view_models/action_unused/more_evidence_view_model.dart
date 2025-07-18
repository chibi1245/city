import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/utils/keys.dart';

class MoreEvidenceViewmodel with ChangeNotifier {
  bool loader = false;
  var note = TextEditingController();

  void initViewModel() {}

  void disposeViewModel() {
    loader = false;
    note.clear();
  }

  void updateUi() => notifyListeners();

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  Future<void> sendOnTap(Complain complain) async {
    await minimizeKeyboard();
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    var message1 = 'Please write a note for more evidence'.translate;
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: message1, isTop: true);
    // var signatureModel = Provider.of<SignatureViewModel>(context, listen: false);
    // var message2 = 'Please upload your signature'.translate;
    // if (signatureModel.signature == null) return sl<Toasts>().warningToast(message: message2, isTop: true);
    // var message3 = 'Please write your signature name'.translate;
    // if (signatureModel.note.text.isEmpty) return sl<Toasts>().warningToast(message: message3, isTop: true);
    _loader(true);
    // var body = _provideMoreEvidenceBody(complain);
    await Future.delayed(const Duration(seconds: 1));
    // var response = await sl<OfficerActionRepository>().provideMoreEvidence(body: body);
    // if (response) backToPrevious();
    _loader(false);
  }

  /*dynamic _provideMoreEvidenceBody(Complain complain) {
    Map<String, dynamic> bodyInformation = {
      'complaint_id': complain.id,
      'office_id': sl<ProfileHelper>().officeInfo.officeId,
      'username': sl<ProfileHelper>().profile?.username,
      'note': note.text,
      'to_employee_record_id': sl<ProfileHelper>().profile?.employeeRecordId,
    };
    return bodyInformation;
  }*/
}
