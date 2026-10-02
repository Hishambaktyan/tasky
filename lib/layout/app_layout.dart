import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../modules/add_task_screen.dart';
import '../shared/compenents/compenents.dart';
import '../shared/cubits/appCubit/app_cubit.dart';
import '../shared/cubits/appCubit/app_states.dart';
import '../shared/localization/app_localizations.dart';
import '../shared/styles/colors.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        AppCubit appCubit = AppCubit.get(context);
        return Scaffold(
          body:Stack(
            children: [
              appCubit.screens[appCubit.currentIndex],
              Align(
                alignment: AlignmentGeometry.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Container(
                    margin: EdgeInsetsDirectional.only(start: 16.w,top:  0.h,end:  16.w,bottom:  15.h),
                    decoration: BoxDecoration(
                      color: appCubit.isDark
                          ? lightDarkColor.withOpacity(0.88)
                          : Colors.white.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(35.r),
                      border: Border.all(
                        color: appCubit.isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.withOpacity(0.12),
                        width: 0.7,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            appCubit.isDark ? 0.18 : 0.07,
                          ),
                          blurRadius: 25,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 25,
                          sigmaY: 25,
                        ),
                        child: SizedBox(
                          height: 70.h,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildNavItem(
                                  icon: 'assets/icons/home.svg',
                                  selectedIcon: 'assets/icons/home_bold.svg',
                                  label: AppLocalizations.translate(
                                    'home',
                                    appCubit.language,
                                  ),
                                  index: 0,
                                  appCubit: appCubit,
                                ),
                              ),
                              Expanded(
                                child: _buildNavItem(
                                  icon: 'assets/icons/tasks.svg',
                                  selectedIcon: 'assets/icons/tasks_bold.svg',
                                  label: AppLocalizations.translate(
                                    'tasks',
                                    appCubit.language,
                                  ),
                                  index: 1,
                                  appCubit: appCubit,
                                ),
                              ),
                              SizedBox(
                                width: 60.w,
                                child: Center(
                                  child: InkWell(
                                    onTap: () => move(
                                      context,
                                      AddTaskScreen()
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Container(
                                      width: 42.w,
                                      height: 42.h,
                                      decoration: BoxDecoration(
                                        color: mainColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: mainColor.withOpacity(0.18),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.add_rounded,
                                        color: mainColor,
                                        size: 27.r,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _buildNavItem(
                                  icon: 'assets/icons/chart.svg',
                                  selectedIcon: 'assets/icons/chart_bold.svg',
                                  label: AppLocalizations.translate(
                                    'statistics',
                                    appCubit.language,
                                  ),
                                  index: 2,
                                  appCubit: appCubit,
                                ),
                              ),
                              Expanded(
                                child: _buildNavItem(
                                  icon: 'assets/icons/settings.svg',
                                  selectedIcon: 'assets/icons/settings_bold.svg',
                                  label: AppLocalizations.translate(
                                    'settings',
                                    appCubit.language,
                                  ),
                                  index: 3,
                                  appCubit: appCubit,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String selectedIcon,
    required String label,
    required int index,
    required AppCubit appCubit,
  }) {
    final bool isSelected = appCubit.currentIndex == index;

    final Color color = isSelected
        ? mainColor
        : (appCubit.isDark ? Colors.grey.shade700 : Colors.black54);

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        appCubit.changeIndex(index);
      },
      child: SizedBox(
        height: 70.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              isSelected ? selectedIcon : icon,
              width: 25.w,
              height: 25.h,
              color: color,
            ),

            SizedBox(height: 3.h),

            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.sp,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}