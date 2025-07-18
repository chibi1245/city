import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/helpers/complain_helper.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/dummy/complain_menu.dart';
import 'package:grs/models/dummy/loader.dart';
import 'package:grs/repositories/complain_repo.dart';

class OfficerComplainsViewModel with ChangeNotifier {
  int menuIndex = 0;
  int? _totalPages = 1;
  int currentPage = 1;
  List<ComplainMenu> complainMenus = [];
  Loader loader = Loader(initial: true, common: true);

  void initViewModel() {
    menuIndex = 0;
    currentPage = 1;
    complainMenus = complainMenuList;
    sl<ComplainRepository>().setPageNumberForMenu(menuIndex, currentPage);
    sl<ComplainRepository>().setTotalPageNumberForMenu(menuIndex);
    notifyListeners();
    getAllComplains();
  }

  void updateUi() => notifyListeners();

  int? get totalPages => _totalPages;

  set totalPages(int? value) {
    _totalPages = value;
    notifyListeners();
  }

  Future<void> getAllComplains() async {
    loader.common = true;
    var menu = complainMenus[menuIndex];
    notifyListeners();
    var endpoint = sl<ComplainHelper>().complainListApiUrl(menu, currentPage-1);
    var complainList = await sl<ComplainRepository>().allComplains(endpoint);
    sl<ComplainRepository>().updateTotalPageNumber(menuIndex);
    totalPages = sl<ComplainRepository>().getTotalPageNumberForMenu(menuIndex);
    menu.complains.clear();
    if (complainList.haveList) menu.complains.addAll(complainList);
    loader = Loader(initial: false, common: false);
    notifyListeners();
  }

  Future<void> refreshAllComplains() async {
    var menu = complainMenus[menuIndex];
    var endpoint = sl<ComplainHelper>().complainListApiUrl(menu, currentPage-1);
    var complainList = await sl<ComplainRepository>().allComplains(endpoint);
    sl<ComplainRepository>().updateTotalPageNumber(menuIndex);
    totalPages = sl<ComplainRepository>().getTotalPageNumberForMenu(menuIndex);
    menu.complains.clear();
    if (complainList.haveList) menu.complains.addAll(complainList);
    notifyListeners();
  }

  void setCurrentPage(int? pageNo){
    currentPage = pageNo ?? 1;
    notifyListeners();
    getAllComplains();
  }

  void selectMenuFromDrawer(int index, ScrollController controller) {
    selectMenu(index);
    var curve = Curves.easeOut;
    const duration = Duration(milliseconds: 300);
    var max = controller.position.maxScrollExtent;
    var min = controller.position.minScrollExtent;
    controller.animateTo(index > 3 ? max : min, curve: curve, duration: duration);
  }

  void selectMenu(int index) {
    sl<ComplainRepository>().updatePageNumber(menuIndex, currentPage);
    menuIndex = index;
    currentPage = sl<ComplainRepository>().getPageNumberForMenu(menuIndex);
    notifyListeners();
    if (!complainMenus[menuIndex].complains.haveList){
      getAllComplains();
    } else{
      totalPages = sl<ComplainRepository>().getTotalPageNumberForMenu(menuIndex);
      notifyListeners();
    }
  }

  void updateComplainInfo(Complain data) {
    if (!complainMenus[menuIndex].complains.haveList) return;
    var index = complainMenus[menuIndex].complains.indexWhere((item) => item.id == data.id);
    if (index < 0) return;
    complainMenus[menuIndex].complains[index] = data;
    notifyListeners();
    getAllComplains();
  }
}
