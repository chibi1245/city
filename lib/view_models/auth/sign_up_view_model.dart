import 'package:flutter/material.dart';

import 'package:grs/constants/date_formats.dart';
import 'package:grs/di.dart';
import 'package:grs/extensions/datetime_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/libraries/formatters.dart';
import 'package:grs/models/country/country.dart';
import 'package:grs/models/dummy/data_type.dart';
import 'package:grs/models/occupation/occupation.dart';
import 'package:grs/models/qualification/qualification.dart';
import 'package:grs/repositories/auth_repo.dart';
import 'package:grs/repositories/public_repo.dart';

class SignUpViewModel with ChangeNotifier {
  bool loader = true;
  bool isAppUser = false;
  bool userLoader = false;
  bool obscureText = true;
  bool keepLoggedIn = false;
  DateTime? dateOfBirth;
  DataType? gender;
  Occupation? occupation;
  Qualification? qualification;
  DataType? identityType;
  Country? country;
  Country? nationality;

  List<Occupation> occupations = [];
  List<Country> nationalities = [];
  List<Qualification> qualifications = [];

  var mobile = TextEditingController();
  var name = TextEditingController();
  var nationalId = TextEditingController();
  var email = TextEditingController();
  var street = TextEditingController();
  var house = TextEditingController();

  void initViewModel() {
    allOccupations();
    allNationalities();
    allQualifications();
  }

  void disposeViewModel() {
    isAppUser = false;
    dateOfBirth = null;
    gender = null;
    occupation = null;
    qualification = null;
    identityType = null;
    country = null;
    nationality = null;
    loader = true;
    userLoader = false;
    obscureText = true;
    keepLoggedIn = false;
    occupations.clear();
    nationalities.clear();
    qualifications.clear();
    mobile.clear();
    name.clear();
    nationalId.clear();
    email.clear();
    street.clear();
    house.clear();
  }

  Future<void> allOccupations() async {
    occupations = await sl<PublicRepository>().allOccupations();
    loader = false;
    notifyListeners();
  }

  Future<void> allNationalities() async {
    nationalities = await sl<PublicRepository>().allNationalities();
    loader = false;
    notifyListeners();
  }

  Future<void> allQualifications() async {
    qualifications = await sl<PublicRepository>().allQualifications();
    loader = false;
    notifyListeners();
  }

  Future<void> checkUser() async {
    if (mobile.text.length < 10) return;
    userLoader = true;
    notifyListeners();
    isAppUser = await sl<AuthRepository>().checkUser(mobile.text);
    userLoader = false;
    notifyListeners();
  }

  Future<void> getBirthDate(BuildContext context) async {
    var picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1950),
      lastDate: currentDate,
      currentDate: currentDate,
    );
    if (picked != null) {
      dateOfBirth = picked;
      notifyListeners();
    }
  }

  void selectCountry(Country data) {
    country = data;
    nationality = country;
    notifyListeners();
  }

  Future<void> signUpOnTap() async {
    loader = true;
    notifyListeners();
    var body = _signupBody();
    var response = await sl<AuthRepository>().signUp(body: body);
    if (response) backToPrevious();
    loader = false;
    notifyListeners();
  }

  Map<String, dynamic> _signupBody() {
    Map<String, dynamic> body = {
      'name': name.text,
      'identification_value': nationalId.text,
      'identification_type': identityType!.value,
      'mobile_number': mobile.text,
      'email': email.text,
      'birth_date': sl<Formatters>().formatDate(DATE_FORMAT_1, '$dateOfBirth'),
      'occupation': occupation!.id,
      'educational_qualification': qualification!.id,
      'gender': gender!.value,
      'nationality_id': nationality!.id!,
      'permanent_address_street': street.text,
      'permanent_address_house': house.text,
      'permanent_address_country_id': country!.id,
    };
    return body;
  }
}
