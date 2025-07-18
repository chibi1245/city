import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/service/service.dart';
import 'package:grs/repositories/action_data_repo.dart';
import 'package:grs/repositories/officer_action_repo.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/proof_files_view_model.dart';
import 'package:grs/view_models/component/subordinate_officers_view_model.dart';

class SubordinateOfficeViewModel with ChangeNotifier {
  var loader = false;
  Service? selectedService;
  List<Service> serviceList = [];
  var note = TextEditingController();
  var otherService = TextEditingController();

  void initViewModel({Complain? complain}) {
    getServiceList();
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<SubordinateOfficersViewModel>(context, listen: false).initViewModel(complain: complain);
    Provider.of<ProofFilesViewModel>(context, listen: false).initViewModel();
  }

  void disposeViewModel() {
    loader = false;
    note.clear();
    otherService.clear();
    serviceList.clear();
    selectedService = null;
  }

  void updateUi() => notifyListeners();

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  Future<void> getServiceList() async {
    _loader(true);
    var response = await sl<ActionDataRepository>().getServiceListByProfileOffice();
    if (response.haveList) serviceList.addAll(response);
    _loader(false);
  }

  void selectService(Service service) {
    selectedService = service;
    notifyListeners();
  }

  void sendOnTap(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) {
    minimizeKeyboard();
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write a note'.translate, isTop: true);
    // var subordinateModel = Provider.of<SubordinateOfficersViewModel>(context, listen: false);
    // var officerNotSelected = subordinateModel.selectedOfficer == null;
    // if (officerNotSelected) return sl<Toasts>().warningToast(message: 'Please select an officer'.translate, isTop: true);
    // var serviceNotSelected = serviceList.haveList && selectedService == null;
    // if (serviceNotSelected) return sl<Toasts>().warningToast(message: 'Please select a service'.translate, isTop: true);
    var proofFilesModel = Provider.of<ProofFilesViewModel>(context, listen: false);
    if (!proofFilesModel.validateProofFiles()) return;
    _subordinateOfficeApi(complain, typePref, viewPref);
  }

  Future<void> _subordinateOfficeApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var context = navigatorKey.currentState!.context;
    var body = _subordinateOfficeBody(context, complain);
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    var response = await sl<OfficerActionRepository>().sendToSubordinateOffice(body, proofFiles);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _subordinateOfficeBody(BuildContext context, Complain complain) {
    var filenames;
    var context = navigatorKey.currentState!.context;
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
    bodyInformation['other_service'] = otherService.text;
    if (selectedService?.id != null) bodyInformation['service_id'] = '${selectedService!.id!}';
    if (filenames != null) bodyInformation['fileNameByUser'] = filenames;
    return bodyInformation;
  }
}
