import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_tracker/shared/cubits/appCubit/app_cubit.dart';
import 'package:task_tracker/shared/cubits/appCubit/app_states.dart';
import 'package:task_tracker/shared/cubits/bloc_observer.dart';
import 'package:task_tracker/shared/networks/local/cache_helper.dart';
import 'package:task_tracker/shared/networks/local/db_helper.dart';
import 'package:task_tracker/shared/styles/styles.dart';
import 'layout/app_layout.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();

  await CacheHelper.init();

  await DbHelper.database;

  bool isDark = CacheHelper.getData(key: 'isDark') ?? false;

  runApp( MyApp(isDark: isDark,));
}

class MyApp extends StatelessWidget {
  final bool isDark;
  const MyApp({super.key, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(create: (context)
        => AppCubit()..changeTheme(fromShared: isDark)..getSavedLanguage()..loadTasks(),),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child)=>BlocBuilder<AppCubit,AppStates>(builder:(context, state) {
          AppCubit appCubit = AppCubit.get(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: appCubit.currentLocale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: appCubit.isDark ? ThemeMode.dark : ThemeMode.light,
            home: AppLayout(),
          );
        }, ),
      ),
    );
  }
}
