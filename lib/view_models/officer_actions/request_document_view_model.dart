import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/dummy/data_type.dart';
import 'package:grs/repositories/officer_action_repo.dart';

class RequestDocumentViewModel with ChangeNotifier {
  bool loader = false;
  DataType? witness;
  List<DataType> witnessList = [];
  var note = TextEditingController();

  void initViewModel(Complain complain) {
    witnessList.add(DataType(labelBn: 'অভিযোগকারী', labelEn: 'Complainant', value: '${complain.complainantId}'));
    notifyListeners();
  }

  void disposeViewModel() {
    loader = false;
    witness = null;
    note.clear();
    witnessList.clear();
  }

  void updateUi() => notifyListeners();

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  void sendOnTap(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) {
    minimizeKeyboard();
    if (witness == null) return sl<Toasts>().warningToast(message: 'Please select a witness'.translate, isTop: true);
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write a note for witness'.translate, isTop: true);
    _requestDocumentApi(complain, typePref, viewPref);
  }

  Future<void> _requestDocumentApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var body = _requestDocumentBody(complain);
    var response = await sl<OfficerActionRepository>().requestDocument(body: body, typePref: typePref);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _requestDocumentBody(Complain complain) {
    Map<String, String> bodyInformation = {};

    var username = sl<ProfileHelper>().officerProfile?.username;
    var officeId = sl<ProfileHelper>().officeInfo.officeId;
    var employeeRecordId = sl<ProfileHelper>().officerProfile?.employeeRecordId;
    var noteText = note.text;

    if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
    if (officeId != null) bodyInformation['office_id'] = '$officeId';
    if (username != null) bodyInformation['username'] = username;
    if (noteText.isNotEmpty) bodyInformation['note'] = noteText;
    if (employeeRecordId != null) bodyInformation['to_employee_record_id'] = '$employeeRecordId';

    return bodyInformation;
  }

  // Map<String, dynamic> _requestDocumentBody(Complain complain) {
  //   Map<String, dynamic> bodyInformation = {
  //     'complaint_id': complain.id,
  //     'office_id': sl<ProfileHelper>().officeInfo.officeId,
  //     'username': sl<ProfileHelper>().officerProfile?.username,
  //     'note': note.text,
  //     'to_employee_record_id': sl<ProfileHelper>().officerProfile?.employeeRecordId,
  //   };
  //   return bodyInformation;
  // }
}
