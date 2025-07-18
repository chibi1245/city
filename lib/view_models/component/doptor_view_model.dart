import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/doptor_apis/divitional_office.dart';
import 'package:grs/models/doptor_apis/ministry.dart';
import 'package:grs/models/doptor_apis/office.dart';
import 'package:grs/models/doptor_apis/office_by_layer.dart';
import 'package:grs/models/doptor_apis/origin.dart';
import 'package:grs/models/service/service.dart';
import 'package:grs/repositories/doptor_repo.dart';
import 'package:grs/service/app_api_status.dart';
import 'package:grs/utils/api_url.dart';
import 'package:grs/utils/keys.dart';
import 'package:grs/view_models/company/citizen_charter_view_model.dart';

class DoptorViewModel with ChangeNotifier {
  Office? office;
  Origin? origin;
  bool loader = true;
  Ministry? ministry;
  OfficeByLayer? layerOffice;
  DivitionalOffice? divitionalOffice;
  List<Origin> originList = [];
  List<Ministry> ministryList = [];
  List<OfficeByLayer> layerOfficeList = [];
  List<DivitionalOffice> divitionalOfficeList = [];
  Service? selectedService;
  List<Service> serviceList = [];
  var search = TextEditingController();

  void initViewModel() {
    // disposeViewModel();
    // notifyListeners();
    if (sl<AppApiStatus>().ministries) _loader(false);
    if (sl<AppApiStatus>().ministries) return;
    getAllMinistries();
  }

  void disposeViewModel() {
    office = null;
    origin = null;
    ministry = null;
    layerOffice = null;
    divitionalOffice = null;
    originList.clear();
    layerOfficeList.clear();
    divitionalOfficeList.clear();
    selectedService = null;
    serviceList.clear();
  }

  void updateUi() => notifyListeners();

  void _loader(bool status) {
    loader = status;
    notifyListeners();
  }

  Future<List<Office>> allSearchableOfficeList() async {
    var searchedOffice = await sl<DoptorRepository>().searchableOfficeList(search.text);
    return searchedOffice;
  }

  Future<void> getAllMinistries() async {
    var response = await sl<DoptorRepository>().allMinistries();
    if (response.haveList) ministryList = response;
    _loader(false);
  }

  Future<void> getOriginsByLayer(int layer) async {
    _loader(true);
    var response = await sl<DoptorRepository>().originsByLayer(layer);
    if (response.haveList) originList = response;
    _loader(false);
  }

  Future<void> getDivisionalOfficeLayer() async {
    _loader(true);
    var response = await sl<DoptorRepository>().divisionalOfficesByLayer();
    if (response.haveList) divitionalOfficeList = response;
    _loader(false);
  }

  Future<void> getAllLayerOffices(int layer) async {
    _loader(true);
    var response = await sl<DoptorRepository>().officesByLayer(layer);
    if (response.haveList) layerOfficeList = response;
    _loader(false);
  }

  void selectSearchedOfficeList(bool needService, bool isCharter, Office data) {
    search.text = data.office_name;
    office = data;
    selectedService = null;
    serviceList.clear();
    notifyListeners();
    if (office != null) _clearMinistryData();
    if (office != null && isCharter) getCitizenCharters(office!.id!);
    if (office != null && needService) getAllServiceByOffice(office!.id!);
  }

  void _clearSearchedOffice() {
    office = null;
    notifyListeners();
  }

  void clearSearchField() {
    search.clear();
    office = null;
    notifyListeners();
  }

  void _clearMinistryData() {
    ministry = null;
    origin = null;
    divitionalOffice = null;
    layerOffice = null;
    selectedService = null;
    serviceList.clear();
    notifyListeners();
  }

