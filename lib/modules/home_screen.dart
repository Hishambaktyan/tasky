import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../shared/compenents/compenents.dart';
import '../shared/cubits/appCubit/app_cubit.dart';
import '../shared/cubits/appCubit/app_states.dart';
import '../shared/localization/app_localizations.dart';
import '../shared/models/task_model.dart';
import '../shared/styles/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;
  int selectedDateIndex = DateTime.now().weekday - 1;
  final List<String> categories = ['all', 'work', 'personal', 'meeting', 'study'];

  DateTime get weekStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  List<DateTime> get weekDays => List.generate(
      7, (i) => DateTime(weekStart.year, weekStart.month, weekStart.day + i));

  List<Map<String, dynamic>> get dayTasks {
    final cubit = context.read<AppCubit>();
    return cubit
        .tasksOn(weekDays[selectedDateIndex])
        .where((t) =>
    selectedCategoryIndex == 0 ||
        t.category.toLowerCase() == categories[selectedCategoryIndex])
        .map(AppCubit.toCard)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        AppCubit appCubit = AppCubit.get(context);
        final isDark = appCubit.isDark;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.translate('dashboard', appCubit.language),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(bottom: 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildProgressOverview(isDark, appCubit.language),
                SizedBox(height: 30.h),
                buildWeekTimeline(isDark, appCubit.language),
                SizedBox(height: 5.h),
                buildCategoryPills(isDark, appCubit.language),
                buildTimelineHeader(isDark, appCubit.language),
                SizedBox(height: 14.h),
                buildTaskCards(isDark, appCubit.language),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildProgressOverview(bool isDark, String language) {
    final all = context.read<AppCubit>().tasksOn(weekDays[selectedDateIndex]);
    final done = all.where((t) => t.isCompleted).length;
    final ratio = all.isEmpty ? 0.0 : done / all.length;

    return Container(
      margin: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      padding: EdgeInsetsDirectional.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            mainColor.withOpacity(0.25),
            const Color(0xFF161922),
          ]
              : [
            mainColor,
            mainColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(isDark ? 0.2 : 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.translate('daily_progress', language).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isDark ? Colors.grey.shade400 : Colors.white70,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${(ratio * 100).round()}%',
                        style: TextStyle(
                          fontSize: 35.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        AppLocalizations.translate('completed_status', language),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? mainColor : Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60.r,
                    height: 60.r,
                    child: CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 7.r,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 22.r,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsetsDirectional.all(10.r),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.task_alt_rounded,
                  size: 16.r,
                  color: Colors.white70,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    AppLocalizations.translate(
                      'tasks_completed_fmt',
                      language,
                      params: {
                        'done': '$done',
                        'total': '${all.length}',
                      },
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWeekTimeline(bool isDark, String language) {
    final letters = [
      AppLocalizations.translate('mon_short', language),
      AppLocalizations.translate('tue_short', language),
      AppLocalizations.translate('wed_short', language),
      AppLocalizations.translate('thu_short', language),
      AppLocalizations.translate('fri_short', language),
      AppLocalizations.translate('sat_short', language),
      AppLocalizations.translate('sun_short', language),
    ];
    final dates = List.generate(
        7, (i) => {'day': letters[i], 'date': '${weekDays[i].day}'});

    return SizedBox(
      height: 85.h,
      child: ListView.separated(
        padding: EdgeInsetsDirectional.only(start: 15.w, end: 15.w, bottom: 17.h),
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final isSelected = selectedDateIndex == index;

          return InkWell(
            onTap: () {
              setState(() {
                selectedDateIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(20.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54.w,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [mainColor, mainColor.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? const Color(0xFF1A1D24) : Colors.white),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: mainColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dates[index]['day']!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    dates[index]['date']!,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF1A1D1E)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCategoryPills(bool isDark, String language) {
    return SizedBox(
      height: 55.h,
      child: ListView.separated(
        padding: EdgeInsetsDirectional.only(start: 15.w, end: 15.w, bottom: 20.h),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final isSelected = selectedCategoryIndex == index;

          return InkWell(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(30.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? mainColor
                    : (isDark
                    ? const Color(0xFF1A1D24)
                    : Colors.white),
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: mainColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Text(
                AppLocalizations.translate(categories[index], language),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTimelineHeader(bool isDark, String language) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.translate('schedule', language),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF1A1D1E),
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
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1D24) : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 18.r,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskCards(bool isDark, String language) {
    if (dayTasks.isEmpty) {
      return buildEmptyState(
        isDark: isDark,
        icon: Icons.event_available_rounded,
        title: AppLocalizations.translate('no_tasks_yet', language),
        subtitle: AppLocalizations.translate('add_first_task_sub', language),
      );
    }
    return ListView.separated(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayTasks.length,
      separatorBuilder: (context, index) => SizedBox(height: 14.h),
      itemBuilder: (context, index) {
        final task = dayTasks[index];
        final bool isDone = task['isCompleted'];
        final Color categoryColor = task['color'] as Color;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 14.r,
                    height: 14.r,
                    margin: EdgeInsets.only(top: 18.h),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? Colors.grey.shade400 : categoryColor,
                      boxShadow: [
                        if (!isDone)
                          BoxShadow(
                            color: categoryColor.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2.w,
                      margin: EdgeInsets.symmetric(vertical: 6.h),
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Container(
                  padding: EdgeInsetsDirectional.all(15.r),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1D24) : Colors.white,
                    borderRadius: BorderRadius.circular(22.r),
                    border: BorderDirectional(
                      start: BorderSide(
                        color: isDone ? Colors.grey.shade400 : categoryColor,
                        width: 4.w,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              AppLocalizations.translate(
                                (task['category'] as String).toLowerCase(),
                                language,
                              ),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: categoryColor,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () =>context.read<AppCubit>().toggleTask(task['model'] as TaskModel),
                            borderRadius: BorderRadius.circular(8.r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                color: isDone ? mainColor : Colors.transparent,
                                border: Border.all(
                                  color: isDone ? mainColor : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 12.r,
                                color: isDone ? Colors.white : Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        task['title'],
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: isDone
                              ? Colors.grey
                              : (isDark ? Colors.white : const Color(0xFF1A1D1E)),
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14.r,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            task['time'],
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : const Color(0xFFF0F2F5),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              AppLocalizations.translate(
                                (task['priority'] as String).toLowerCase(),
                                language,
                              ),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: task['priority'] == 'High'
                                    ? const Color(0xFFFF5252)
                                    : task['priority'] == 'Medium'
                                    ? const Color(0xFFFFB300)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}