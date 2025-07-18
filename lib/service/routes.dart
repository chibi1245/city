import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';

class Routes {
  void backToPrevious() => Navigator.of(navigatorKey.currentState!.context).pop();
  // on-boarding
  Widget grsOnboardScreen() => GrsOnboardScreen();

  // Company
  Widget questionsScreen() => QuestionsScreen();
  Widget improvementScreen() => ImprovementScreen();
  Widget citizenCharterScreen() => CitizenCharterScreen();

  // auth
  Widget signInScreen() => SignInScreen();
  Widget signUpScreen() => SignUpScreen();
  Widget forgotPinScreen() => ForgotPinScreen();
  Widget otpScreen({required String mobile}) => OTPScreen(mobile: mobile);

  // Complain
  Widget trackingScreen() => TrackingScreen();
  Widget addComplainScreen() => AddComplainScreen();
  Widget citizenComplainsScreen() => CitizenComplainsScreen();
  Widget officerComplainsScreen() => OfficerComplainsScreen();
  Widget myComplainsScreen() => MyComplainsScreen();
  Widget appealComplainsScreen({required int index}) => AppealComplainsScreen(index: index);

  // Complain Details
  Widget citizenComplainDetailsScreen(Complain complain) => CitizenComplainDetailsScreen(complain: complain);
  Widget officerComplainDetailsScreen(String menu, ComplainListPref pref, Complain complain) =>
      OfficerComplainDetailsScreen(menu: menu, pref: pref, complain: complain);
  Widget appealComplainDetailsScreen(String menu, ComplainListPref pref, Complain complain) =>
      AppealComplainDetailsScreen(menu: menu, pref: pref, complain: complain);

  // Blacklist
  Widget blacklistsScreen() => BlacklistsScreen();
  Widget blacklistRequestScreen() => BlacklistRequestScreen();

  // Profile
  Widget profileScreen() => ProfileScreen();

  // Dashboard
  Widget dashboardScreen() => DashboardScreen();

  // Citizen Actions
  Widget sendAppealScreen(Complain complain) => SendAppealScreen(complain: complain);
  Widget hearingDateScreen(Complain complain) => HearingDateScreen(complain: complain);
  Widget evidenceMaterialScreen(Complain complain) => EvidenceMaterialScreen(complain: complain);

  // Officer Actions
  Widget sendForOpinionScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      SendForOpinionScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget giveOpinionScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      GiveOpinionScreen(complain: complain, typePref: typePref, viewPref: viewPref);

  Widget toAnotherOfficeScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      ToAnotherOfficeScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget subordinateOfficeScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      SubordinateOfficeScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget subordinateOfficeGroScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      SubordinateOfficeGroScreen(complain: complain, typePref: typePref, viewPref: viewPref);

  Widget sendToAppealOfficerScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      SendToAppealOfficerScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget provideServiceScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      ProvideServiceScreen(complain: complain, typePref: typePref, viewPref: viewPref);

  Widget sendPermissionScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      SendForPermissionScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget givePermissionScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      GivePermissionScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget requestDocumentScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      RequestDocumentScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget startInvestigationScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      StartInvestigationScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget investigationReportScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      InvestigationReportScreen(complain: complain, typePref: typePref, viewPref: viewPref);

  Widget hearingNoticeScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      HearingNoticeScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget takeHearingScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      TakeHearingScreen(complain: complain, typePref: typePref, viewPref: viewPref);

  Widget moreEvidenceScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      MoreEvidenceScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget approveDisapproveScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      ApproveDisapproveScreen(complain: complain, typePref: typePref, viewPref: viewPref);

  Widget rejectScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      RejectScreen(complain: complain, typePref: typePref, viewPref: viewPref);
  Widget closeComplainScreen(Complain complain, ActionTypePref typePref, ActionViewPref viewPref) =>
      CloseComplainScreen(complain: complain, typePref: typePref, viewPref: viewPref);
}
