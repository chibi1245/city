import 'package:flutter/material.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/complain/complain_details_api.dart';
import 'package:grs/models/dummy/loader.dart';
import 'package:grs/models/history/complain_history.dart';
import 'package:grs/repositories/appeal_repo.dart';
import 'package:grs/repositories/blacklist_repo.dart';
import 'package:grs/repositories/complain_repo.dart';
import 'package:grs/utils/api_url.dart';

import '../../service/storage_service.dart';

class AppealComplainDetailsViewModel with ChangeNotifier {
  int tabIndex = 0;
  bool isGro = false;
  ComplainDetailsApi? complainDetails;
  List<ComplainHistory> complainHistories = [];
  List<ComplainHistory> appealHistories = [];
  List<Complain> complainantComplainList = [];
  Loader loader = Loader(initial: true, common: true);

  void initViewModel(Complain data) {
    complainDetails = null;
    isGro = sl<StorageService>().getUserType.toLowerCase() == 'gro';
    notifyListeners();
    getAppealHistory(data);
    getComplainHistory(data);
    getComplainDetails(data);
    if (data.complainantId != null) getComplaintComplains(data);
  }

  void disposeViewModel() {
    appealHistories.clear();
    complainHistories.clear();
    tabIndex = 0;
    complainDetails = null;
    complainantComplainList.clear();
    loader = Loader(initial: true, common: true);
  }

  void handleTabChange(TabController tabController) {
    tabIndex = tabController.index;
    notifyListeners();
  }

  void updateUi() => notifyListeners();

  Future<void> getComplainDetails(Complain data) async {
    var response = await sl<ComplainRepository>().complainDetails(data);
    if (response != null) complainDetails = response;
    loader = Loader(initial: false, common: false);
    notifyListeners();
  }

  Future<void> getComplainHistory(Complain data) async {
    var response = await sl<ComplainRepository>().officerComplainMovement(data);
    complainHistories.clear();
    if (response.haveList) complainHistories = response;
    notifyListeners();
  }

  Future<void> getAppealHistory(Complain data) async {
    var response = await sl<AppealRepository>().appealHistories(data);
    appealHistories.clear();
    if (response.haveList) appealHistories = response;
    notifyListeners();
  }

  Future<void> getComplaintComplains(Complain data) async {
    var endpoint = '${sl<ApiUrl>().allComplains}?complainant_id=${data.complainantId}';
    var complainList = await sl<ComplainRepository>().allComplains(endpoint);
    complainantComplainList.clear();
    if (complainList.haveList) complainantComplainList.addAll(complainList);
    if (complainList.haveList) complainantComplainList = complainantComplainList.reversed.toList();
    notifyListeners();
  }

  Future<void> addAsBlacklist(var body) async {
    loader.common = true;
    notifyListeners();
    var response = await sl<BlacklistRepository>().saveAsBlacklist(body);
    if (response != null) {
      complainDetails?.complainedUser?.isBlacklisted = response.blacklisted;
      complainDetails?.complainedUser?.blacklisterOfficeId = response.officeId;
      complainDetails?.complainedUser?.blacklisterOfficeName = response.officeName;
      complainDetails?.complainedUser?.blacklistReason = response.reason;
    }
    loader.common = false;
    notifyListeners();
  }

  void updateComplainInfo(Complain data) {
    complainDetails?.complain = data;
    notifyListeners();
  }

  Future<void> sendFeedback() async {
    loader.common = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    loader.common = false;
    notifyListeners();
  }

  Future<void> sendAppeal() async {
    loader.common = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    loader.common = false;
    notifyListeners();
  }
}
