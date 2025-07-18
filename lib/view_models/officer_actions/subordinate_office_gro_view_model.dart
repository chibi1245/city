import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'package:grs/constants/date_formats.dart';
import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/action_data_helper.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/libraries/formatters.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/branch/officer.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/dummy/proof_file.dart';
import 'package:grs/repositories/officer_action_repo.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/subordinate_officers_view_model.dart';

class SubOrdinateOfficeGroViewModel with ChangeNotifier {
  bool loader = false;
  DateTime? lastDate;
  List<ProofFile> proofFiles = [];
  var note = TextEditingController();

  void initViewModel({Complain? complain}) {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<SubordinateOfficersViewModel>(context, listen: false).initViewModel(complain: complain);
  }

  void disposeViewModel() {
    loader = false;
    lastDate = null;
    note.clear();
    proofFiles.clear();
  }

  void updateUi() => notifyListeners();

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  void sendOnTap(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) {
    minimizeKeyboard();
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    if (lastDate == null) return sl<Toasts>().warningToast(message: 'Please select last date'.translate, isTop: true);
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write a note'.translate, isTop: true);
    var selectedOfficers = Provider.of<SubordinateOfficersViewModel>(context, listen: false).selectedOfficers;
    if (!selectedOfficers.haveList) return sl<Toasts>().warningToast(message: 'Please select officers'.translate, isTop: true);
    var isCommitteeHead = sl<ActionDataHelper>().checkCommitteeHead(selectedOfficers);
    if (!isCommitteeHead) return sl<Toasts>().warningToast(message: 'Please select an officer as committee head'.translate, isTop: true);
    _complainSubordinateOfficeGroApi(complain, typePref, viewPref);
  }

  Future<void> _complainSubordinateOfficeGroApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var context = navigatorKey.currentState!.context;
    var selectedOfficers = Provider.of<SubordinateOfficersViewModel>(context, listen: false).selectedOfficers;
    var body = _sendForOpinionBody(selectedOfficers, complain);
    var response = await sl<OfficerActionRepository>().subordinateOfficeGro(typePref: typePref, body: body);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  // Map<String, dynamic> _sendForOpinionBody(List<Officer> officers, Complain complain) {
  //   var username = sl<ProfileHelper>().officerProfile?.username;
  //   var officeId = sl<ProfileHelper>().officeInfo.officeId;
  //   var employeeRecordId = sl<ProfileHelper>().officerProfile?.employeeRecordId;
  //   Map<String, String> bodyInformation = {};
  //   if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
  //   if (officeId != null) bodyInformation['office_id'] = '$officeId';
  //   if (username != null) bodyInformation['username'] = username;
  //   if (employeeRecordId != null) bodyInformation['to_employee_record_id'] = '$employeeRecordId';
  //   bodyInformation['note'] = note.text;
  //   bodyInformation['officers'] = jsonEncode(!officers.haveList ? [] : _officerList(officers));
  //   bodyInformation['deadline'] = sl<Formatters>().formatDate(DATE_FORMAT_1, '$lastDate');
  //   // Map<String, dynamic> bodyInformation = {
  //   //   'complaint_id': complain.id,
  //   //   'office_id': sl<ProfileHelper>().officeInfo.officeId,
  //   //   'username': sl<ProfileHelper>().officerProfile?.username,
  //   //   'note': note.text,
  //   //   'officers': jsonEncode(!officers.haveList ? [] : _officerList(officers)),
  //   //   'deadline': sl<Formatters>().formatDate(DATE_FORMAT_1, '$lastDate'),
  //   //   'to_employee_record_id': sl<ProfileHelper>().officerProfile?.employeeRecordId,
  //   // };
  //   return bodyInformation;
  // }

  Map<String, String> _sendForOpinionBody(List<Officer> officers, Complain complain) {
    var username = sl<ProfileHelper>().officerProfile?.username;
    var officeId = sl<ProfileHelper>().officeInfo.officeId;
    var employeeRecordId = sl<ProfileHelper>().officerProfile?.employeeRecordId;
    Map<String, String> bodyInformation = {};
    if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
    if (officeId != null) bodyInformation['office_id'] = '$officeId';
    if (username != null) bodyInformation['username'] = username;
    if (employeeRecordId != null) bodyInformation['to_employee_record_id'] = '$employeeRecordId';
    bodyInformation['note'] = note.text;
    bodyInformation['officers'] = jsonEncode(!officers.haveList ? [] : _officerList(officers));
    bodyInformation['deadline'] = sl<Formatters>().formatDate(DATE_FORMAT_1, '$lastDate');
    // Map<String, dynamic> bodyInformation = {
    //   'complaint_id': complain.id,
    //   'office_id': sl<ProfileHelper>().officeInfo.officeId,
    //   'username': sl<ProfileHelper>().officerProfile?.username,
    //   'note': note.text,
    //   'officers': jsonEncode(!officers.haveList ? [] : _officerList(officers)),
    //   'deadline': sl<Formatters>().formatDate(DATE_FORMAT_1, '$lastDate'),
    //   'to_employee_record_id': sl<ProfileHelper>().officerProfile?.employeeRecordId,
    // };
    return bodyInformation;
  }

  List<Map<String, dynamic>> _officerList(List<Officer> officers) {
    List<Map<String, dynamic>> officersList = [];
    if (!officers.haveList) return [];
    officers.forEach((item) => officersList.add({
          'id': item.id,
          'office_unit_organogram_id': item.officeUnitOrganogramId,
          'office_unit_id': item.officeUnitId,
          'employee_record_id': item.employeeRecordId,
          'designation': item.designation,
          'unit_name_bng': item.unitNameBng,
          'name': item.name,
          'name_en': item.nameEn,
          'office_id': item.officeId,
          'office_name_bng': item.officeNameBng,
          'receiverCheck': item.isCommitteeHead ?? false,
          'ccCheck': item.isRecipient ?? false
        }));
    return officersList;
  }
}
