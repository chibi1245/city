
import 'package:grs/di.dart';
import 'package:grs/implementations/http_library.dart';

import 'package:grs/service/storage_service.dart';

class AuthService {
  bool get authStatus => sl<StorageService>().getAuthStatus;

  // void clearMemory() => sl<StorageService>().clearMemory();

  void initStorageInLoginState() {
    var token = sl<StorageService>().getToken;
    HttpLibrary.setToken(token: token);
  }

  void storeRememberMeData(Map<String, dynamic> rememberData) {
    sl<StorageService>().setUsername(rememberData['username']!);
    sl<StorageService>().setPassword(rememberData['password']!);
    sl<StorageService>().setRememberMe(true);
  }

  void storeOfficerProfileData(OfficerProfileApi profileApi, OrganogramInfo? organogram) {
    sl<StorageService>().setAuthStatus(true);
    sl<StorageService>().setModule(false);
    sl<StorageService>().setCitizenStatus('officer');
    HttpLibrary.setToken(token: profileApi.token!);
    sl<StorageService>().setToken(profileApi.token!);
    sl<StorageService>().setUserId(profileApi.profileInfo!.profile!.id!);
    sl<StorageService>().setOfficerProfile(profileApi.profileInfo!.profile!);
    sl<StorageService>().setUserType(profileApi.userType ?? '');
    sl<StorageService>().setProfileInfo(profileApi.profileInfo!);
    if (organogram != null) sl<StorageService>().setOrganogram(organogram);
    sl<StorageService>().setEmployeeRecordId(profileApi.profileInfo!.profile!.employeeRecordId!);
  }

  void storeCitizenProfileData(CitizenProfileApi profileApi) {
    sl<StorageService>().setAuthStatus(true);
    sl<StorageService>().setModule(true);
    sl<StorageService>().setCitizenStatus('citizen');
    HttpLibrary.setToken(token: profileApi.token!);
    sl<StorageService>().setToken(profileApi.token!);
    sl<StorageService>().setUserId(profileApi.profile!.id!);
    sl<StorageService>().setCitizenProfile(profileApi.profile!);
  }

  void removeStorageData() {
    sl<Storage>().removeData(key: AUTH_STATUS);
    sl<Storage>().removeData(key: BEARER_TOKEN);
    sl<Storage>().removeData(key: OFFICER_PROFILE);
    sl<Storage>().removeData(key: PROFILE_INFO);
    sl<Storage>().removeData(key: USER_ID);
    sl<Storage>().removeData(key: EMPLOYEE_RECORD_ID);
    sl<Storage>().removeData(key: ORGANOGRAM);
    sl<Storage>().removeData(key: CITIZEN_PROFILE);
    sl<Storage>().removeData(key: MODULE);
  }
}
