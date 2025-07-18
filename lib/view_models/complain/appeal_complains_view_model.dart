import 'package:flutter/material.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/helpers/complain_helper.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/dummy/complain_menu.dart';
import 'package:grs/models/dummy/loader.dart';
import 'package:grs/repositories/complain_repo.dart';

class AppealComplainsViewModel with ChangeNotifier {
  int menuIndex = 0;
  int? _totalPages = 1;
  int currentPage = 1;
  List<ComplainMenu> appealMenus = [];
  Loader loader = Loader(initial: true, common: true);

  void initViewModel(int menuInt, ScrollController controller) {
    menuIndex = menuInt;
    currentPage = 1;
    if (!appealMenus.haveList) appealMenus = appealMenuList;
    sl<ComplainRepository>().setPageNumberForAppealMenu(menuIndex, currentPage);
    sl<ComplainRepository>().setTotalPageNumberForAppealMenu(menuIndex);
    notifyListeners();
    var haveData = appealMenus[menuIndex].complains.haveList;
    if (haveData) loader = Loader(initial: false, common: false);
    if (haveData) notifyListeners();
    if (haveData) return;
    getAllAppealComplains();
  }

  void disposeViewModel() {}

  void updateUi() => notifyListeners();

  int? get totalPages => _totalPages;

  set totalPages(int? value) {
    _totalPages = value;
    notifyListeners();
  }

  Future<void> getAllAppealComplains() async {
    loader.common = true;
    var menu = appealMenus[menuIndex];
    notifyListeners();
    var endpoint = sl<ComplainHelper>().appealListApiUrl(menu, currentPage-1);
    var complainList = await sl<ComplainRepository>().allComplains(endpoint);
    sl<ComplainRepository>().updateTotalAppealPageNumber(menuIndex);
    totalPages = sl<ComplainRepository>().getTotalPageNumberForAppealMenu(menuIndex);
    menu.complains.clear();
    if (complainList.haveList) menu.complains.addAll(complainList);
    loader = Loader(initial: false, common: false);
    notifyListeners();
  }

  Future<void> refreshAppealComplains() async {
    var menu = appealMenus[menuIndex];
    var endpoint = sl<ComplainHelper>().appealListApiUrl(menu, currentPage-1);
    var complainList = await sl<ComplainRepository>().allComplains(endpoint);
    sl<ComplainRepository>().updateTotalAppealPageNumber(menuIndex);
    totalPages = sl<ComplainRepository>().getTotalPageNumberForAppealMenu(menuIndex);
    menu.complains.clear();
    if (complainList.haveList) menu.complains.addAll(complainList);
    notifyListeners();
  }

  void setCurrentPage(int? pageNo){
    currentPage = pageNo ?? 1;
    notifyListeners();
    getAllAppealComplains();
  }

  void selectMenu(int index) {
    sl<ComplainRepository>().updateAppealPageNumber(menuIndex, currentPage);
    menuIndex = index;
    currentPage = sl<ComplainRepository>().getPageNumberForAppealMenu(menuIndex);
    notifyListeners();
    if (!appealMenus[menuIndex].complains.haveList){
      getAllAppealComplains();
    } else{
      totalPages = sl<ComplainRepository>().getTotalPageNumberForAppealMenu(menuIndex);
      notifyListeners();
    }
  }

  void updateComplainInfo(Complain data) {
    if (!appealMenus[menuIndex].complains.haveList) return;
    var index = appealMenus[menuIndex].complains.indexWhere((item) => item.id == data.id);
    if (index < 0) return;
    appealMenus[menuIndex].complains[index] = data;
    notifyListeners();
    getAllAppealComplains();
  }
}
