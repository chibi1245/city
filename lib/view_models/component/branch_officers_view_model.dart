import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/models/branch/branch_office.dart';
import 'package:grs/models/branch/officer.dart';
import 'package:grs/repositories/action_data_repo.dart';
import 'package:grs/service/app_api_status.dart';

class BranchOfficersViewModel with ChangeNotifier {
  bool loader = true;
  Officer? selectedOfficer;
  List<Officer> selectedOfficers = [];
  List<BranchOffice> officeBranches = [];

  void initViewModel() {
    if (sl<AppApiStatus>().branchOfficers) _loader(false);
    if (sl<AppApiStatus>().branchOfficers) return;
    getBranchOfficeList();
  }

  void disposeViewModel() {
    selectedOfficer = null;
    selectedOfficers.clear();
    refreshSelections();
  }

  void refreshSelections() {
    if (!officeBranches.haveList) return;
    officeBranches.forEach((item) => item.officers.haveList ? item.officers!.forEach((officer) => officer.selected = false) : null);
  }

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  void expansionChanged(int index) {
    officeBranches[index].isExpanded = !(officeBranches[index].isExpanded ?? false);
    notifyListeners();
  }

  Future<void> getBranchOfficeList() async {
    officeBranches.clear();
    var responseList = await sl<ActionDataRepository>().getBranches();
    if (responseList.haveList) officeBranches.addAll(responseList);
    _loader(false);
  }

  void selectCommitteeHead(int index) {
    selectedOfficers.asMap().entries.forEach((item) {
      item.value.isRecipient = item.key != index;
      item.value.isCommitteeHead = item.key == index;
    });
    notifyListeners();
  }

  void selectAsRecipient(int index) {
    var officer = selectedOfficers[index];
    officer.isRecipient = !(officer.isRecipient ?? false);
    if (officer.isCommitteeHead != null && officer.isCommitteeHead!) officer.isCommitteeHead = false;
    var headCount = 0;
    selectedOfficers.forEach((item) => item.isCommitteeHead != null && item.isCommitteeHead! ? headCount = headCount + 1 : null);
    if (headCount < 1 && selectedOfficers.haveList) {
      selectedOfficers.first.isRecipient = false;
      selectedOfficers.first.isCommitteeHead = true;
    }
    notifyListeners();
  }

  void officerSelectionFromList(bool isMultiSelect, int pIndex, int cIndex) {
    var officer = officeBranches[pIndex].officers![cIndex];
    if (!isMultiSelect) {
      selectedOfficer = officer;
      notifyListeners();
      return;
    }
    if (officer.selected != null && officer.selected!) {
      officer.selected = false;
      var index = !selectedOfficers.haveList ? -1 : selectedOfficers.indexWhere((item) => item.id == officer.id);
      if (index >= 0) selectedOfficers.removeAt(index);
    } else {
      officer.selected = true;
      selectedOfficers.add(officer);
      if (selectedOfficers.length == 1) {
        selectedOfficers.last.isRecipient = false;
        selectedOfficers.last.isCommitteeHead = true;
      } else {
        selectedOfficers.last.isCommitteeHead = false;
        selectedOfficers.last.isRecipient = true;
      }
    }
    notifyListeners();
  }

  void removeSelectedOfficer(bool isMultiSelect, int index) {
    if (!isMultiSelect) {
      selectedOfficer = null;
      notifyListeners();
      return;
    }
    var officer = selectedOfficers[index];
    var branchIndex = officeBranches.indexWhere((item) => item.id == officer.officeUnitId);
    if (branchIndex < 0) return;
    var branchOffice = officeBranches[branchIndex];
    if (!branchOffice.officers.haveList) return;
    var officerIndex = branchOffice.officers!.indexWhere((item) => item.id == officer.id);
    if (officerIndex < 0) return;
    branchOffice.officers![officerIndex].selected = false;
    selectedOfficers.removeAt(index);
    var headCount = 0;
    selectedOfficers.forEach((item) => item.isCommitteeHead != null && item.isCommitteeHead! ? headCount = headCount + 1 : null);
    if (headCount < 1 && selectedOfficers.haveList) {
      selectedOfficers.first.isRecipient = false;
      selectedOfficers.first.isCommitteeHead = true;
    }
    notifyListeners();
  }
}
