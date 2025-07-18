import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/complain/complain_details_api.dart';
import 'package:grs/models/dummy/loader.dart';
import 'package:grs/models/history/complain_history.dart';
import 'package:grs/repositories/citizen_action_repo.dart';
import 'package:grs/repositories/complain_repo.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/complain/citizen_complains_view_model.dart';

class CitizenComplainDetailsViewModel with ChangeNotifier {
  ComplainDetailsApi? complainDetails;
  List<ComplainHistory> histories = [];
  Loader loader = Loader(initial: true, common: true);

  void initViewModel(Complain data) {
    getComplainHistory(data);
    getComplainDetails(data);
  }

  void disposeViewModel() {
    complainDetails = null;
    histories.clear();
    loader = Loader(initial: true, common: true);
  }

  void updateUi() => notifyListeners();

  Future<void> getComplainHistory(Complain data) async {
    var responseList = await sl<ComplainRepository>().citizenComplainMovement(data);
    histories.clear();
    if (responseList.haveList) histories.addAll(responseList);
    notifyListeners();
  }

  Future<void> getComplainDetails(Complain data) async {
    var response = await sl<ComplainRepository>().complainDetails(data);
    if (response != null) complainDetails = response;
    loader = Loader(initial: false, common: false);
    notifyListeners();
  }

  Future<void> sendRating(var body) async {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    loader.common = true;
    notifyListeners();
    var response = await sl<CitizenActionRepository>().sendComplainRating(body);
    if (response) unawaited(Provider.of<CitizenComplainsViewModel>(context, listen: false).getAllComplains());
    if (response) backToPrevious();
    loader.common = false;
    notifyListeners();
  }

  void updateComplainInfo(Complain data) {
    complainDetails?.complain = data;
    notifyListeners();
  }

/*Future<void> sendAppeal(var body) async {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    loader.common = true;
    notifyListeners();
    var response = await sl<ComplainRepository>().sendAppealRequest(body);
    if (response) unawaited(Provider.of<ComplainsViewModel>(context, listen: false).getAllComplains());
    if (response) backToPrevious();
    loader.common = false;
    notifyListeners();
  }*/
}
