import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grs/drawers/app_drawer.dart'; // For SystemUiOverlayStyle

// Dummy TextStyles and SizeConfig to replace sl<TextStyles>() and custom responsive values.
// In a real project, these might be in a separate, purely UI-focused 'utils' or 'constants' file.
class DummyTextStyles {
  TextStyle text18_500(Color color) => TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color, fontFamily: poppins);
  TextStyle text20_600(Color color) => TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color, fontFamily: poppins);
  TextStyle text14_400(Color color) => TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: color, fontFamily: poppins);
  TextStyle text14_500(Color color) => TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color, fontFamily: poppins);
  TextStyle text16_500(Color color) => TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color, fontFamily: poppins);
  TextStyle text12_500(Color color) => TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color, fontFamily: poppins);
}
final _dummyTextStyles = DummyTextStyles();

// --- UI-related Constants ---
const String poppins = 'poppins'; // Assuming this font is included in pubspec.yaml
const Color primary = Color(0xFF6200EE); // Example color
const Color pink = Colors.pink; // Example color
const Color grey40 = Color(0xFFBDBDBD); // Example color
const Color grey80 = Color(0xFF333333); // Example color
const Color disabled = Color(0xFFE0E0E0); // Example color
const Color transparent = Colors.transparent;
const Color white = Colors.white;
const Color black = Colors.black;
const Color popupBearer = Color(0x66000000); // Semi-transparent black for scrim
const double drawerWidth = 250.0; // Example fixed width for drawer
const Color red20 = Color(0xFFEF9A9A); // Example color

// Placeholder for responsive values and overlay style
// In a real project, you'd use MediaQuery or a robust responsive package.
final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle.light; // Or dark, depending on design
const Size button52Large = Size(double.infinity, 52); // Example button size
// Assuming 13.5.widthRatio was an extension, replacing it with a fixed height or a calculation
double get _appBarToolbarHeight => 72.0; // Example fixed height for toolbar


ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: false,
    fontFamily: poppins,
    primaryColor: primary,
    dividerColor: grey40,
    disabledColor: disabled,
    hintColor: grey80,
    indicatorColor: primary,
    primarySwatch: Colors.indigo,
    splashColor: transparent,
    focusColor: transparent,
    hoverColor: transparent,
    highlightColor: transparent,
    scaffoldBackgroundColor: white,
    brightness: Brightness.light,
    visualDensity: VisualDensity.comfortable,
    textTheme: _textThemeLight,
    dividerTheme: _dividerThemeLight,
    primaryIconTheme: _primaryIconThemeLight,
    drawerTheme: _drawerThemeLight,
    dialogTheme: _dialogThemeLight,
    bottomSheetTheme: _bottomSheetThemeLight,
    tabBarTheme: _tabBarThemeLight,
    appBarTheme: _appBarThemeLight,
    cardTheme: _cardThemeLight,
    chipTheme: _chipThemeLight,
    bottomAppBarTheme: _bottomAppBarThemeLight,
    bottomNavigationBarTheme: bottomNavigationBarThemeLight,
    buttonTheme: _buttonThemeLight,
    floatingActionButtonTheme: _floatingActionButtonThemeLight,
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyleLight),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _outlineButtonStyleLight),
    colorScheme: const ColorScheme.light(
      primary: pink,           // Main buttons
      secondary: pink,         // FABs, selection controls
      onSurface: black,        // Regular text color
      surfaceVariant: white,
      secondaryContainer: pink,
      onSecondaryContainer: white,
    ),
  );
}

// Replaced sl<TextStyles>() with _dummyTextStyles
TextTheme get _textThemeLight => TextTheme(labelLarge: _dummyTextStyles.text18_500(white));
DividerThemeData get _dividerThemeLight => const DividerThemeData(color: grey40, thickness: 1);
IconThemeData get _primaryIconThemeLight => const IconThemeData(color: black, size: 24);

DrawerThemeData get _drawerThemeLight => DrawerThemeData(elevation: 0, backgroundColor: white, scrimColor: popupBearer, width: drawerWidth);
DialogThemeData get _dialogThemeLight {
  return DialogThemeData(
    elevation: 2,
    iconColor: black,
    backgroundColor: white,
    alignment: Alignment.topCenter,
    titleTextStyle: _dummyTextStyles.text20_600(black),
    contentTextStyle: _dummyTextStyles.text14_400(black),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}

CardThemeData get _cardThemeLight {
  return CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    color: white,
    margin: EdgeInsets.zero,
  );
}

