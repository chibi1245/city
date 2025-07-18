import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/action_data_helper.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/branch/officer.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/repositories/officer_action_repo.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/branch_officers_view_model.dart';

class StartInvestigationViewModel with ChangeNotifier {
  bool loader = false;
  var note = TextEditingController();

  void initViewModel() {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<BranchOfficersViewModel>(context, listen: false).initViewModel();
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
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write a note for investigation'.translate, isTop: true);
    var selectedOfficers = Provider.of<BranchOfficersViewModel>(context, listen: false).selectedOfficers;
    if (!selectedOfficers.haveList) return sl<Toasts>().warningToast(message: 'Please select officers'.translate, isTop: true);
    var isCommitteeHead = sl<ActionDataHelper>().checkCommitteeHead(selectedOfficers);
    if (!isCommitteeHead) return sl<Toasts>().warningToast(message: 'Please select an officer as committee head'.translate, isTop: true);
    _startInvestigationApi(complain, typePref, viewPref);
  }

  Future<void> _startInvestigationApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var context = navigatorKey.currentState!.context;
    var officers = Provider.of<BranchOfficersViewModel>(context, listen: false).selectedOfficers;
    var body = _startInvestigationBody(officers, complain);
    var response = await sl<OfficerActionRepository>().startInvestigation(body: body, typePref: typePref);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _startInvestigationBody(List<Officer> officers, Complain complain) {
    Map<String, String> bodyInformation = {};
    var username = sl<ProfileHelper>().officerProfile?.username;
    var officeId = sl<ProfileHelper>().officeInfo.officeId;
    var employeeRecordId = sl<ProfileHelper>().officerProfile?.employeeRecordId;
    var noteText = note.text;
    var officerList = officers.isNotEmpty ? _officerList(officers) : [];

    if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
    if (officeId != null) bodyInformation['office_id'] = '$officeId';
    if (username != null) bodyInformation['username'] = username;
    if (noteText.isNotEmpty) bodyInformation['note'] = noteText;
    if (employeeRecordId != null) bodyInformation['to_employee_record_id'] = '$employeeRecordId';
    if (officerList.isNotEmpty) bodyInformation['officers'] = jsonEncode(officerList);

    return bodyInformation;
  }

  // Map<String, dynamic> _startInvestigationBody(List<Officer> officers, Complain complain) {
  //   Map<String, dynamic> bodyInformation = {
  //     'complaint_id': complain.id,
  //     'office_id': sl<ProfileHelper>().officeInfo.officeId,
  //     'username': sl<ProfileHelper>().officerProfile?.username,
  //     'note': note.text,
  //     'officers': jsonEncode(!officers.haveList ? [] : _officerList(officers)),
  //     'to_employee_record_id': sl<ProfileHelper>().officerProfile?.employeeRecordId,
  //   };
  //   return bodyInformation;
  // }

  // Map<String, dynamic> _startInvestigationBody(List<Officer> officers, Complain complain) {
  //   Map<String, dynamic> bodyInformation = {
  //     'complaint_id': complain.id,
  //     'office_id': sl<ProfileHelper>().officeInfo.officeId,
  //     'username': sl<ProfileHelper>().officerProfile?.username,
  //     'note': note.text,
  //     'officers': jsonEncode(!officers.haveList ? [] : _officerList(officers)),
  //     'to_employee_record_id': sl<ProfileHelper>().officerProfile?.employeeRecordId,
  //   };
  //   return bodyInformation;
  // }

  List<Map<String, dynamic>> _officerList(List<Officer> officers) {
    List<Map<String, dynamic>> officersList = [];
    if (!officers.haveList) return [];
    officers.forEach((item) => officersList.add({
          'id': item.id,
          'office_id': item.officeId,
          'office_name_bng': item.officeNameBng,
          'office_unit_organogram_id': item.officeUnitOrganogramId,
          'office_unit_id': item.officeUnitId,
          'employee_record_id': item.employeeRecordId,
          'designation': item.designation,
          'unit_name_bng': item.unitNameBng,
          'name': item.name,
          'name_en': item.nameEn,
          'committeeHead': item.isCommitteeHead ?? false,
        }));
    // officersList.forEach((item) => print(item['committeeHead']));
    return officersList;
  }
}
