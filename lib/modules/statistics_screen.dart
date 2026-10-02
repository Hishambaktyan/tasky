import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../shared/cubits/appCubit/app_cubit.dart';
import '../shared/cubits/appCubit/app_states.dart';
import '../shared/localization/app_localizations.dart';
import '../shared/styles/colors.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int selectedPeriodIndex = 0;

  final List<String> periods = [
    'week',
    'month',
    'year',
  ];
  List<Map<String, dynamic>> get weeklyData =>
      context.read<AppCubit>().weeklyData();

  List<Map<String, dynamic>> get categoryData =>
      context.read<AppCubit>().categoryData(selectedPeriodIndex);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        AppCubit appCubit = AppCubit.get(context);
        final isDark = appCubit.isDark;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.translate(
                'statistics',
                appCubit.language,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(bottom: 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPeriodPills(isDark, appCubit.language),
                SizedBox(height: 20.h),
                buildCompletionOverview(isDark, appCubit.language),
                SizedBox(height: 25.h),
                buildSectionHeader(
                  isDark,
                  AppLocalizations.translate(
                    'weekly_activity',
                    appCubit.language,
                  ),
                  Icons.bar_chart_rounded,
                ),
                SizedBox(height: 14.h),
                buildWeeklyChart(isDark, appCubit.language),
                SizedBox(height: 25.h),
                buildSectionHeader(
                  isDark,
                  AppLocalizations.translate(
                    'task_categories',
                    appCubit.language,
                  ),
                  Icons.pie_chart_rounded,
                ),
                SizedBox(height: 14.h),
                buildCategoryStatistics(isDark, appCubit.language),
                SizedBox(height: 25.h),
                buildSectionHeader(
                  isDark,
                  AppLocalizations.translate(
                    'performance',
                    appCubit.language,
                  ),
                  Icons.insights_rounded,
                ),
                SizedBox(height: 14.h),
                buildPerformanceCards(isDark, appCubit.language),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPeriodPills(bool isDark, String language) {
    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: periods.length,
        separatorBuilder: (context, index) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final isSelected = selectedPeriodIndex == index;

          return InkWell(
            onTap: () {
              setState(() {
                selectedPeriodIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(15.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? mainColor
                    : (isDark
                    ? lightDarkColor
                    : Colors.white),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: isSelected
                      ? mainColor
                      : Colors.transparent,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: mainColor.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Text(
                AppLocalizations.translate(
                  periods[index].toLowerCase(),
                  language,
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCompletionOverview(bool isDark, String language) {
    final cubit = context.read<AppCubit>();
    final periodTasks = cubit.tasksInPeriod(selectedPeriodIndex);
    final doneCount = periodTasks.where((t) => t.isCompleted).length;
    final rate = periodTasks.isEmpty ? 0.0 : doneCount / periodTasks.length;

    final timeframes = ['this_week', 'this_month', 'this_year'];

    return Container(
      margin: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      padding: EdgeInsetsDirectional.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            mainColor.withOpacity(0.22),
            const Color(0xFF161922),
          ]
              : [
            mainColor,
            mainColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(
              isDark ? 0.18 : 0.3,
            ),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.translate(
                    'completion_rate',
                    language,
                  ),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.white70,
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${(rate * 100).round()}%',
                      style: TextStyle(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppLocalizations.translate(
                        timeframes[selectedPeriodIndex],
                        language,
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? mainColor
                            : Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 82.r,
                height: 82.r,
                child: CircularProgressIndicator(
                  value: rate,
                  strokeWidth: 8.r,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${periodTasks.length}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    AppLocalizations.translate(
                      'tasks',
                      language,
                    ),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSectionHeader(
      bool isDark,
      String title,
      IconData icon,
      ) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
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
          const Spacer(),
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: isDark
                  ? lightDarkColor
                  : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              size: 18.r,
              color: isDark
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWeeklyChart(bool isDark, String language) {
    final int totalWeeklyTasks = weeklyData.fold<int>(
      0,
          (s, e) => s + (e['tasks'] as int),
    );

    return Container(
      margin: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      padding: EdgeInsetsDirectional.fromSTEB(15.w, 20.h, 15.w, 15.h),
      decoration: BoxDecoration(
        color: isDark ? lightDarkColor : Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.translate('tasks_completed', language),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              Text(
                AppLocalizations.translate(
                  'tasks_count',
                  language,
                  params: {'count': '$totalWeeklyTasks'},
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: mainColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h),
          SizedBox(
            height: 190.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.map((data) {
                final double value = data['value'];

                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 4.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${data['tasks']}',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          height: 130.h * value,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                mainColor,
                                mainColor.withOpacity(0.65),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(9.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          AppLocalizations.translate(
                            data['dayKey'] as String,
                            language,
                          ),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryStatistics(bool isDark, String language) {
    final data = categoryData;

    final total = data.fold<int>(
      0,
          (sum, item) => sum + (item['count'] as int),
    );

    return Container(
      margin: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      padding: EdgeInsetsDirectional.all(18.r),
      decoration: BoxDecoration(
        color: isDark ? lightDarkColor : Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: List.generate(data.length, (index) {
          final category = data[index];
          final Color categoryColor = category['color'] as Color;
          final int count = category['count'] as int;
          final double percentage =
          total == 0 ? 0.0 : count / total;

          final String categoryKey =
          (category['name'] as String).toLowerCase();

          return Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: index == data.length - 1 ? 0 : 18.h,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 9.w),
                    Expanded(
                      child: Text(
                        AppLocalizations.translate(
                          categoryKey,
                          language,
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1D1E),
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.translate(
                        'tasks_count',
                        language,
                        params: {'count': '$count'},
                      ),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '${(percentage * 100).round()}%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 6.h,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFF0F2F5),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(categoryColor),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget buildPerformanceCards(bool isDark, String language) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      child: Row(
        children: [
          Expanded(
            child: buildPerformanceCard(
              isDark: isDark,
              icon: Icons.local_fire_department_rounded,
              title: AppLocalizations.translate(
                'current_streak',
                language,
              ),
              value: AppLocalizations.translate(
                'days_count',
                language,
                params: {
                  'days': '${context.read<AppCubit>().currentStreak}'
                },
              ),
              color: const Color(0xFFFF5252),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: buildPerformanceCard(
              isDark: isDark,
              icon: Icons.emoji_events_rounded,
              title: AppLocalizations.translate(
                'best_streak',
                language,
              ),
              value: AppLocalizations.translate(
                'days_count',
                language,
                params: {
                  'days': '${context.read<AppCubit>().bestStreak}'
                },
              ),
              color: const Color(0xFFFFB300),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPerformanceCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsetsDirectional.all(16.r),
      decoration: BoxDecoration(
        color: isDark
            ? lightDarkColor
            : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? 0.2 : 0.03,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              icon,
              size: 18.r,
              color: color,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? Colors.white
                  : const Color(0xFF1A1D1E),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}