import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/models/dummy/data_type.dart';
import 'package:grs/repositories/public_repo.dart';
import 'package:grs/service/auth_service.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/component/doptor_view_model.dart';

class ImprovementViewModel with ChangeNotifier {
  bool loader = false;
  DataType effect = probable_effects[0];
  DataType suggestion = suggestion_subjects[0];

  var mobile = TextEditingController();
  var name = TextEditingController();
  var email = TextEditingController();
  var search = TextEditingController();
  var currentSituation = TextEditingController();
  var yourSuggestion = TextEditingController();

  void initViewModel() {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<DoptorViewModel>(context, listen: false).initViewModel();
    if (!sl<AuthService>().authStatus) return;
    _setInitialData();
  }

  void disposeViewModel() {
    loader = false;
    mobile.clear();
    name.clear();
    email.clear();
    search.clear();
    currentSituation.clear();
    yourSuggestion.clear();
    effect = probable_effects[0];
    suggestion = suggestion_subjects[0];
  }

  void updateUi() => notifyListeners();

  void _setInitialData() {
    if (sl<ProfileHelper>().isCitizen) {
      var profile = sl<ProfileHelper>().citizenProfile;
      if (profile.name != null) name.text = profile.name!;
      if (profile.mobileNumber != null) mobile.text = profile.mobileNumber!;
      if (profile.email != null) email.text = profile.email!;
    } else {
      var profile = sl<ProfileHelper>().employee;
      name.text = profile.name.trim();
      if (profile.personalMobile != null) mobile.text = profile.personalMobile!;
      if (profile.personalEmail != null) email.text = profile.personalEmail!;
    }
    notifyListeners();
  }

  void _loader(bool status) {
    loader = status;
    notifyListeners();
  }

  void selectSuggestion(DataType dataType) {
    suggestion = dataType;
    notifyListeners();
  }

  void selectQuality(DataType dataType) {
    effect = dataType;
    notifyListeners();
  }

  Future<void> sendSuggestionOnTap() async {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    _loader(true);
    var body = _improvementBody(context);
    var response = await sl<PublicRepository>().saveImprovementFeedback(body);
    if (response) backToPrevious();
    _loader(false);
  }

  Map<String, dynamic> _improvementBody(BuildContext context) {
    var doptorModel = Provider.of<DoptorViewModel>(context, listen: false);
    var officeId = doptorModel.layerOffice == null ? doptorModel.office?.id : doptorModel.layerOffice?.id;
    Map<String, dynamic> body = {
      'name': name.text,
      'email': email.text,
      'phone': mobile.text,
      'office_id': officeId,
      'office_service_id': doptorModel.selectedService?.id,
      'office_service_name': doptorModel.selectedService?.service_name,
      'description': currentSituation.text,
      'suggestion': yourSuggestion.text,
      'type_of_opinion': suggestion.value,
      'probable_improvement': effect.value,
      'status': null,
    };
    return body;
  }
}
