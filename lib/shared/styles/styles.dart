import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: 'Tajawal',
  scaffoldBackgroundColor: bgColor,
  colorScheme: ColorScheme.fromSeed(seedColor: mainColor,brightness: Brightness.light,),
  appBarTheme: AppBarTheme(
    backgroundColor:  bgColor,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 24.sp,
      fontFamily: 'Tajawal',
    ),
    scrolledUnderElevation: 0,
    titleSpacing: 15,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
  ),
  textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.black,
      )
  ),
  iconTheme: const IconThemeData(
      color: Colors.black
  ),
);

ThemeData darkTheme = ThemeData(
  fontFamily: 'Tajawal',
  scaffoldBackgroundColor: darkBgColor,
  colorScheme: ColorScheme.fromSeed(seedColor: mainColor,brightness: Brightness.dark,),
  appBarTheme: AppBarTheme(
    backgroundColor:  darkBgColor,
    scrolledUnderElevation: 0,
    titleSpacing: 15,
    elevation: 0,
    titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24.sp,
      fontFamily: 'Tajawal',
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.white,
      )
  ),
  iconTheme: const IconThemeData(
      color: Colors.white
  ),
);