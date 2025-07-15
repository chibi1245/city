import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_storage/get_storage.dart';

// Removed imports related to specific business logic, services, and core app components:
// import 'dart:io';
// import 'package:grs/constants/storage_keys.dart';
// import 'package:grs/provider/providers.dart';
// import 'package:grs/screen_craft.dart';
// import 'package:grs/service/http_overrides.dart';
// import 'package:grs/utils/app_config.dart';
// import 'package:grs/views/grievance_redress_app.dart';
// import 'di.dart' as dependency_injection;


/// flutter build appbundle --release
/// flutter build apk --split-per-abi
/// flutter pub run import_sorter:main lib

// keytool -list -v -keystore /Users/md.tanviranwarrafi/RafiTanvir/projects/freelanceing/grs_officer/android_key/grs_app.jks -alias key

Future<void> main() async {
  // Removed: await dependency_injection.init(); // No business services to initialize
  await initApp();
  await Future.delayed(const Duration(microseconds: 1200));
  runApp(_runApp());
}

// Removed the entire screenCraft() function as it's part of the original app's UI/logic.
// Widget screenCraft() => ScreenCraft(builder: (context, orientation) => GrievanceRedressApp());

// This is a placeholder widget for the stripped application.
Widget _placeholderApp() => Builder(
  builder: (context) => MaterialApp(
    // Use context to access EasyLocalization properties
    localizationsDelegates: EasyLocalization.of(context)?.delegates,
    supportedLocales: EasyLocalization.of(context)?.supportedLocales ?? const [Locale('en')],
    locale: EasyLocalization.of(context)?.locale ?? const Locale('en'),
    home: Scaffold(
      appBar: AppBar(title: const Text('')), // Use const for Text widget
      body: const Center(child: Text('.')), // Use const for Center and Text widgets
    ),
  ),
);


Future<void> initApp() async {
  // Removed: HttpOverrides.global = MyHttpOverrides(); // No services needing HTTP overrides
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Keep for basic app settings like language persistence if desired
  // Removed: await portraitMode(); // Assuming this was defined in app_config.dart and tied to the original app's setup
}

EasyLocalization _runApp() {
  return EasyLocalization(
    useOnlyLangCode: true,
    path: 'assets/languages', // Keep if you want to retain localization capabilities for a future app
    useFallbackTranslations: true,
    fallbackLocale: const Locale('bn'),
    supportedLocales: const [Locale('bn'), Locale('en')],
    // Replaced original startLocale which depended on removed constants/logic
    startLocale: const Locale('en'), // Default to English for a stripped app
    
    // Replaced the MultiProvider and screenCraft() with our placeholder app.
    child: DismissKeyboard(child: _placeholderApp()),
  );
}

class DismissKeyboard extends StatelessWidget {
  final Widget child;

  // Use Key? key and super(key: key) for better practice with constructors.
  const DismissKeyboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside a text field
        FocusScope.of(context).unfocus();
      },
      child: FocusScope(
        node: FocusScopeNode(),
        child: child,
      ),
    );
  }
}