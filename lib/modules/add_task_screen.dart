import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:task_tracker/shared/compenents/compenents.dart';
import '../shared/cubits/appCubit/app_cubit.dart';
import '../shared/cubits/appCubit/app_states.dart';
import '../shared/localization/app_localizations.dart';
import '../shared/models/task_model.dart';
import '../shared/styles/colors.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int selectedCategoryIndex = 0;
  int selectedPriorityIndex = 0;

  TimeOfDay? selectedTime;
  DateTime? selectedDate;

  final List<String> categories = [
    'Work',
    'Personal',
    'Meeting',
    'Study',
  ];

  final List<String> priorities = [
    'low',
    'medium',
    'high',
  ];

  final List<Color> categoryColors = [
    const Color(0xFFFF5252),
    const Color(0xFFFFB300),
    const Color(0xFF00BFA5),
    const Color(0xFF00ACC1),
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
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
              AppLocalizations.translate(
                'add_task',
                appCubit.language,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(
                start: 15.w,
                end: 15.w,
                bottom: 30.h,
                top: 10.h
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTaskInformation(isDark, appCubit.language),
                SizedBox(height: 20.h),
                buildCategorySection(isDark, appCubit.language),
                SizedBox(height: 20.h),
                buildPrioritySection(isDark, appCubit.language),
                SizedBox(height: 20.h),
                buildDateTimeSection(isDark, appCubit.language),
                SizedBox(height: 25.h),
                defaultButtonWithIcon(
                    onPressed: () => saveTask(appCubit),
                    text: AppLocalizations.translate(
                      'add_task',
                      appCubit.language,
                    ),
                    icon: const Icon(Icons.add_task_rounded,color: Colors.white,),
                    height: 55
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildHeader(bool isDark, String language) {
    return Container(
      width: double.infinity,
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
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(isDark ? 0.2 : 0.3),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(
              Icons.add_task_rounded,
              color: Colors.white,
              size: 25.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.translate(
                    'create_new_task',
                    language,
                  ),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  AppLocalizations.translate(
                    'add_schedule_sub',
                    language,
                  ),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskInformation(bool isDark, String language) {
    return buildSectionCard(
      isDark: isDark,
      title: AppLocalizations.translate(
        'task_information',
        language,
      ),
      icon: Icons.edit_note_rounded,
      child: Column(
        children: [
          buildTextField(
            isDark: isDark,
            controller: titleController,
            label: AppLocalizations.translate(
              'task_title',
              language,
            ),
            hint: AppLocalizations.translate(
              'enter_task_title',
              language,
            ),
            icon: Icons.title_rounded,
          ),
          SizedBox(height: 15.h),
          buildTextField(
            isDark: isDark,
            controller: descriptionController,
            label: AppLocalizations.translate(
              'description',
              language,
            ),
            hint: AppLocalizations.translate(
              'add_description',
              language,
            ),
            icon: Icons.notes_rounded,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.all(15.r),
      decoration: BoxDecoration(
        color: isDark ? lightDarkColor : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? 0.2 : 0.04,
            ),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  icon,
                  size: 18.r,
                  color: mainColor,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF1A1D1E),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }

  Widget buildTextField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: isDark
                ? Colors.grey.shade400
                : Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white
                : const Color(0xFF1A1D1E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            prefixIcon: Icon(
              icon,
              size: 19.r,
              color: mainColor,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.04)
                : const Color(0xFFF7F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(
                color: mainColor,
                width: 1.2,
              ),
            ),
            contentPadding: EdgeInsetsDirectional.all(14.r),
          ),
        ),
      ],
    );
  }

  Widget buildCategorySection(bool isDark, String language) {
    return buildSectionCard(
      isDark: isDark,
      title: AppLocalizations.translate(
        'category',
        language,
      ),
      icon: Icons.category_rounded,
      child: SizedBox(
        height: 40.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (context, index) =>
              SizedBox(width: 9.w),
          itemBuilder: (context, index) {
            final isSelected = selectedCategoryIndex == index;
            final color = categoryColors[index];

            return InkWell(
              onTap: () {
                setState(() {
                  selectedCategoryIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(14.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 15.w,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color
                      : (isDark
                      ? Colors.white.withOpacity(0.04)
                      : const Color(0xFFF7F8FA)),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : Colors.transparent,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 9,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      AppLocalizations.translate(
                        categories[index],
                        language,
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildPrioritySection(bool isDark, String language) {
    return buildSectionCard(
      isDark: isDark,
      title: AppLocalizations.translate(
        'priority',
        language,
      ),
      icon: Icons.flag_rounded,
      child: Row(
        children: [
          for (int index = 0; index < priorities.length; index++) ...[
            Expanded(
              child: buildPriorityItem(
                isDark: isDark,
                language: language,
                index: index,
              ),
            ),
            if (index != priorities.length - 1)
              SizedBox(width: 10.w),
          ],
        ],
      ),
    );
  }

  Widget buildPriorityItem({
    required bool isDark,
    required String language,
    required int index,
  })
  {
    final isSelected = selectedPriorityIndex == index;

    final Color color = index == 0
        ? Colors.grey
        : index == 1
        ? const Color(0xFFFFB300)
        : const Color(0xFFFF5252);

    return InkWell(
      onTap: () {
        setState(() {
          selectedPriorityIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(15.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 45.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.12)
              : (isDark
              ? Colors.white.withOpacity(0.04)
              : const Color(0xFFF7F8FA)),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? color
                : Colors.transparent ,
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.flag_rounded
                  : Icons.flag_outlined,
              size: 16.r,
              color: color,
            ),
            SizedBox(width: 6.w),
            Text(
              AppLocalizations.translate(
                priorities[index],
                language,
              ),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: isSelected
                    ? color
                    : (isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateTimeSection(bool isDark, String language) {
    return buildSectionCard(
      isDark: isDark,
      title: AppLocalizations.translate(
        'date_and_time',
        language,
      ),
      icon: Icons.calendar_month_rounded,
      child: Row(
        children: [
          Expanded(
            child: buildDateItem(isDark, language),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: buildTimeItem(isDark, language),
          ),
        ],
      ),
    );
  }

  Widget buildDateItem(bool isDark, String language) {
    return InkWell(
      onTap: selectDate,
      child: Container(
        padding: EdgeInsetsDirectional.all(15.r),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 16.r,
                color: mainColor,
              ),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.translate(
                      'date',
                      language,
                    ),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    selectedDate == null
                        ? AppLocalizations.translate(
                      'today',
                      language,
                    )
                        : DateFormat('dd MMM yyyy').format(selectedDate!),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF1A1D1E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimeItem(bool isDark, String language) {
    return InkWell(
      onTap: selectTime,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsetsDirectional.all(13.r),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.schedule_rounded,
                size: 17.r,
                color: mainColor,
              ),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.translate(
                      'time',
                      language,
                    ),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    selectedTime == null
                        ? AppLocalizations.translate(
                      'select',
                      language,
                    )
                        : selectedTime!.format(context),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF1A1D1E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveTask(AppCubit appCubit) async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            AppLocalizations.translate(
              'please_enter_title',
              appCubit.language,
            ),
          ),
        ),
      );
      return;
    }

    final date = selectedDate ?? DateTime.now();
    final time = selectedTime ?? TimeOfDay.now();

    final taskDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    await appCubit.addTask(
      TaskModel(
        title: title,
        description: descriptionController.text.trim(),
        category: categories[selectedCategoryIndex],
        priority: priorities[selectedPriorityIndex],
        dueDate: taskDateTime,
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  Future<void> selectDate() async {
    final time = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );

    if (time != null) {
      setState(() {
        selectedDate = time;
      });
    }
  }

}