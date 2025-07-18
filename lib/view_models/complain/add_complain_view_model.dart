import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grs/di.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/district/district.dart';
import 'package:grs/models/dummy/data_type.dart';
import 'package:grs/models/safety_net/safety_net.dart';
import 'package:grs/repositories/complain_repo.dart';
import 'package:grs/repositories/public_repo.dart';
import 'package:grs/service/app_api_status.dart';
import 'package:grs/service/auth_service.dart';
import 'package:grs/utils/api_url.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/complain/citizen_complains_view_model.dart';
import 'package:grs/view_models/component/doptor_view_model.dart';
import 'package:grs/view_models/component/proof_files_view_model.dart';
import 'package:provider/provider.dart';

class AddComplainViewModel with ChangeNotifier {
  bool loader = false;

  District? division;
  District? district;
  District? subDistrict;
  SafetyNet? safetyNet;
  List<District> divisions = [];
  List<District> districts = [];
  List<District> subDistricts = [];
  List<SafetyNet> safetyNets = [];
  var mobile = TextEditingController();
  var name = TextEditingController();
  var email = TextEditingController();
  var subject = TextEditingController();
  var description = TextEditingController();
  var category = complain_categories.first;

  void initViewModel() {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    if (!sl<AppApiStatus>().divisions) getAllDivisions();
    Provider.of<DoptorViewModel>(context, listen: false).initViewModel();
    Provider.of<ProofFilesViewModel>(context, listen: false).initViewModel();
  }

  void disposeViewModel() {
    loader = false;
    mobile.clear();
    name.clear();
    email.clear();
    subject.clear();
    description.clear();
    districts.clear();
    subDistricts.clear();
    division = null;
    district = null;
    subDistrict = null;
    safetyNet = null;
    category = complain_categories.first;
  }

  void updateUi() => notifyListeners();

  void _loader(bool status) {
    loader = status;
    notifyListeners();
  }

  void selectCategory(DataType data) {
    data.value == '1' ? clearSafetyNet() : clearDoptor();
    category = data;
    notifyListeners();
    if (data.value == '2') getAllSafetyNets();
  }

  void clearSafetyNet() {
    var context = navigatorKey.currentState!.context;
    var doptorViewModel = Provider.of<DoptorViewModel>(context, listen: false);
    safetyNet = null;
    division = null;
    district = null;
    subDistrict = null;
    doptorViewModel.selectedService = null;
  }

  void clearDoptor() {
    var context = navigatorKey.currentState!.context;
    var doptorViewModel = Provider.of<DoptorViewModel>(context, listen: false);
    doptorViewModel.ministry = null;
    doptorViewModel.office = null;
    doptorViewModel.origin = null;
    doptorViewModel.layerOffice = null;
    doptorViewModel.divitionalOffice = null;
    doptorViewModel.selectedService = null;
    doptorViewModel.originList.clear();
    doptorViewModel.layerOfficeList.clear();
    doptorViewModel.divitionalOfficeList.clear();
    doptorViewModel.serviceList.clear();
  }

  Future<void> getAllSafetyNets() async {
    if (sl<AppApiStatus>().safetyNets && safetyNets.haveList) return;
    _loader(true);
    var response = await sl<PublicRepository>().getSafetyNets();
    if (response.haveList) safetyNets = response;
    _loader(false);
  }

  Future<void> getAllDivisions() async {
    var response = await sl<PublicRepository>().getDivisions();
    if (response.haveList) divisions = response;
    notifyListeners();
  }

  Future<void> getAllDistricts() async {
    if (division == null) return sl<Toasts>().warningToast(message: 'Please select division first'.translate, isTop: true);
    _loader(true);
    var endpoint = '${sl<ApiUrl>().districts}${division!.id}';
    var response = await sl<PublicRepository>().getDistricts(endpoint);
    if (response.haveList) districts = response;
    _loader(false);
  }

  Future<void> getAllSubDistricts() async {
    if (district == null) return sl<Toasts>().warningToast(message: 'Please select district first'.translate, isTop: true);
    _loader(true);
    var endpoint = '${sl<ApiUrl>().sub_districts}${district!.id}';
    var response = await sl<PublicRepository>().getDistricts(endpoint);
    if (response.haveList) subDistricts = response;
    _loader(false);
  }

  void selectDivision(District city) {
    districts.clear();
    subDistricts.clear();
    district = null;
    subDistrict = null;
    division = city;
    notifyListeners();
    getAllDistricts();
  }

  void selectDistrict(District city) {
    clearDoptor();
    subDistricts.clear();
    subDistrict = null;
    district = city;
    notifyListeners();
    getAllSubDistricts();
    if (category.value == '2') callServicesByArea(city.id!);
  }

  void selectSubDistrict(District city) {
    clearDoptor();
    subDistrict = city;
    notifyListeners();
  }

  void callServicesByArea(int districtId) {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<DoptorViewModel>(context, listen: false).getAllServiceByArea(districtId);
  }

  Future<void> sendComplainOnTap() async {
    await minimizeKeyboard();
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    var proofFilesModel = Provider.of<ProofFilesViewModel>(context, listen: false);
    if (!proofFilesModel.validateProofFiles()) return;
    _loader(true);
    var body = _complainBody(context);
    var complain = await sl<ComplainRepository>().createComplainApi(body, proofFilesModel.proofFiles);
    if (complain != null) unawaited(Provider.of<CitizenComplainsViewModel>(context, listen: false).getAllComplains());
    if (complain != null) backToPrevious();
    _loader(false);
  }

  Map<String, String> _complainBody(BuildContext context) {
    var filenames;
    var authStatus = sl<AuthService>().authStatus;
    var isSafetyNet = category.value == '2';
    var doptorModel = Provider.of<DoptorViewModel>(context, listen: false);
    var serviceId = doptorModel.selectedService?.id;
    var proofFiles = Provider.of<ProofFilesViewModel>(context, listen: false).proofFiles;
    var officeId = doptorModel.layerOffice == null ? doptorModel.office?.id : doptorModel.layerOffice?.id;
    if (proofFiles.length > 0) filenames = proofFiles.map((item) => item.name.text).join(',');
    Map<String, String> body = {};
    if (!authStatus) body['name'] = name.text;
    if (!authStatus) body['email'] = email.text;
    if (!authStatus) body['mobile_number'] = mobile.text;
    if (authStatus) body['complainant_id'] = '${sl<ProfileHelper>().citizenProfile.id}';
    body['subject'] = subject.text;
    body['description'] = description.text;
    if (!isSafetyNet && officeId != null) body['officeId'] = '$officeId';
    body['is_grs_user'] = authStatus ? '1' : '0';
    if (serviceId != null) body['service_id'] = '$serviceId';
    if (isSafetyNet) body['division_id'] = '${division!.id}';
    if (isSafetyNet) body['district_id'] = '${district!.id}';
    if (isSafetyNet) body['upazila_id'] = '${subDistrict!.id}';
    body['complaint_category'] = authStatus ? complain_categories.first.value : category.value;
    if (safetyNet != null) body['sp_programme_id'] = '${safetyNet?.id}';
    if (filenames != null) body['fileNameByUser'] = filenames;
    return body;
  }

  Future<void> checkUser() async {
    if (mobile.text.length < 10) return;
    var appUser = await sl<ComplainRepository>().checkUser(mobile.text);
    if (appUser == null) return;
    if (appUser.name != null) name.text = appUser.name!;
    if (appUser.email != null) email.text = appUser.email!;
    notifyListeners();
  }
}
