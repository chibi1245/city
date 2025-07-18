import 'dart:convert';

import 'package:grs/constants/storage_keys.dart';
import 'package:grs/di.dart';
import 'package:grs/libraries/storage.dart';
import 'package:grs/models/citizen_profile/citizen_profile.dart';
import 'package:grs/models/officer_profile/officer_profile.dart';
import 'package:grs/models/officer_profile/officer_profile_info.dart';
import 'package:grs/models/officer_profile/organogram_info.dart';

class StorageService {
  /// Get Local Storage Data
  String get getModule => sl<Storage>().readData(key: MODULE) ?? '';
  String get getLanguage => sl<Storage>().readData(key: LANGUAGE_CODE) ?? 'bn';

  String get getUsername => sl<Storage>().readData(key: USERNAME) ?? 'null';
  String get getPassword => sl<Storage>().readData(key: PASSWORD) ?? 'null';
  bool get getRememberMe => sl<Storage>().readData(key: REMEMBER) ?? false;
  String? get getCredentialType => sl<Storage>().readData(key: CREDENTIAL_TYPE);

  String get getToken => sl<Storage>().readData(key: BEARER_TOKEN);
  bool get getAuthStatus => sl<Storage>().readData(key: AUTH_STATUS) ?? false;
  int get getEmployeeRecordId => sl<Storage>().readData(key: EMPLOYEE_RECORD_ID);

  int get getUserId => sl<Storage>().readData(key: USER_ID);
  String get getUserType => sl<Storage>().readData(key: USER_TYPE) ?? '';

  // Officer
  OfficerProfile get getOfficerProfile {
    var haveData = sl<Storage>().hasLocalData(key: OFFICER_PROFILE);
    if (!haveData) return OfficerProfile();
    return OfficerProfile.fromJson(json.decode(sl<Storage>().readData(key: OFFICER_PROFILE)));
  }

  OfficerProfileInfo get getProfileInfo {
    var haveData = sl<Storage>().hasLocalData(key: PROFILE_INFO);
    if (!haveData) return OfficerProfileInfo();
    return OfficerProfileInfo.fromJson(json.decode(sl<Storage>().readData(key: PROFILE_INFO)));
  }

  OrganogramInfo get getOrganogram {
    var haveData = sl<Storage>().hasLocalData(key: ORGANOGRAM);
    if (!haveData) return OrganogramInfo();
    return OrganogramInfo.fromJson(json.decode(sl<Storage>().readData(key: ORGANOGRAM)));
  }

  // Citizen
  CitizenProfile get getCitizenProfile {
    var haveData = sl<Storage>().hasLocalData(key: CITIZEN_PROFILE);
    if (!haveData) return CitizenProfile();
    return CitizenProfile.fromJson(json.decode(sl<Storage>().readData(key: CITIZEN_PROFILE)));
  }

  // void clearMemory() => sl<Storage>().removeAllData();

  /// Set Local Storage Data
  void setModule(bool isCitizen) => sl<Storage>().storeData(key: MODULE, value: isCitizen ? 'citizen' : 'officer');
  void setLanguage(String code) => sl<Storage>().storeData(key: LANGUAGE_CODE, value: code);

  void setUsername(String username) => sl<Storage>().storeData(key: USERNAME, value: username);
  void setPassword(String password) => sl<Storage>().storeData(key: PASSWORD, value: password);
  void setRememberMe(bool value) => sl<Storage>().storeData(key: REMEMBER, value: value);
  void setCitizenStatus(String value) => sl<Storage>().storeData(key: CREDENTIAL_TYPE, value: value);

  void setAuthStatus(bool value) => sl<Storage>().storeData(key: AUTH_STATUS, value: value);
  void setToken(String token) => sl<Storage>().storeData(key: BEARER_TOKEN, value: token);
  void setUserId(int id) => sl<Storage>().storeData(key: USER_ID, value: id);
  void setEmployeeRecordId(int id) => sl<Storage>().storeData(key: EMPLOYEE_RECORD_ID, value: id);

  // Officer
  void setOfficerProfile(OfficerProfile data) => sl<Storage>().storeData(key: OFFICER_PROFILE, value: json.encode(data));
  void setUserType(String data) => sl<Storage>().storeData(key: USER_TYPE, value: data);
  void setProfileInfo(OfficerProfileInfo data) => sl<Storage>().storeData(key: PROFILE_INFO, value: json.encode(data));
  void setOrganogram(OrganogramInfo data) => sl<Storage>().storeData(key: ORGANOGRAM, value: json.encode(data));

  // Citizen
  void setCitizenProfile(CitizenProfile data) => sl<Storage>().storeData(key: CITIZEN_PROFILE, value: json.encode(data));
}
