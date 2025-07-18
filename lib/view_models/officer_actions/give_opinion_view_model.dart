import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/branch/officer.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/repositories/officer_action_repo.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/branch_officers_view_model.dart';
import 'package:grs/view_models/component/proof_files_view_model.dart';

class GiveOpinionViewModel with ChangeNotifier {
  bool loader = false;
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
    // var selectedOfficers = Provider.of<BranchOfficersViewModel>(context, listen: false).selectedOfficers;
    // if (!selectedOfficers.haveList) return sl<Toasts>().warningToast(message: 'Please select an officer'.translate, isTop: true);
    var proofFilesModel = Provider.of<ProofFilesViewModel>(context, listen: false);
    if (!proofFilesModel.validateProofFiles()) return;
    _giveOpinionApi(complain, typePref, viewPref);
  }

  Future<void> _giveOpinionApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var context = navigatorKey.currentState!.context;
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    var selectedOfficers = Provider.of<BranchOfficersViewModel>(context, listen: false).selectedOfficers;
    var body = _giveOpinionBody(context, complain, selectedOfficers);
    var response = await sl<OfficerActionRepository>().giveOpinion(typePref, body, proofFiles);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _giveOpinionBody(BuildContext context, Complain complain, List<Officer> officers) {
    var filenames;
    var officerLabels = [];
    var username = sl<ProfileHelper>().officerProfile?.username;
    var officeId = sl<ProfileHelper>().officeInfo.officeId;
    var employeeRecordId = sl<ProfileHelper>().officerProfile?.employeeRecordId;
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    officers.forEach((item) => officerLabels.add(item.label));
    if (proofFiles.length > 0) filenames = proofFiles.map((item) => item.name.text).join(',');
    var label = officerLabels.join(', ');
    var modifiedNote = '${note.text} $label';
    Map<String, String> bodyInformation = {};
    if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
    if (officeId != null) bodyInformation['office_id'] = '$officeId';
    if (username != null) bodyInformation['username'] = username;
    if (employeeRecordId != null) bodyInformation['to_employee_record_id'] = '$employeeRecordId';
    bodyInformation['note'] = modifiedNote;
    if (filenames != null) bodyInformation['fileNameByUser'] = filenames;
    return bodyInformation;
  }
}
