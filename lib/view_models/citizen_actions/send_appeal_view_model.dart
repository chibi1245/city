import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/repositories/citizen_action_repo.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/proof_files_view_model.dart';

class SendAppealViewModel with ChangeNotifier {
  bool loader = false;
  var note = TextEditingController();

  void initViewModel() {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    note.text = 'ok, I am concern of hearing date'.translate;
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

  void sendOnTap(Complain complain) {
    minimizeKeyboard();
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    if (note.text.isEmpty) return sl<Toasts>().errorToast(message: 'Please write your note here'.translate, isTop: true);
    var proofFilesModel = Provider.of<ProofFilesViewModel>(context, listen: false);
    if (!proofFilesModel.validateProofFiles()) return;
    _sendAppealApi(context, complain);
  }

  Future<void> _sendAppealApi(BuildContext context, Complain complain) async {
    _loader(true);
    Map<String, String> body = _sendAppealBody(context, complain);
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    var response = await sl<CitizenActionRepository>().sendForAppeal(body, proofFiles);
    if (response) backToPrevious();
    _loader(false);
  }

  Map<String, String> _sendAppealBody(BuildContext context, Complain complain) {
    var filenames;
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    if (proofFiles.length > 0) filenames = proofFiles.map((item) => item.name.text).join(',');
    Map<String, String> bodyInformation = {};
    bodyInformation['note'] = note.text;
    if (complain.id != null) bodyInformation['complaint_id'] = '${complain.id}';
    if (filenames != null) bodyInformation['fileNameByUser'] = filenames;
    return bodyInformation;
  }
}
