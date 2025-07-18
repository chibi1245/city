import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/repositories/officer_action_repo.dart';
import 'package:grs/view_models/component/signature_files_view_model.dart';
import 'package:provider/provider.dart';

import '../../utils/keys.dart';

class ApproveDisapproveViewModel with ChangeNotifier {
  bool loader = false;

  void initViewModel() {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<SignatureFilesViewModel>(context, listen: false).initViewModel();
  }

  void disposeViewModel() {
    loader = false;
  }

  void updateUi() => notifyListeners();

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  void sendOnTap(Complain complain, ActionTypePref typePref, ActionViewPref viewPref, bool isAgree) {
    minimizeKeyboard();
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    var message1 = 'Please upload your signature files'.translate;
    var signatureFilesModel = Provider.of<SignatureFilesViewModel>(context, listen: false);
    if (signatureFilesModel.signatureFiles.isEmpty) return sl<Toasts>().warningToast(message: message1, isTop: true);
    if (!signatureFilesModel.validateSignatureFiles()) return;
    _approveDisapproveApi(complain, typePref, viewPref, isAgree);
  }

  Future<void> _approveDisapproveApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref, bool isAgree) async {
    _loader(true);
    var context = navigatorKey.currentState!.context;
    var body = _approveDisapproveBody(context ,complain, isAgree);
    var signatureFiles = Provider.of<SignatureFilesViewModel>(context, listen: false).signatureFiles;
    var response = await sl<OfficerActionRepository>().approveOrDisapprove(body, signatureFiles);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _approveDisapproveBody(BuildContext context,Complain complain, bool isAgree) {
    var filenames;
    var username = sl<ProfileHelper>().officerProfile?.username;
    var officeId = sl<ProfileHelper>().officeInfo.officeId;
    var employeeRecordId = sl<ProfileHelper>().officerProfile?.employeeRecordId;
    var signatureFiles = Provider.of<SignatureFilesViewModel>(context, listen: false).signatureFiles;
    if (signatureFiles.length > 0) filenames = signatureFiles.map((item) => item.name.text).join(',');
    Map<String, String> bodyInformation = {};
    if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
    if (officeId != null) bodyInformation['office_id'] = '$officeId';
    if (username != null) bodyInformation['username'] = username;
    if (employeeRecordId != null) bodyInformation['to_employee_record_id'] = '$employeeRecordId';
    if (filenames != null) bodyInformation['fileNameByUser'] = filenames;
    bodyInformation['opinion'] = isAgree ? 'AGREED' : 'DISAGREED';
    return bodyInformation;
  }
}