ChipThemeData get _chipThemeLight {
  return ChipThemeData(
    backgroundColor: white,
    selectedColor: pink,
    disabledColor: grey80,
    labelStyle: _dummyTextStyles.text14_500(black),
    secondaryLabelStyle: _dummyTextStyles.text14_500(white),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: black),
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0
  );
}

BottomSheetThemeData get _bottomSheetThemeLight {
  var radius = const Radius.circular(10);
  return BottomSheetThemeData(
    elevation: 5,
    modalElevation: 5,
    backgroundColor: white,
    modalBackgroundColor: white,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: radius, topRight: radius)),
  );
}

TabBarThemeData get _tabBarThemeLight => TabBarThemeData(
      labelColor: black,
      indicatorColor: primary,
      unselectedLabelColor: grey80,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: _dummyTextStyles.text16_500(black),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      unselectedLabelStyle: _dummyTextStyles.text16_500(grey80),
      indicator: const UnderlineTabIndicator(borderSide: BorderSide(color: primary, width: 2)),
    );

AppBarTheme get _appBarThemeLight {
  return AppBarTheme(
    elevation: 0,
    titleSpacing: 16,
    centerTitle: true,
    backgroundColor: white,
    systemOverlayStyle: overlayStyle,
    titleTextStyle: _dummyTextStyles.text18_500(black),
    toolbarTextStyle: _dummyTextStyles.text18_500(black),
    iconTheme: const IconThemeData(color: black, size: 24),
    actionsIconTheme: const IconThemeData(color: black, size: 24),
    toolbarHeight: _appBarToolbarHeight, // Replaced 13.5.widthRatio
  );
}

BottomAppBarTheme get _bottomAppBarThemeLight => const BottomAppBarTheme(color: primary, elevation: 3);

BottomNavigationBarThemeData get bottomNavigationBarThemeLight {
  return BottomNavigationBarThemeData(
    elevation: 3,
    backgroundColor: white,
    showUnselectedLabels: true,
    showSelectedLabels: true,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: _dummyTextStyles.text12_500(pink),
    unselectedLabelStyle: _dummyTextStyles.text12_500(black),
    landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    selectedIconTheme: const IconThemeData(size: 24, color: pink),
    unselectedIconTheme: const IconThemeData(size: 24, color: black),
  );
}

ButtonThemeData get _buttonThemeLight {
  return ButtonThemeData(
    minWidth: 50,
    height: 52,
    disabledColor: red20,
    buttonColor: primary,
    focusColor: transparent,
    hoverColor: transparent,
    splashColor: transparent,
    highlightColor: transparent,
    // textTheme: ButtonTextTheme.accent,
    // layoutBehavior: ButtonBarLayoutBehavior.constrained,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

FloatingActionButtonThemeData get _floatingActionButtonThemeLight {
  return FloatingActionButtonThemeData(
    iconSize: 24,
    backgroundColor: primary,
    foregroundColor: white,
    hoverColor: transparent,
    splashColor: transparent,
    focusColor: transparent,
    disabledElevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );
}

ButtonStyle get _elevatedButtonStyleLight {
  return ElevatedButton.styleFrom(
    elevation: 0.5,
    shadowColor: transparent,
    backgroundColor: primary,
    disabledBackgroundColor: primary.withOpacity(0.3),
    disabledForegroundColor: white,
    disabledMouseCursor: MouseCursor.defer,
    visualDensity: VisualDensity.comfortable,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    minimumSize: button52Large,
    maximumSize: button52Large,
    textStyle: _dummyTextStyles.text18_500(white),
    side: const BorderSide(color: transparent, width: 0),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );
}

ButtonStyle get _outlineButtonStyleLight {
  var grey60;
  return OutlinedButton.styleFrom(
    elevation: 0.5,
    shadowColor: transparent,
    backgroundColor: transparent,
    foregroundColor: grey80,
    disabledBackgroundColor: transparent,
    disabledForegroundColor: grey40,
    enabledMouseCursor: MouseCursor.uncontrolled,
    disabledMouseCursor: MouseCursor.defer,
    visualDensity: VisualDensity.comfortable,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    side: BorderSide(color: grey60),
    textStyle: _dummyTextStyles.text18_500(grey80),
    minimumSize: button52Large,
    maximumSize: button52Large,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );
}