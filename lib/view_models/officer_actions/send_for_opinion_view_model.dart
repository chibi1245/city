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
import 'package:grs/repositories/officer_action_repo.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/branch_officers_view_model.dart';
import 'package:grs/view_models/component/proof_files_view_model.dart';

class SendForOpinionViewModel with ChangeNotifier {
  bool loader = false;
  DateTime? submissionDate;
  var note = TextEditingController();

  void initViewModel() {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<BranchOfficersViewModel>(context, listen: false).initViewModel();
    Provider.of<ProofFilesViewModel>(context, listen: false).initViewModel();
  }

  void disposeViewModel() {
    loader = false;
    note.clear();
    submissionDate = null;
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
    if (submissionDate == null) return sl<Toasts>().warningToast(message: 'Please select last submission date'.translate, isTop: true);
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write a note'.translate, isTop: true);
    var selectedOfficers = Provider.of<BranchOfficersViewModel>(context, listen: false).selectedOfficers;
    if (!selectedOfficers.haveList) return sl<Toasts>().warningToast(message: 'Please select officers'.translate, isTop: true);
    var isCommitteeHead = sl<ActionDataHelper>().checkCommitteeHead(selectedOfficers);
    if (!isCommitteeHead) return sl<Toasts>().warningToast(message: 'Please select an officer as committee head'.translate, isTop: true);
    // var isRecipient = sl<ActionDataHelper>().checkRecipients(selectedOfficers);
    // if (!isRecipient) return sl<Toasts>().warningToast(message: 'Please select an officer as copy recipient'.translate, isTop: true);
    var proofFilesModel = Provider.of<ProofFilesViewModel>(context, listen: false);
    if (!proofFilesModel.validateProofFiles()) return;
    _sendForOpinionApi(complain, typePref, viewPref);
  }

  Future<void> _sendForOpinionApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var context = navigatorKey.currentState!.context;
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    var officers = Provider.of<BranchOfficersViewModel>(context, listen: false).selectedOfficers;
    var body = _sendForOpinionBody(context, officers, complain);
    var response = await sl<OfficerActionRepository>().sendForOpinion(body, proofFiles);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _sendForOpinionBody(BuildContext context, List<Officer> officers, Complain complain) {
    var filenames;
    var username = sl<ProfileHelper>().officerProfile?.username;
    var officeId = sl<ProfileHelper>().officeInfo.officeId;
    var employeeRecordId = sl<ProfileHelper>().officerProfile?.employeeRecordId;
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    if (proofFiles.length > 0) filenames = proofFiles.map((item) => item.name.text).join(',');
    Map<String, String> bodyInformation = {};
    if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
    if (officeId != null) bodyInformation['office_id'] = '$officeId';
    if (username != null) bodyInformation['username'] = username;
    if (employeeRecordId != null) bodyInformation['to_employee_record_id'] = '$employeeRecordId';
    bodyInformation['note'] = note.text;
    bodyInformation['officers'] = jsonEncode(!officers.haveList ? [] : _officerList(officers));
    bodyInformation['deadline'] = sl<Formatters>().formatDate(DATE_FORMAT_1, '$submissionDate');
    if (filenames != null) bodyInformation['fileNameByUser'] = filenames;
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
