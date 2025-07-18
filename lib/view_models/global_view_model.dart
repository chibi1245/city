import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/app_helper.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/dummy/language.dart';
import 'package:grs/service/auth_service.dart';
import 'package:grs/service/routes.dart';
import 'package:grs/service/storage_service.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/complain/appeal_complains_view_model.dart';
import 'package:grs/view_models/complain/citizen_complains_view_model.dart';
import 'package:grs/view_models/complain/officer_complains_view_model.dart';

class GlobalViewModel with ChangeNotifier {
  bool logoutLoader = false;
  Language language = allLanguages.first;

  Future<void> initViewModel() async {
    await Future.delayed(const Duration(milliseconds: 100));
    var languageCode = sl<StorageService>().getLanguage;
    language = allLanguages.firstWhere((item) => item.code == languageCode);
    notifyListeners();
  }

  void selectLanguage(BuildContext context, int index) {
    language = allLanguages[index];
    navigatorKey.currentState!.context.setLocale(Locale(language.code));
    sl<StorageService>().setLanguage(language.code);
    notifyListeners();
    sl<AppHelper>().updateAllUi();
    backToPrevious();
    sl<Toasts>().successToast(message: '${'Your language is'.translate} ${language.name}', isTop: true);
  }

  Future<void> logoutUser() async {
    backToPrevious();
    logoutLoader = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1500));
    sl<AuthService>().removeStorageData();
    unawaited(sl<Routes>().grsOnboardScreen().pushAndRemoveUntil());
    logoutLoader = false;
    notifyListeners();
    clearStates();
  }

  void clearStates() {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    var appealMenus = Provider.of<AppealComplainsViewModel>(context, listen: false).appealMenus;
    var complainMenus = Provider.of<OfficerComplainsViewModel>(context, listen: false).complainMenus;
    Provider.of<CitizenComplainsViewModel>(context, listen: false).complainList.clear();
    appealMenus.forEach((item) => item.complains.clear());
    complainMenus.forEach((item) => item.complains.clear());
    notifyListeners();
  }
}