  void selectMinistry(Ministry data) {
    ministry = data;
    origin = null;
    divitionalOffice = null;
    layerOffice = null;
    selectedService = null;
    serviceList.clear();
    notifyListeners();
    if (ministry != null) _clearSearchedOffice();
    if (ministry?.layerLevel == null) {
      sl<Toasts>().toastMessage(message: 'No ministry level found'.translate, isTop: false);
      return;
    }
    if (ministry!.layerLevel == 1 || ministry!.layerLevel == 2) getAllLayerOffices(ministry!.layerLevel!);
    if (ministry!.layerLevel == 3) getDivisionalOfficeLayer();
    if (ministry!.layerLevel! > 3) getOriginsByLayer(ministry!.layerLevel!);
  }

  void selectOrigin(Origin data) {
    origin = data;
    divitionalOffice = null;
    layerOffice = null;
    selectedService = null;
    serviceList.clear();
    notifyListeners();
    if (origin != null) _clearSearchedOffice();
    if (origin?.officeLayer?.layerLevel == null) {
      sl<Toasts>().toastMessage(message: 'No office layer found'.translate, isTop: false);
      return;
    }
    getAllLayerOffices(origin!.officeLayer!.layerLevel!);
  }

  void selectDivisionalOffice(DivitionalOffice data) {
    divitionalOffice = data;
    origin = null;
    layerOffice = null;
    selectedService = null;
    serviceList.clear();
    notifyListeners();
    if (divitionalOffice != null) _clearSearchedOffice();
    if (divitionalOffice?.layerLevel == null) {
      sl<Toasts>().toastMessage(message: 'No divitional office layer found'.translate, isTop: false);
      return;
    }
    getAllLayerOffices(divitionalOffice!.layerLevel!);
  }

  void selectOfficeLayer(bool needService, bool isCharter, OfficeByLayer data) {
    layerOffice = data;
    selectedService = null;
    serviceList.clear();
    notifyListeners();
    if (layerOffice != null) _clearSearchedOffice();
    if (layerOffice != null && isCharter) getCitizenCharters(layerOffice!.id!);
    if (layerOffice != null && needService) getAllServiceByOffice(layerOffice!.id!);
  }

  void getCitizenCharters(int officeId) {
    var context = navigatorKey.currentState?.context;
    if (context == null) return;
    Provider.of<CitizenCharterViewModel>(context, listen: false).getCitizenCharters(officeId);
  }

  Future<void> getAllServiceByOffice(int officeId) async {
    _loader(true);
    var responseList = await sl<DoptorRepository>().getServiceListByOffice(officeId);
    if (responseList.haveList) serviceList = responseList;
    _loader(false);
  }

  Future<void> getAllServiceByArea(int districtId) async {
    _loader(true);
    var endpoint = '${sl<ApiUrl>().servicesByDistrict}$districtId';
    var responseList = await sl<DoptorRepository>().getServiceListByArea(endpoint);
    if (responseList.haveList) serviceList = responseList;
    _loader(false);
  }

  void selectService(Service service) {
    selectedService = service;
    notifyListeners();
  }

  /*Future<void> getOfficeByServiceAndArea(String params) async {
    _loader(true);
    var endpoint = '${sl<ApiUrl>().officesByServiceArea}$params';
    var response = await sl<DoptorRepository>().getOfficeInfoByServiceArea(endpoint);
    if (response != null) office = response;
    _loader(false);
  }*/

  bool doptorDataValidation() {
    if (ministry == null) {
      if (office == null) return _returnMessage('Please select any office'.translate);
    } else {
      if (ministry == null) return _returnMessage('Please select any ministry'.translate);
      var layerLevel = ministry?.layerLevel;
      if (layerLevel != null && layerLevel > 2) {
        if (layerLevel == 3 && divitionalOffice == null) return _returnMessage('Please select any divisional office'.translate);
        if (layerLevel > 3 && origin == null) return _returnMessage('Please select any origin'.translate);
      }
      if (layerOffice == null) return _returnMessage('Please select any office'.translate);
    }
    return true;
  }

  bool _returnMessage(String message) {
    sl<Toasts>().warningToast(message: message.translate, isTop: true);
    return false;
  }
}
