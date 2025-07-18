import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/models/branch/branch_office.dart';
import 'package:grs/models/branch/officer.dart';
import 'package:grs/models/complain/complain.dart';
import 'package:grs/models/subordinate_office/sub_ordinate_office.dart';
import 'package:grs/repositories/action_data_repo.dart';
import 'package:grs/repositories/doptor_repo.dart';
import 'package:grs/service/app_api_status.dart';

class SubordinateOfficersViewModel with ChangeNotifier {
  bool loader = true;
  Officer? selectedOfficer;
  List<Officer> selectedOfficers = [];
  List<SubordinateOffice> subordinateOffices = [];

  void initViewModel({Complain? complain}) {
    if (complain == null) return _loader(false);
    if (sl<AppApiStatus>().subordinateOfficers) {
      getGroOfficer(complain);
    } else {
      getSubordinateOfficers(complain);
    }
  }

  void disposeViewModel() {
    loader = true;
    selectedOfficer = null;
    selectedOfficers.clear();
    _refreshSelections();
  }

  void _refreshSelections() {
    if (!subordinateOffices.haveList) return;
    subordinateOffices.forEach((item) => item.branchOffices.haveList ? item.branchOffices!.forEach(_refreshOfficers) : null);
  }

  void _refreshOfficers(BranchOffice branchOffice) {
    if (!branchOffice.officers.haveList) return;
    branchOffice.officers!.forEach((item) => item.selected = false);
  }

  void _loader(bool data) {
    loader = data;
    notifyListeners();
  }

  void subOrdinateExpansionChanged(int Index) {
    subordinateOffices[Index].isExpanded = !(subordinateOffices[Index].isExpanded ?? false);
    notifyListeners();
  }

  void branchExpansionChanged(int pIndex, int cIndex) {
    var branchOffice = subordinateOffices[pIndex].branchOffices![cIndex];
    branchOffice.isExpanded = !(branchOffice.isExpanded ?? false);
    notifyListeners();
  }

  Future<void> getSubordinateOfficers(Complain? complain) async {
    subordinateOffices.clear();
    var responseList = await sl<DoptorRepository>().getSubOrdinateOffice(complain?.complainantId!);
    if (responseList.haveList) subordinateOffices.addAll(responseList);
    if (subordinateOffices.length == 1) subordinateOffices[0].isExpanded = true;
    if (complain != null) await getGroOfficer(complain);
    _loader(false);
  }

  Future<void> getGroOfficer(Complain complain) async {
    var officer = await sl<ActionDataRepository>().getGroOfficer(complain.id!);
    _loader(false);
    if (officer == null) return;
    var subordinateIndex = subordinateOffices.indexWhere((item) => item.id == officer.office);
    if (subordinateIndex < 0) return;
    var branchOffices = subordinateOffices[subordinateIndex].branchOffices;
    var branchIndex = branchOffices!.indexWhere((item) => item.id == officer.unit);
    if (branchIndex < 0) return;
    var branchOffice = branchOffices[branchIndex];
    if (!branchOffice.officers.haveList) return;
    var officerIndex = branchOffice.officers!.indexWhere((item) => item.id == officer.organogram);
    if (officerIndex < 0) return;
    branchOffice.officers![officerIndex].selected = true;
    if (officer.officeHead != null) {
      branchOffice.officers![officerIndex].isCommitteeHead = true;
      branchOffice.officers![officerIndex].isRecipient = false;
    }
    selectedOfficers.add(branchOffice.officers![officerIndex]);
    notifyListeners();
  }

  void selectCommitteeHead(int index) {
    selectedOfficers.forEach((item) => item.isCommitteeHead = false);
    selectedOfficers[index].isRecipient = false;
    selectedOfficers[index].isCommitteeHead = true;
    notifyListeners();
  }

  void selectAsRecipient(int index) {
    var officer = selectedOfficers[index];
    officer.isRecipient = !(officer.isRecipient ?? false);
    if (officer.isCommitteeHead != null && officer.isCommitteeHead!) officer.isCommitteeHead = false;
    notifyListeners();
  }

  void officerSelectionFromList(bool isMultiSelect, int sIndex, int bIndex, int cIndex) {
    var officer = subordinateOffices[sIndex].branchOffices![bIndex].officers![cIndex];
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
      selectedOfficers.length == 1 ? officer.isCommitteeHead = true : officer.isRecipient = true;
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
    var subordinateIndex = subordinateOffices.indexWhere((item) => item.id == officer.officeId);
    if (subordinateIndex < 0) return;
    var branchOffices = subordinateOffices[subordinateIndex].branchOffices;
    var branchIndex = branchOffices!.indexWhere((item) => item.id == officer.officeUnitId);
    if (branchIndex < 0) return;
    var branchOffice = branchOffices[branchIndex];
    if (!branchOffice.officers.haveList) return;
    var officerIndex = branchOffice.officers!.indexWhere((item) => item.id == officer.id);
    if (officerIndex < 0) return;
    branchOffice.officers![officerIndex].selected = false;
    selectedOfficers.removeAt(index);
    notifyListeners();
  }
}
