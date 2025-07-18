import 'package:flutter/material.dart';

import 'package:grs/constants/date_formats.dart';
import 'package:grs/di.dart';
import 'package:grs/enum/enums.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/extensions/route_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/profile_helper.dart';
import 'package:grs/libraries/formatters.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/dummy/data_type.dart';
import 'package:grs/repositories/officer_action_repo.dart';
import 'package:grs/service/storage_service.dart';

class HearingNoticeViewModel with ChangeNotifier {
  DataType? witness;
  bool loader = false;
  DateTime? hearingDate;
  TimeOfDay? hearingTime;
  List<DataType> witnessList = [];
  var note = TextEditingController();

  void initViewModel(Complain complain) {
    witnessList.add(DataType(labelBn: 'অভিযোগকারী', labelEn: 'Complainant', value: '${complain.complainantId}'));
    notifyListeners();
  }

  void disposeViewModel() {
    loader = false;
    note.clear();
    witnessList.clear();
    witness = null;
    hearingDate = null;
    hearingTime = null;
  }

  void updateUi() => notifyListeners();

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  void sendOnTap(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) {
    minimizeKeyboard();
    // var context = navigatorKey.currentState?.context;
    // if (context == null) return;
    if (hearingDate == null) return sl<Toasts>().warningToast(message: 'Please select the date of hearing'.translate, isTop: true);
    if (hearingTime == null) return sl<Toasts>().warningToast(message: 'Please select the time of hearing'.translate, isTop: true);
    if (witness == null) return sl<Toasts>().warningToast(message: 'Please select a witness'.translate, isTop: true);
    var message1 = 'Please write a note for hearing notice'.translate;
    if (note.text.isEmpty) return sl<Toasts>().warningToast(message: message1, isTop: true);
    _hearingNoticeApi(complain, typePref, viewPref);
  }

  Future<void> _hearingNoticeApi(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) async {
    _loader(true);
    var body = _hearingNoticeBody(complain);
    var response = await sl<OfficerActionRepository>().hearingNotice(body: body);
    if (response) backToPrevious();
    if (response && viewPref == ActionViewPref.details_view) backToPrevious();
    _loader(false);
  }

  Map<String, String> _hearingNoticeBody(Complain complain) {
    var datetime = sl<Formatters>().timeOfDayToDateTime(hearingTime!);

    Map<String, String> bodyInformation = {
      'complaint_id': complain.id.toString(), // Ensuring `id` is converted to String
      'office_id': sl<ProfileHelper>().officeInfo.officeId.toString(),
      'username': sl<ProfileHelper>().officerProfile?.username ?? '',
      'hearing_date': sl<Formatters>().formatDate(DATE_FORMAT_1, '$hearingDate'),
      'hearing_time': sl<Formatters>().formatDate(DATE_FORMAT_14, '$datetime'),
      'note': note.text,
      'to_employee_record_id': sl<ProfileHelper>().officerProfile?.employeeRecordId.toString() ?? '',
      'language': sl<StorageService>().getLanguage ?? '',
    };

    return bodyInformation;
  }

  // Map<String, dynamic> _hearingNoticeBody(Complain complain) {
  //   var datetime = sl<Formatters>().timeOfDayToDateTime(hearingTime!);
  //   Map<String, dynamic> bodyInformation = {
  //     'complaint_id': complain.id,
  //     'office_id': sl<ProfileHelper>().officeInfo.officeId,
  //     'username': sl<ProfileHelper>().officerProfile?.username,
  //     'hearing_date': sl<Formatters>().formatDate(DATE_FORMAT_1, '$hearingDate'),
  //     'hearing_time': sl<Formatters>().formatDate(DATE_FORMAT_14, '$datetime'),
  //     'note': note.text,
  //     'to_employee_record_id': sl<ProfileHelper>().officerProfile?.employeeRecordId,
  //     'language': sl<StorageService>().getLanguage,
  //   };
  //   return bodyInformation;
  // }
}
