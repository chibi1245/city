import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/dummy/loader.dart';
import 'package:grs/repositories/complain_repo.dart';
import 'package:grs/service/auth_service.dart';
import 'package:grs/service/storage_service.dart';
import 'package:grs/utils/api_url.dart';

class CitizenComplainsViewModel with ChangeNotifier {
  List<Complain> complainList = [];
  Loader loader = Loader(initial: true, common: true);

  void initViewModel() {
    if (!sl<AuthService>().authStatus) loader = Loader(initial: false, common: false);
    notifyListeners();
    if (sl<AuthService>().authStatus) getAllComplains();
  }

  void updateUi() => notifyListeners();

  Future<void> getAllComplains() async {
    loader.common = true;
    notifyListeners();
    var userId = sl<StorageService>().getUserId;
    var endpoint = '${sl<ApiUrl>().allComplains}?complainant_id=$userId';
    var responseList = await sl<ComplainRepository>().allComplains(endpoint);
    if (responseList.length > 0) complainList = responseList;
    loader = Loader(initial: false, common: false);
    notifyListeners();
  }

  Future<void> refreshComplains() async {
    var userId = sl<StorageService>().getUserId;
    var endpoint = '${sl<ApiUrl>().allComplains}?complainant_id=$userId';
    var responseList = await sl<ComplainRepository>().allComplains(endpoint);
    if (responseList.length > 0) complainList = responseList;
    notifyListeners();
  }

  void addComplain(Complain complain) {
    complainList.insert(0, complain);
    notifyListeners();
  }

  void updateComplainInfo(Complain data) {
    if (!complainList.haveList) return;
    var index = complainList.indexWhere((item) => item.id == data.id);
    if (index < 0) return;
    complainList[index] = data;
    notifyListeners();
    getAllComplains();
  }
}
