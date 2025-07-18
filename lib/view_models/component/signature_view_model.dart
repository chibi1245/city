import 'dart:core';
import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:grs/di.dart';
import 'package:grs/extensions/flutter_ext.dart';
import 'package:grs/libraries/file_compresser.dart';
import 'package:grs/libraries/image_croppers.dart';
import 'package:grs/libraries/image_pickers.dart';
import 'package:grs/models/dummy/proof_file.dart';

class SignatureViewModel with ChangeNotifier {
  ProofFile? signature;
  var note = TextEditingController();

  void initViewModel() {}

  void disposeViewModel() {
    signature = null;
    note.clear();
  }

  Future<void> getImageFromGallery() async {
    var imageFile = await sl<ImagePickers>().imageFromGallery();
    if (imageFile == null) return;
    var updatedFile = await _modifyPickedImage(imageFile);
    if (updatedFile == null) return;
    // signature = ProofFile(file: updatedFile, isLarge: false, unit8List: await sl<ImageService>().fileToUnit8List(updatedFile));
    notifyListeners();
  }

  Future<io.File?> _modifyPickedImage(XFile image) async {
    io.File pickedFile = io.File(image.path);
    var compressedImage = await sl<FileCompressor>().compressImageFile(io.File(pickedFile.path));
    if (compressedImage == null) return null;
    var croppedImage = await sl<ImageCroppers>().cropImage(image: pickedFile);
    if (croppedImage == null) return null;
    return io.File(croppedImage.path);
  }

  void clearSignature() {
    signature = null;
    notifyListeners();
    minimizeKeyboard();
  }
}
