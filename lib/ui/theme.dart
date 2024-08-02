
import 'package:alc_mobile_app/ui/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const double textHeader1Size = 26;
const double textHeader2Size = 22;
const double textTitle1Size = 18;
const double textTitle2Size = 16;
const double textBodySize = 16;
const double textSubBodySize = 14;
const double textCaptionSize = 12;
const double textBadgeSize = 10;
const double textButtonSize = 14;

final ThemeData alcMobileTheme = ThemeData(
  dialogBackgroundColor: Colors.white,
  useMaterial3: true,
  primaryColor: AlcMobileColors.primary,
  disabledColor: AlcMobileColors.disabledColor,
  fontFamily: 'Kanit',
  scaffoldBackgroundColor: AlcMobileColors.scaffoldBackgroundColor,
  appBarTheme: AppBarTheme(
    color: AlcMobileColors.primary,
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    actionsIconTheme: const IconThemeData(
      color: Colors.white,
    ),
    titleTextStyle: const TextStyle().copyWith(
      color: Colors.white,
      fontFamily: 'Kanit',
      fontSize: textBodySize.sp,
      fontWeight: FontWeight.w500,
    ),
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle().copyWith(
      fontSize: textHeader1Size.sp,
      fontWeight: FontWeight.w400,
      color: AlcMobileColors.textThemeColor,
    ),
    displayMedium: const TextStyle().copyWith(
      fontSize: textHeader2Size.sp,
      fontWeight: FontWeight.w400,
      color: AlcMobileColors.textThemeColor,
    ),
    displaySmall: const TextStyle().copyWith(
      fontSize: textTitle1Size.sp,
      fontWeight: FontWeight.w400,
      color: AlcMobileColors.textThemeColor,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: textHeader1Size.sp,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: textHeader2Size.sp,
      fontWeight: FontWeight.w500,
      color: AlcMobileColors.textThemeColor,
    ),
    titleLarge: const TextStyle().copyWith(
      fontSize: textTitle1Size.sp,
      fontWeight: FontWeight.w500,
      color: AlcMobileColors.textThemeColor,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: textTitle2Size.sp,
      fontWeight: FontWeight.w500,
      color: AlcMobileColors.primary,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: textBodySize.sp,
      fontWeight: FontWeight.w500,
      color: AlcMobileColors.textThemeColor,
    ),
    bodyLarge: const TextStyle().copyWith(
      fontSize: textBodySize.sp,
      fontWeight: FontWeight.w400,
      color: AlcMobileColors.textThemeColor,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: textSubBodySize.sp,
      fontWeight: FontWeight.w300,
      color: AlcMobileColors.textThemeColor,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: textCaptionSize.sp,
      fontWeight: FontWeight.w400,
      color: AlcMobileColors.textThemeColor,
    ),
    labelLarge: const TextStyle().copyWith(
      fontSize: textButtonSize.sp,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    labelSmall: const TextStyle().copyWith(
      fontSize: textBadgeSize.sp,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all<TextStyle>(
        TextStyle(
          fontSize: textButtonSize.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Kanit'
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) return AlcMobileColors.primary.withOpacity(0.5);
          return AlcMobileColors.primary;
        },
      ),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 16.sp)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))),
      minimumSize: WidgetStateProperty.all(Size(40.sp, 50.sp)),
      elevation: WidgetStateProperty.all(10),
      shadowColor: WidgetStateProperty.all(AlcMobileColors.primary.withOpacity(0.25)),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AlcMobileColors.primary,
    disabledColor: AlcMobileColors.primary.withOpacity(0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
    height: 50.w,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
    ),
    backgroundColor: AlcMobileColors.scaffoldBackgroundColor,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AlcMobileColors.primary,
    surface: AlcMobileColors.backgroundColor,
  ),
  /* inputDecorationTheme: InputDecorationTheme(
    prefixIconColor: AlcMobileColors.inputIconColor,
    suffixIconColor: AlcMobileColors.inputIconColor,
    iconColor: AlcMobileColors.inputIconColor,
    hintStyle: TextStyle(fontSize: textBodySize.sp, color: Colors.black38),
    errorStyle: TextStyle(fontSize: textSubBodySize.sp, color: AlcMobileColors.redAlert, overflow: TextOverflow.clip),
    alignLabelWithHint: false,
    errorMaxLines: 3,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        color: AlcMobileColors.inputBorderColor,
        width: 1, 
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        color: AlcMobileColors.lightGray,
        width: 1,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        color: AlcMobileColors.redAlert,
        width: 1, 
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        color: AlcMobileColors.redAlert,
        width: 1, 
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        color: AlcMobileColors.primary,
        width: 1
      ),
    ),
    fillColor: Colors.transparent,
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    isCollapsed: false,
    isDense: false,
  ) */
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AlcMobileColors.primary,
    shape: CircleBorder(),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white
  )
);