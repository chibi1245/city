import 'package:grs/di.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/utils/reg_exps.dart';

class Validators {
  String? userId({required String data}) {
    if (data.length < 1) return 'Please enter your user id'.translate;
    return null;
  }

  String? mobileNumber({required String mobile}) {
    if (mobile.length < 1) return 'Please enter your mobile number'.translate;
    if (mobile.length != 11) return 'Mobile number must be 11 digit'.translate;
    return null;
  }

  String? pinNumber({required String pin}) {
    if (pin.length < 1) return 'Please enter your pin number'.translate;
    if (pin.length < 4) return 'Pin number must be greater than 4 digit'.translate;
    return null;
  }

  String? trackingNumber({required String trackingNo}) {
    if (trackingNo.length < 1) return 'Please enter your tracking number'.translate;
    return null;
  }

  String? fullName({required String name}) {
    if (name.length < 1) return 'Please enter your full name'.translate;
    return null;
  }

  String? emailAddress({required String email}) {
    if (email.length < 1) return 'Please enter your email address'.translate;
    if (!sl<RegExps>().email.hasMatch(email)) return 'Please enter a valid email address'.translate;
    return null;
  }

  String? complainSubject({required String subject}) {
    if (subject.length < 1) return 'Please write your complain subject'.translate;
    return null;
  }

  String? complainDescription({required String subject}) {
    if (subject.length < 1) return 'Please write your complain description'.translate;
    return null;
  }

  String? yourAddress({required String address}) {
    if (address.length < 1) return 'Please write your address here'.translate;
    return null;
  }
}
