import 'package:flutter/material.dart';

import 'package:grs/di.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/repositories/citizen_action_repo.dart';
import 'package:grs/repositories/complain_repo.dart';

class TrackingViewModel with ChangeNotifier {
  double rating = 0;
  bool loader = false;
  Complain? complain;
  var comment = TextEditingController();
  var mobileNo = TextEditingController();
  var trackingNo = TextEditingController();

  void initViewModel() {}

  void disposeViewModel() {
    mobileNo.clear();
    trackingNo.clear();
    loader = false;
    complain = null;
  }

  void updateUi() => notifyListeners();

  Future<void> trackComplainOnTap() async {
    rating = 0;
    complain = null;
    loader = true;
    comment.clear();
    notifyListeners();
    complain = await sl<ComplainRepository>().trackComplain(trackingNo.text);
    loader = false;
    notifyListeners();
  }

  Future<void> submitRating() async {
    loader = true;
    notifyListeners();
    var body = {'complaint_id': complain!.id, 'rating': rating, 'feedback_comments': comment.text};
    var apiResponse = await sl<CitizenActionRepository>().sendComplainRating(body);
    if (apiResponse) {
      complain = null;
      mobileNo.clear();
      trackingNo.clear();
    }
    loader = false;
    notifyListeners();
  }
}
