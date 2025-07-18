import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/list_ext.dart';
import 'package:grs/extensions/string_ext.dart';
import 'package:grs/helpers/file_helper.dart';
import 'package:grs/libraries/file_pickers.dart';
import 'package:grs/libraries/toasts.dart';
import 'package:grs/models/dummy/proof_file.dart';

class ProofFilesViewModel with ChangeNotifier {
  bool loader = false;
  List<ProofFile> proofFiles = [];

  void initViewModel() => loader = false;

  void disposeViewModel() {
    loader = false;
    proofFiles.clear();
  }

  Future<void> getProofFiles() async {
    List<File> files = await sl<FilePickers>().pickMultipleFile();
    loader = true;
    notifyListeners();
    var modifiedFiles = await sl<FileHelper>().renderFilesInModel(files);
    if (modifiedFiles.haveList) proofFiles.addAll(modifiedFiles);
    loader = false;
    notifyListeners();
  }

  void removeProofFile(int index) {
    proofFiles.removeAt(index);
    notifyListeners();
  }

  bool validateProofFiles() {
    if (proofFiles.length < 1) return true;
    int totalByteSize = proofFiles.map((file) => file.size).reduce((value, element) => value + element);
    double fileSizeInMB = totalByteSize / (1024 * 1024);
    if (fileSizeInMB > 10) sl<Toasts>().warningToast(message: 'File size will never exceed than 10 MB'.translate, isTop: true);
    if (fileSizeInMB > 10) return false;
    int validCount = 0;
    int largeCount = 0;
    int nameCount = 0;
    proofFiles.forEach((item) {
      if (!item.isValid) validCount = validCount + 1;
      if (item.isLarge) largeCount = largeCount + 1;
      if (item.name.text.trim().length < 1) nameCount = nameCount + 1;
    });

    if (validCount > 0) {
      sl<Toasts>().warningToast(message: 'File is not valid'.translate, isTop: true);
      return false;
    }
    if (largeCount > 0) {
      sl<Toasts>().warningToast(message: 'File size is too large'.translate, isTop: true);
      return false;
    }
    if (nameCount > 0) {
      sl<Toasts>().warningToast(message: 'Please write the file name'.translate, isTop: true);
      return false;
    }
    return true;
  }
}
