import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/models/blacklist/blacklist.dart';
import 'package:grs/models/dummy/loader.dart';
import 'package:grs/repositories/blacklist_repo.dart';
import 'package:grs/utils/api_url.dart';

class BlacklistRequestsViewModel with ChangeNotifier {
  int page = 1;
  bool moreBlacklists = true;
  List<Blacklist> blacklists = [];
  Loader loader = Loader(initial: true, common: true);

  void initViewModel() => getAllRequestedBlacklists();

  void disposeViewModel() {
    page = 1;
    moreBlacklists = true;
    blacklists.clear();
    loader = Loader(initial: true, common: true);
  }

  void updateUi() => notifyListeners();

  Future<void> getAllRequestedBlacklists() async {
    var officeId = sl<ProfileHelper>().officeInfo.officeId;
    var endpoint = '${sl<ApiUrl>().requestedBlacklists}$officeId&page=$page';
    var responseList = await sl<BlacklistRepository>().getAllBlackLists(endpoint);
    if (responseList.length < 20) page = page + 1;
    if (responseList.length < 20) moreBlacklists = false;
    if (responseList.haveList) blacklists.addAll(responseList);
    // if (blacklists.haveList) blacklists = blacklists.reversed.toList();
    loader = Loader(initial: false, common: false);
    notifyListeners();
  }

  Future<void> refreshAllRequestedBlackLists() async {
    var officeId = sl<ProfileHelper>().officeInfo.officeId;
    var endpoint = '${sl<ApiUrl>().requestedBlacklists}$officeId&page=$page';
    var responseList = await sl<BlacklistRepository>().getAllBlackLists(endpoint);
    if (responseList.length < 20) page = page + 1;
    if (responseList.length < 20) moreBlacklists = false;
    if (responseList.haveList) blacklists.addAll(responseList);
    // if (blacklists.haveList) blacklists = blacklists.reversed.toList();
    notifyListeners();
  }

  Future<void> checkPagination(ScrollController controller) async {
    controller.addListener(() {
      var maxPosition = controller.position.pixels == controller.position.maxScrollExtent;
      if (maxPosition && moreBlacklists) getAllRequestedBlacklists();
    });
  }
}
