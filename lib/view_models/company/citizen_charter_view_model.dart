import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/models/citizen_charter/citizen_charter_api.dart';
import 'package:grs/repositories/public_repo.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/doptor_view_model.dart';

class CitizenCharterViewModel with ChangeNotifier {
  bool loader = false;
  bool isExpanded = true;
  CitizenCharterApi? charterApi;

  void initViewModel() {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<DoptorViewModel>(context, listen: false).initViewModel();
  }

  void disposeViewModel() {
    loader = false;
    isExpanded = true;
  }

  void updateUi() => notifyListeners();

  Future<void> getCitizenCharters(int officeId) async {
    loader = true;
    notifyListeners();
    var response = await sl<PublicRepository>().citizenCharterInfo(officeId);
    if (response != null) charterApi = response;
    // isExpanded = false;
    loader = false;
    notifyListeners();
  }
}
