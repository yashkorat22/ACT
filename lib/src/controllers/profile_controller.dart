import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:image_picker/image_picker.dart';

import '../repository/user_repository.dart' as user_repo;
import '../helpers/helper.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

final genders = <String>['Unknown', 'Female', 'Male', 'Other'];
final isoCodes = [
  {
    'locale': 'GB',
    'code': '+44',
  },
  {
    'locale': 'US',
    'code': '+1',
  },
  {
    'locale': 'RU',
    'code': '+7',
  },
  {
    'locale': 'CH',
    'code': '+41',
  },
  {
    'locale': 'DE',
    'code': '+49',
  },
  {
    'locale': 'LI',
    'code': '+423',
  },
  {
    'locale': 'FR',
    'code': '+33',
  },
  {
    'locale': 'IT',
    'code': '+39',
  },
];

// = Helper for missing context when use for AppLocalizations.of(context)!...

class ProfileController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  GlobalKey<FormState>? profileFormKey;
  OverlayEntry? loader;
  Uint8List? imageFile;
  int? gender = 0;
  String? phone;
  PhoneNumber phoneNumber = PhoneNumber();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String birthday = "";

  final ImagePicker _picker = ImagePicker();

  BuildContext? context;

  ProfileController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    profileFormKey = new GlobalKey<FormState>();
  }

  @override
  void initState() {
    super.initState();

    context = state!.context;
    loader = Helper.overlayLoader(context);

    imageFile = user_repo.currentUserAvatar.value;
    firstNameController.text = user_repo.currentUser.value.firstName!;
    lastNameController.text = user_repo.currentUser.value.lastName!;
    gender = user_repo.currentUserProfile.value.gender;
    birthday = user_repo.currentUserProfile.value.birthday!;
    phone = user_repo.currentUserProfile.value.phone;
    if (phone != null) {
      final code = isoCodes.firstWhere(
          (item) => phone!.startsWith(item['code']!),
          orElse: () => {'locale': '', 'code': ''});
      phoneNumber = PhoneNumber(isoCode: code['locale']);
      phoneController.text = phone!.substring(code['code']!.length);
    }

    user_repo.currentUserAvatar.addListener(() {
      setState(() => imageFile = user_repo.currentUserAvatar.value);
      Helper.hideLoader(loader);
    });
    user_repo.currentUser.addListener(() {
      firstNameController.text = user_repo.currentUser.value.firstName!;
      lastNameController.text = user_repo.currentUser.value.lastName!;
    });
    user_repo.currentUserProfile.addListener(() {
      setState(() {
        gender = user_repo.currentUserProfile.value.gender;
        birthday = user_repo.currentUserProfile.value.birthday!;
        phone = user_repo.currentUserProfile.value.phone;
        if (phone != null) {
          final code = isoCodes.firstWhere(
              (item) => phone!.startsWith(item['code']!),
              orElse: () => {'locale': '', 'code': ''});
          phoneNumber = PhoneNumber(isoCode: code['locale']);
          phoneController.text = user_repo.currentUserProfile.value.phone!
              .substring(code['code']!.length);
        }
      });
      Helper.hideLoader(loader);
    });
  }

  Future<void> getImage(source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;
      File? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressQuality: 30,
        maxHeight: 1024,
        maxWidth: 1024,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Theme.of(context!).primaryColor,
            toolbarWidgetColor: Theme.of(context!).accentColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ),
      );
      if (croppedFile == null) return;
      final imageSize = await croppedFile.length();
      if (imageSize > 256 * 1024) {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(
              "Image size(${imageSize / 1024} KB) is larger than maximum size(256 KB)."),
        ));
        return;
      }
      Overlay.of(context!)!.insert(loader!);
      if (await user_repo.setUserAvatar(croppedFile.readAsBytesSync())) {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context!)!.appInfoUpdateSuccessfully),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context!)!.appInfoErrorOccured),
        ));
        Helper.hideLoader(loader);
      }
    } catch (e) {
      ScaffoldMessenger.of(context!)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> removeAvatar() async {
    try {
      Overlay.of(context!)!.insert(loader!);
      await user_repo.removeUserAvatar();
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> getProfile() async {
    await user_repo.getProfile();
  }

  Future<void> saveProfile() async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!profileFormKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      await user_repo.setProfile({
        'user_firstname': firstNameController.text,
        'user_lastname': lastNameController.text,
        'user_gender': gender,
        'user_birthday': birthday,
        'user_phone_mobile': phone,
      });
      await user_repo.getProfileData();
    } catch (e) {
      throw e;
    } finally {
      Helper.hideLoader(loader);
    }
  }
}
