import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/dummy/loader.dart';
import 'package:grs/repositories/complain_repo.dart';
import 'package:grs/service/storage_service.dart';
import 'package:grs/utils/api_url.dart';

class MyComplainsViewModel with ChangeNotifier {
  int page = 1;
  bool moreComplains = true;
  List<Complain> complainList = [];
  Loader loader = Loader(initial: true, common: true);

  void initViewModel() => getUserComplains();

  void disposeViewModel() {
    page = 1;
    moreComplains = true;
    complainList.clear();
    loader = Loader(initial: true, common: true);
  }

  Future<void> getUserComplains() async {
    var employeeRecordId = sl<StorageService>().getEmployeeRecordId;
    var endpoint = '${sl<ApiUrl>().allComplains}?complainant_id=$employeeRecordId';
    var responseList = await sl<ComplainRepository>().allComplains(endpoint);
    if (responseList.length < 20) page = page + 1;
    if (responseList.length < 20) moreComplains = false;
    if (responseList.haveList) complainList.addAll(responseList);
    if (complainList.haveList) complainList = complainList.reversed.toList();
    loader = Loader(initial: false, common: false);
    notifyListeners();
  }

  Future<void> refreshUserComplains() async{
    var employeeRecordId = sl<StorageService>().getEmployeeRecordId;
    var endpoint = '${sl<ApiUrl>().allComplains}?complainant_id=$employeeRecordId';
    var responseList = await sl<ComplainRepository>().allComplains(endpoint);
    if (responseList.length < 20) page = page + 1;
    if (responseList.length < 20) moreComplains = false;
    if (responseList.haveList) complainList.addAll(responseList);
    if (complainList.haveList) complainList = complainList.reversed.toList();
    notifyListeners();
  }

  Future<void> checkPagination(ScrollController controller) async {
    controller.addListener(() {
      var maxPosition = controller.position.pixels == controller.position.maxScrollExtent;
      if (maxPosition && moreComplains) getUserComplains();
    });
  }
}
