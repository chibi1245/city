import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/helpers/graph_helper.dart';
import 'package:grs/models/dashboard/dashboard.dart';
import 'package:grs/models/dashboard/graph_model.dart';
import 'package:grs/models/dummy/loader.dart';
import 'package:grs/repositories/dashboard_repo.dart';

class DashboardViewModel with ChangeNotifier {
  int totalTouchIndex = -1;
  int appliedTouchIndex = -1;
  String selectedGraphType = 'all';
  Dashboard dashboard = Dashboard();
  GraphModel graphModel = dummyGraphModel;
  Loader loader = Loader(initial: true, common: true);

  void initViewModel() => getDashboardData();

  void disposeViewModel() {
    dashboard = Dashboard();
    totalTouchIndex = -1;
    appliedTouchIndex = -1;
    selectedGraphType = 'all';
    graphModel = dummyGraphModel;
    loader = Loader(initial: true, common: true);
  }

  void updateUi() => notifyListeners();

  Future<void> getDashboardData() async {
    dashboard = await sl<DashboardRepository>().dashboardData();
    if (dashboard.graphGrievanceList.haveList) updateGraphModel();
    loader = Loader(initial: false, common: false);
    notifyListeners();
  }

  Future<void> refreshDashboardData() async {
    dashboard = await sl<DashboardRepository>().dashboardData();
    if (dashboard.graphGrievanceList.haveList) updateGraphModel();
    notifyListeners();
  }

  void totalTouchCallback(event, pieTouchResponse) {
    var invalidTouch = !event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null;
    totalTouchIndex = invalidTouch ? -1 : pieTouchResponse.touchedSection!.touchedSectionIndex;
    notifyListeners();
  }

  void appliedTouchCallback(FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
    var invalidTouch = !event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null;
    appliedTouchIndex = invalidTouch ? -1 : pieTouchResponse.touchedSection!.touchedSectionIndex;
    notifyListeners();
  }

  Future<void> selectGraphType(String type) async {
    loader.common = true;
    selectedGraphType = type;
    notifyListeners();
    updateGraphModel();
    await Future.delayed(const Duration(milliseconds: 250));
    loader.common = false;
    notifyListeners();
  }

  void updateGraphModel() {
    graphModel = dummyGraphModel;
    Map<String, List<FlSpot>> graphSpots = sl<GraphHelper>().getSpots(dashboard.graphGrievanceList!);
    graphModel.total = graphSpots['total']!;
    graphModel.resolved = graphSpots['resolved']!;
    graphModel.time_passed = graphSpots['time_passed']!;
    Map<String, double> maxValues = sl<GraphHelper>().getMaxValues(graphSpots);
    graphModel.maxX = maxValues['max_x']!;
    graphModel.maxY = maxValues['max_y']!;
    notifyListeners();
  }
}
