import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'package:grs/constants/date_formats.dart';
import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/libraries/formatters.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/repositories/officer_action_repo.dart';
import 'package:grs/service/storage_service.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/branch_officers_view_model.dart';
import 'package:grs/view_models/component/proof_files_view_model.dart';

class ProvideServiceViewModel with ChangeNotifier {
  bool loader = false;
  DateTime? serviceDate;
  // DataType? selectedLanguage;
  var comment = TextEditingController();

  void initViewModel() {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    comment.text = 'Notify by providing service within due date'.translate;
    Provider.of<BranchOfficersViewModel>(context, listen: false).initViewModel();
    Provider.of<ProofFilesViewModel>(context, listen: false).initViewModel();
  }

  void disposeViewModel() {
    loader = false;
    comment.clear();
    serviceDate = null;
    // selectedLanguage = null;
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
    if (serviceDate == null) return sl<Toasts>().warningToast(message: 'Please select the date of service'.translate, isTop: true);
    if (comment.text.isEmpty) return sl<Toasts>().warningToast(message: 'Please write a comment'.translate, isTop: true);
    // if (selectedLanguage == null) return sl<Toasts>().warningToast(message: 'Please select a language'.translate, isTop: true);
    var selectedOfficer = Provider.of<BranchOfficersViewModel>(context, listen: false).selectedOfficer;
    if (selectedOfficer == null) return sl<Toasts>().warningToast(message: 'Please select an officer'.translate, isTop: true);
    var proofFilesModel = Provider.of<ProofFilesViewModel>(context, listen: false);
    if (!proofFilesModel.validateProofFiles()) return;
    _provideServiceApi(complain, typePref, viewPref);
  }

  Future<void> _provideServiceApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var context = navigatorKey.currentState!.context;
    var body = _provideServiceBody(context, complain);
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    var response = await sl<OfficerActionRepository>().providingService(typePref, body, proofFiles);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _provideServiceBody(BuildContext context, Complain complain) {
    var filenames;
    var language = sl<StorageService>().getLanguage;
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
    bodyInformation['language'] = language;
    bodyInformation['note'] = comment.text;
    bodyInformation['deadline'] = sl<Formatters>().formatDate(DATE_FORMAT_1, '$serviceDate');
    bodyInformation['guidance_receiver'] = json.encode(_officerInfo(context));
    if (filenames != null) bodyInformation['fileNameByUser'] = filenames;
    return bodyInformation;
  }

  dynamic _officerInfo(BuildContext context) {
    var officer = Provider.of<BranchOfficersViewModel>(context, listen: false).selectedOfficer;
    var officerBody = {
      'id': officer?.id,
      'office_id': officer?.officeId,
      'office_name_bng': officer?.officeNameBng,
      'office_unit_organogram_id': officer?.officeUnitOrganogramId,
      'office_unit_id': officer?.officeUnitId,
      'employee_record_id': officer?.employeeRecordId,
      'label': officer?.label,
      'designation': officer?.designation,
      'unit_name_bng': officer?.unitNameBng,
      'name': officer?.name,
      'name_en': officer?.nameEn,
      'expanded': false,
      'checked': true
    };
    return officerBody;
  }
}
