import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:grs/di.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/repositories/citizen_action_repo.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/proof_files_view_model.dart';
import 'package:provider/provider.dart';

class EvidenceMaterialViewModel with ChangeNotifier {
  bool loader = false;
  var note = TextEditingController();

  void initViewModel() {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
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

  Future<void> sendOnTap(Complain complain) async {
    await minimizeKeyboard();
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    var message1 = 'Please write a note for evidence material'.translate;
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: message1, isTop: true);
    var proofFilesModel = Provider.of<ProofFilesViewModel>(context, listen: false);
    if (!proofFilesModel.validateProofFiles()) return;
    _loader(true);
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    var body = _evidenceMaterialBody(context, complain);
    var response = await sl<CitizenActionRepository>().evidenceMaterial(proofFiles: proofFiles, body: body);
    if (response) backToPrevious();
    _loader(false);
  }

  Map<String, String> _evidenceMaterialBody(BuildContext context, Complain complain) {
    var filenames;
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    if (proofFiles.length > 0) filenames = proofFiles.map((item) => item.name.text).join(',');
    Map<String, String> bodyInformation = {};
    bodyInformation['complaint_id'] = '${complain.id}';
    bodyInformation['note'] = note.text;
    if (filenames != null) bodyInformation['fileNameByUser'] = filenames;
    return bodyInformation;
  }
}
