import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_tracker/shared/compenents/compenents.dart';
import 'package:task_tracker/shared/localization/app_localizations.dart';

import '../shared/cubits/appCubit/app_cubit.dart';
import '../shared/cubits/appCubit/app_states.dart';
import '../shared/models/task_model.dart';
import '../shared/styles/colors.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int selectedFilterIndex = 0;
  int selectedCategoryIndex = 0;
  TextEditingController searchController = TextEditingController();

  final List<String> filters = [
    'all_tasks',
    'pending',
    'completed',
    'high_priority',
  ];

  final List<String> categories = [
    'all',
    'work',
    'personal',
    'meeting',
    'study',
  ];
  List<Map<String, dynamic>> get allTasks =>
      context.read<AppCubit>().tasks.map(AppCubit.toCard).toList();
  List<Map<String, dynamic>> get tasks {
    final query = searchController.text.trim().toLowerCase();
    return allTasks.where((t) {
      final done = t['isCompleted'] as bool;
      if (selectedFilterIndex == 1 && done) return false;
      if (selectedFilterIndex == 2 && !done) return false;
      if (selectedFilterIndex == 3 && t['priority'] != 'High') return false;

      if (selectedCategoryIndex != 0 &&
          (t['category'] as String).toLowerCase() != categories[selectedCategoryIndex]) {
        return false;
      }

      if (query.isNotEmpty) {
        final title = (t['title'] ?? '').toString().toLowerCase();
        if (!title.contains(query)) return false;
      }

      return true;
    }).toList();
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
              AppLocalizations.translate('tasks', appCubit.language),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(bottom: 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
                  child: defaultTextFormField(
                    text: AppLocalizations.translate('search', appCubit.language),
                    prefixIcon: 'assets/icons/search.svg',
                    errorMes: '',
                    controller:searchController,
                    type: TextInputType.text,
                    cubit: appCubit,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(height: 20.h),
                buildTasksOverview(isDark, appCubit.language),
                SizedBox(height: 20.h),
                buildFilterPills(isDark, appCubit.language),
                buildCategoryPills(isDark, appCubit.language),
                SizedBox(height: 10.h,),
                buildTasksSectionHeader(isDark, appCubit.language),
                SizedBox(height: 14.h),
                buildTasksList(isDark, appCubit.language),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTasksOverview(bool isDark, String language) {
    final total = allTasks.length;
    final completed = allTasks
        .where((task) => task['isCompleted'] == true)
        .length;
    final pending = total - completed;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      child: Row(
        children: [
          Expanded(
            child: buildOverviewCard(
              isDark: isDark,
              title: AppLocalizations.translate('total', language),
              value: '$total',
              icon: Icons.task_alt_rounded,
              color: mainColor,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: buildOverviewCard(
              isDark: isDark,
              title: AppLocalizations.translate('pending', language),
              value: '$pending',
              icon: Icons.schedule_rounded,
              color: const Color(0xFFFFB300),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: buildOverviewCard(
              isDark: isDark,
              title: AppLocalizations.translate('completed', language),
              value: '$completed',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF00BFA5),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOverviewCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsetsDirectional.all(15.r),
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
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              icon,
              size: 17.r,
              color: color,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? Colors.white
                  : const Color(0xFF1A1D1E),
            ),
          ),
          SizedBox(height: 2.h),
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

  Widget buildFilterPills(bool isDark, String language) {
    return SizedBox(
      height: 55.h,
      child: ListView.separated(
        padding: EdgeInsetsDirectional.only(start: 15.w,end: 15.w,bottom: 15.h),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: 9.w),
        itemBuilder: (context, index) {
          final isSelected = selectedFilterIndex == index;

          return InkWell(
            onTap: () {
              setState(() {
                selectedFilterIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(15.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 17.w,
              ),
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
                AppLocalizations.translate(filters[index].toString().toLowerCase(), language),
                style: TextStyle(
                  fontSize: 11.sp,
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

  Widget buildCategoryPills(bool isDark, String language) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: 18.w),
        itemBuilder: (context, index) {
          final isSelected = selectedCategoryIndex == index;

          return InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.translate(categories[index].toString().toLowerCase(), language),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isSelected
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: isSelected
                        ? mainColor
                        : (isDark
                        ? Colors.grey.shade500
                        : Colors.grey.shade600),
                  ),
                ),
                SizedBox(height: 5.h),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 18.w : 0,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTasksSectionHeader(bool isDark, String language) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      child: Row(
        children: [
          Text(
            AppLocalizations.translate('all_tasks', language),
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
        ],
      ),
    );
  }

  Widget buildTasksList(bool isDark, String language) {
    if (tasks.isEmpty) {
      final noTasksAtAll = allTasks.isEmpty;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: buildEmptyState(
          isDark: isDark,
          icon: noTasksAtAll ? Icons.checklist_rounded : Icons.search_off_rounded,
          title: AppLocalizations.translate(
            noTasksAtAll ? 'no_tasks_yet' : 'no_matching_tasks',
            language,
          ),
          subtitle: AppLocalizations.translate(
            noTasksAtAll ? 'add_first_task_sub' : 'change_filter_sub',
            language,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => SizedBox(height: 13.h),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final bool isDone = task['isCompleted'];
        final Color categoryColor = task['color'] as Color;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 13.r,
                    height: 13.r,
                    margin: EdgeInsets.only(top: 20.h),
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.grey.shade400
                          : categoryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (!isDone)
                          BoxShadow(
                            color: categoryColor.withOpacity(0.4),
                            blurRadius: 7,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2.w,
                      margin: EdgeInsets.symmetric(vertical: 5.h),
                      color: isDark
                          ? Colors.white.withOpacity(0.07)
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onLongPress: () async {
                    final cubit = context.read<AppCubit>();
                    final model = task['model'] as TaskModel;
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          AppLocalizations.translate('delete_task_title', language),
                        ),
                        content: Text(model.title),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              AppLocalizations.translate('cancel', language),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              AppLocalizations.translate('delete', language),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) cubit.deleteTask(model.id!);
                  },
                  onTap: ()=>context.read<AppCubit>().toggleTask(task['model'] as TaskModel),
                  borderRadius: BorderRadius.circular(22.r),
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: isDark
                          ? lightDarkColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                      border: BorderDirectional(
                        start: BorderSide(
                          color: isDone
                              ? Colors.grey.shade400
                              : categoryColor,
                          width: 4.w,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isDark ? 0.25 : 0.04,
                          ),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding:
                              EdgeInsetsDirectional.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor
                                    .withOpacity(0.1),
                                borderRadius:
                                BorderRadius.circular(9.r),
                              ),
                              child: Text(
                                AppLocalizations.translate(
                                  (task['category'] as String).toLowerCase(),
                                  language,
                                ),
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: ()=>context.read<AppCubit>().toggleTask(task['model'] as TaskModel),
                              borderRadius:
                              BorderRadius.circular(8.r),
                              child: AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 200,
                                ),
                                width: 25.r,
                                height: 25.r,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? mainColor
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isDone
                                        ? mainColor
                                        : Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 14.r,
                                  color: isDone
                                      ? Colors.white
                                      : Colors.transparent,
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
                                : (isDark
                                ? Colors.white
                                : const Color(0xFF1A1D1E)),
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
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
                            SizedBox(width: 5.w),
                            Text(
                              '${task['date']} • ${task['time']}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding:
                              EdgeInsetsDirectional.symmetric(
                                horizontal: 9.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white
                                    .withOpacity(0.05)
                                    : const Color(0xFFF1F3F5),
                                borderRadius:
                                BorderRadius.circular(7.r),
                              ),
                              child: Text(
                                AppLocalizations.translate(
                                  (task['priority'] as String).toLowerCase(),
                                  language,
                                ),
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
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
              ),
            ],
          ),
        );
      },
    );
  }
}