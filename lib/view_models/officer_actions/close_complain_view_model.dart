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
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/dummy/data_type.dart';
import 'package:grs/models/history/complain_history.dart';
import 'package:grs/repositories/action_data_repo.dart';
import 'package:grs/repositories/officer_action_repo.dart';
import 'package:grs/service/app_api_status.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/proof_files_view_model.dart';

class CloseComplainViewModel with ChangeNotifier {
  bool loader = true;
  DataType? settlement;
  bool departmentalMeasure = false;
  List<ComplainHistory> officers = [];
  var department = TextEditingController();
  var decision = TextEditingController();
  var rootCause = TextEditingController();
  var advice = TextEditingController();

  void initViewModel(Complain complain) {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<ProofFilesViewModel>(context, listen: false).initViewModel();
    if (sl<AppApiStatus>().movementOfficers) _loader(false);
    if (sl<AppApiStatus>().movementOfficers) return;
    getMovementOfficers(complain.id!);
  }

  void disposeViewModel() {
    loader = true;
    settlement = null;
    advice.clear();
    decision.clear();
    rootCause.clear();
    department.clear();
    departmentalMeasure = false;
    if (officers.haveList) officers.forEach((item) => item.isSelected = false);
  }

  void updateUi() => notifyListeners();

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  void chooseSettlement(DataType data) {
    if (settlement != null && settlement!.value == data.value) return;
    settlement = data;
    department.clear();
    departmentalMeasure = false;
    officers.forEach((item) => item.isSelected = false);
    notifyListeners();
  }

  void setDepartmentalMeasure() {
    departmentalMeasure = !departmentalMeasure;
    notifyListeners();
  }

  Future<void> getMovementOfficers(int complainId) async {
    var responseList = await sl<ActionDataRepository>().movementOfficersList(complainId);
    officers.clear();
    if (responseList.haveList) officers.addAll(responseList);
    _loader(false);
  }

  void selectOfficer(int index) {
    var officer = officers[index];
    var isSelected = officer.isSelected != null && officer.isSelected!;
    officer.isSelected = isSelected ? false : true;
    notifyListeners();
  }

  void sendOnTap(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) {
    minimizeKeyboard();
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    if (settlement == null) return sl<Toasts>().warningToast(message: 'Please select a settlement reason'.translate, isTop: true);
    if (settlement != null && settlement!.value == 'CLOSED_ACCUSATION_PROVED' && departmentalMeasure) {
      var recordIds = sl<ActionDataHelper>().checkMovementOfficers(officers);
      if (!recordIds.haveList) return sl<Toasts>().warningToast(message: 'Please select any departmental officer'.translate, isTop: true);
      var message = 'Please write a reason for departmental system'.translate;
      if (department.text.isEmpty) return sl<Toasts>().warningToast(message: message, isTop: true);
    }
    var message1 = "Please write a note for grievance Officer's Decision".translate;
    if (decision.text.isEmpty) return sl<Toasts>().warningToast(message: message1, isTop: true);
    var message2 = 'Please write a note for root cause of complaint'.translate;
    if (rootCause.text.isEmpty) return sl<Toasts>().warningToast(message: message2, isTop: true);
    if (advice.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write a note for advice'.translate, isTop: true);
    var proofFilesModel = Provider.of<ProofFilesViewModel>(context, listen: false);
    if (!proofFilesModel.validateProofFiles()) return;
    _closeComplainApi(complain, typePref, viewPref);
  }

  Future<void> _closeComplainApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var context = navigatorKey.currentState!.context;
    var body = _closeComplainBody(context, complain);
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    var response = await sl<OfficerActionRepository>().closeComplain(typePref, body, proofFiles);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _closeComplainBody(BuildContext context, Complain complain) {
    var filenames;
    var username = sl<ProfileHelper>().officerProfile?.username;
    var officeId = sl<ProfileHelper>().officeInfo.officeId;
    var employeeRecordId = sl<ProfileHelper>().officerProfile?.employeeRecordId;
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    // var deptActions = sl<ActionDataHelper>().checkMovementOfficers(officers);
    var deptActions = sl<ActionDataHelper>().checkMovementOfficersWithOrganogramId(officers);
    if (proofFiles.length > 0) filenames = proofFiles.map((item) => item.name.text).join(',');
    Map<String, String> bodyInformation = {};
    if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
    if (officeId != null) bodyInformation['office_id'] = '$officeId';
    if (username != null) bodyInformation['username'] = username;
    bodyInformation['action'] = settlement!.value;
    bodyInformation['closingNoteGRODecision'] = decision.text;
    bodyInformation['closingNoteMainReason'] = rootCause.text;
    bodyInformation['closingNoteSuggestion'] = advice.text;
    bodyInformation['departmentalActionReason'] = department.text;
    bodyInformation['deptAction'] = jsonEncode(deptActions); // arise issue
    if (employeeRecordId != null) bodyInformation['to_employee_record_id'] = '$employeeRecordId';
    if (filenames != null) bodyInformation['fileNameByUser'] = filenames;
    return bodyInformation;
  }
}
