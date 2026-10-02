import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../shared/cubits/appCubit/app_cubit.dart';
import '../shared/cubits/appCubit/app_states.dart';
import '../shared/localization/app_localizations.dart';
import '../shared/styles/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        AppCubit appCubit = AppCubit.get(context);
        final isDark = appCubit.isDark;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.translate('settings', appCubit.language),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(
              start: 15.w,
              end: 15.w,
              bottom: 110.h,
              top: 10.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionTitle(
                  AppLocalizations.translate(
                    'preferences',
                    appCubit.language,
                  ),
                  isDark,
                ),
                SizedBox(height: 13.h),
                buildSettingsCard(
                  isDark,
                  [
                    buildSettingItem(
                      icon: 'assets/icons/lang.svg',
                      title: AppLocalizations.translate(
                        'language',
                        appCubit.language,
                      ),
                      subtitle: appCubit.language == 'ar'
                          ? AppLocalizations.translate(
                        'arabic',
                        appCubit.language,
                      )
                          : AppLocalizations.translate(
                        'english',
                        appCubit.language,
                      ),
                      trailing: Icons.arrow_forward_ios_rounded,
                      isDark: isDark,
                      onTap: () {
                        showLanguageDialog(context, appCubit);
                      },
                    ),
                    buildDivider(isDark),
                    buildSwitchItem(
                      icon: 'assets/icons/moon.svg',
                      title: AppLocalizations.translate(
                        'dark_mode',
                        appCubit.language,
                      ),
                      subtitle: AppLocalizations.translate(
                        'dark_mode_subtitle',
                        appCubit.language,
                      ),
                      value: isDark,
                      isDark: isDark,
                      onChanged: (value) {
                        appCubit.changeTheme();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 3.w),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? Colors.white
                  : const Color(0xFF1A1D1E),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: mainColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsCard(bool isDark, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? lightDarkColor : Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget buildSettingItem({
    required String icon,
    required String title,
    required String subtitle,
    required IconData trailing,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 16.w,
          vertical: 15.h,
        ),
        child: Row(
          children: [
            Container(
              width: 43.r,
              height: 43.r,
              padding: EdgeInsets.all(11.r),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: SvgPicture.asset(
                icon,
                color: mainColor,
              ),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF1A1D1E),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              trailing,
              size: 15.r,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSwitchItem({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
        vertical: 13.h,
      ),
      child: Row(
        children: [
          Container(
            width: 43.r,
            height: 43.r,
            padding: EdgeInsets.all(11.r),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: SvgPicture.asset(
              icon,
              color: mainColor,
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF1A1D1E),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: mainColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget buildDivider(bool isDark) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      child: Divider(
        height: 1,
        thickness: 0.7,
        color: isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.grey.shade200,
      ),
    );
  }

  void showLanguageDialog(BuildContext context, AppCubit appCubit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          title: Text(
            AppLocalizations.translate(
              'language',
              appCubit.language,
            ),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildLanguageOption(
                context: context,
                title: AppLocalizations.translate(
                  'english',
                  appCubit.language,
                ),
                subtitle: 'English',
                languageCode: 'en',
                appCubit: appCubit,
              ),
              SizedBox(height: 10.h),
              buildLanguageOption(
                context: context,
                title: AppLocalizations.translate(
                  'arabic',
                  appCubit.language,
                ),
                subtitle: 'العربية',
                languageCode: 'ar',
                appCubit: appCubit,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildLanguageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String languageCode,
    required AppCubit appCubit,
  })
  {
    final bool isSelected = appCubit.language == languageCode;
    final bool isDark = appCubit.isDark;

    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        appCubit.changeLanguage(languageCode);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? mainColor.withOpacity(0.12)
              : (isDark
              ? lightDarkColor
              : Colors.white),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected
                ? mainColor
                : (isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.shade200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Icon(
                Icons.language_rounded,
                color: mainColor,
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? mainColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? mainColor
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14.r,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}