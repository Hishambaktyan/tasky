import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../modules/home_screen.dart';
import '../../../modules/settings_screen.dart';
import '../../../modules/statistics_screen.dart';
import '../../../modules/tasks_screen.dart';
import '../../models/task_model.dart';
import '../../networks/local/cache_helper.dart';
import '../../networks/local/db_helper.dart';
import '../../styles/colors.dart';
import 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitThemeState()) ;

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    TasksScreen(),
    StatisticsScreen(),
    SettingsScreen()
  ];

  bool isDark = false;

  void changeIndex(int value) {
    currentIndex = value;
    emit(ChangeNavBarState());
  }

  void changeTheme({bool? fromShared}) {
    if (fromShared != null) {
      isDark = fromShared;
    } else {
      isDark = !isDark;
    }

    CacheHelper.saveData(key: 'isDark', value: isDark);

    emit(ChangeThemeState());
  }

  Locale currentLocale = const Locale('en');

  String get language => currentLocale.languageCode;

  void changeLanguage(String languageCode) {
    currentLocale = Locale(languageCode);

    CacheHelper.saveData(
      key: 'languageCode',
      value: languageCode,
    );

    emit(ChangeLanguageState());
  }

  void getSavedLanguage() {
    final languageCode = CacheHelper.getData(key: 'languageCode');

    if (languageCode != null) {
      currentLocale = Locale(languageCode);
    }
  }

  List<TaskModel> tasks = [];

  Future<void> loadTasks() async {
    tasks = await DbHelper.getAll();
    emit(TasksChangedState());
  }

  Future<void> addTask(TaskModel t) async {
    await DbHelper.insert(t);
    await loadTasks();
  }

  Future<void> toggleTask(TaskModel t) async {
    await DbHelper.update(TaskModel(
      id: t.id,
      title: t.title,
      description: t.description,
      category: t.category,
      priority: t.priority,
      dueDate: t.dueDate,
      isCompleted: !t.isCompleted,
      completedAt: t.isCompleted ? null : DateTime.now(),
    ));
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await DbHelper.delete(id);
    await loadTasks();
  }

  List<TaskModel> tasksOn(DateTime day) => tasks
      .where((t) =>
  t.dueDate.year == day.year &&
      t.dueDate.month == day.month &&
      t.dueDate.day == day.day)
      .toList();

  static Map<String, dynamic> toCard(TaskModel t) => {
    'model': t,
    'title': t.title,
    'category': t.category,
    'time': DateFormat('hh:mm a').format(t.dueDate),
    'date': DateFormat('dd MMM').format(t.dueDate),
    'priority': t.priority,
    'isCompleted': t.isCompleted,
    'color': categoryColorOf(t.category),
  };

  List<TaskModel> tasksInPeriod(int index) {
    final now = DateTime.now();
    late DateTime start;
    late DateTime end;
    if (index == 0) {
      start = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      end = DateTime(start.year, start.month, start.day + 7);
    } else if (index == 1) {
      start = DateTime(now.year, now.month);
      end = DateTime(now.year, now.month + 1);
    } else {
      start = DateTime(now.year);
      end = DateTime(now.year + 1);
    }
    return tasks
        .where((t) => !t.dueDate.isBefore(start) && t.dueDate.isBefore(end))
        .toList();
  }

  List<Map<String, dynamic>> weeklyData() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final end = DateTime(start.year, start.month, start.day + 7);

    const dayKeys = [
      'mon_short',
      'tue_short',
      'wed_short',
      'thu_short',
      'fri_short',
      'sat_short',
      'sun_short'
    ];

    final counts = List<int>.filled(7, 0);
    for (final t in tasks) {
      final d = t.completedAt;
      if (!t.isCompleted || d == null) continue;
      if (!d.isBefore(start) && d.isBefore(end)) counts[d.weekday - 1]++;
    }
    final maxCount = counts.fold<int>(0, (m, c) => c > m ? c : m);
    return List.generate(
      7,
          (i) => {
        'dayKey': dayKeys[i],
        'value': maxCount == 0 ? 0.0 : counts[i] / maxCount,
        'tasks': counts[i],
      },
    );
  }

  List<Map<String, dynamic>> categoryData(int periodIndex) {
    const names = ['Work', 'Personal', 'Meeting', 'Study'];
    final list = tasksInPeriod(periodIndex);
    return names
        .map((n) => {
      'name': n,
      'count': list.where((t) => t.category.toLowerCase() == n.toLowerCase()).length,
      'color': categoryColorOf(n),
    })
        .toList();
  }

  Set<DateTime> get _completedDays => tasks
      .where((t) => t.isCompleted && t.completedAt != null)
      .map((t) => DateTime(
      t.completedAt!.year, t.completedAt!.month, t.completedAt!.day))
      .toSet();

  int get currentStreak {
    final days = _completedDays;
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (!days.contains(day)) day = DateTime(day.year, day.month, day.day - 1);
    var count = 0;
    while (days.contains(day)) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }

  int get bestStreak {
    final sorted = _completedDays.toList()..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final d in sorted) {
      if (prev != null && DateTime(prev.year, prev.month, prev.day + 1) == d) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

}

