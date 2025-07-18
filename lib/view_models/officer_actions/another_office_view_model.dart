import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/repositories/officer_action_repo.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/doptor_view_model.dart';
import 'package:grs/view_models/component/proof_files_view_model.dart';

class AnotherOfficeViewModel with ChangeNotifier {
  bool loader = false;
  var note = TextEditingController();
  var otherService = TextEditingController();

  void initViewModel() {
    note.text = 'sent_to_another_office_note'.translate;
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<DoptorViewModel>(context, listen: false).initViewModel();
    Provider.of<ProofFilesViewModel>(context, listen: false).initViewModel();
  }

  void disposeViewModel() {
    loader = false;
    note.clear();
    otherService.clear();
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
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write a note'.translate, isTop: true);
    var doptorViewmodel = Provider.of<DoptorViewModel>(context, listen: false);
    if (!doptorViewmodel.doptorDataValidation()) return;
    var proofFilesModel = Provider.of<ProofFilesViewModel>(context, listen: false);
    if (!proofFilesModel.validateProofFiles()) return;
    _anotherOfficeApi(complain, typePref, viewPref);
  }

  Future<void> _anotherOfficeApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var context = navigatorKey.currentState!.context;
    var body = _anotherOfficeBody(context, complain);
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    var response = await sl<OfficerActionRepository>().sendToAnotherOffice(body, proofFiles);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _anotherOfficeBody(BuildContext context, Complain complain) {
    var filenames;
    var username = sl<ProfileHelper>().officerProfile?.username;
    var employeeRecordId = sl<ProfileHelper>().officerProfile?.employeeRecordId;
    var doptorModel = Provider.of<DoptorViewModel>(context, listen: false);
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    var serviceId = doptorModel.selectedService?.id;
    var officeId = doptorModel.layerOffice == null ? doptorModel.office?.id : doptorModel.layerOffice?.id;
    if (proofFiles.length > 0) filenames = proofFiles.map((item) => item.name.text).join(',');
    Map<String, String> bodyInformation = {};
    bodyInformation['complaint_id'] = '${complain.id}';
    bodyInformation['note'] = note.text;
    if (username != null) bodyInformation['username'] = username;
    if (officeId != null) bodyInformation['office_id'] = '$officeId';
    bodyInformation['other_service'] = otherService.text;
    if (serviceId != null) bodyInformation['service_id'] = '$serviceId';
    if (employeeRecordId != null) bodyInformation['to_employee_record_id'] = '$employeeRecordId';
    if (filenames != null) bodyInformation['fileNameByUser'] = filenames;
    return bodyInformation;
  }
}
