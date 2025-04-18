import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/providers/throw_away_task_provider.dart';
import 'package:todo/screens/categories_screen.dart';
import 'package:todo/screens/category_detail_screen.dart';
import 'package:todo/screens/export_json_screen.dart';
import 'package:todo/screens/home_screen.dart';
import 'package:todo/screens/import_json_screen.dart';
import 'package:todo/screens/routine_detail_screen.dart';
import 'package:todo/screens/settings_screen.dart';
import 'package:todo/screens/task_detail_screen.dart';
import 'app_colour.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColour.colorCustom,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => RoutineProvider(tableName: "routines")),
        ChangeNotifierProvider(create: (_) => TaskProvider(tableName: "tasks")),
        ChangeNotifierProvider(
            create: (_) => CategoryProvider(tableName: "categories")),
        ChangeNotifierProvider(
            create: (_) => ThrowAwayTaskProvider(tableName: "dayplantasks"))
      ],
      child: MaterialApp(
        title: 'Sennight',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('en', 'GB'),
        ],
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: AppColour.colorCustom,
          appBarTheme: const AppBarTheme(
            elevation: 0.0,
            backgroundColor: AppColour.colorCustom,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColour.colorCustom,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (ctx) => const HomeScreen(),
          RoutineDetailScreen.routeName: (context) =>
              const RoutineDetailScreen(),
          TaskDetailScreen.routeName: (context) => const TaskDetailScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
          CategoriesScreen.routeName: (context) => const CategoriesScreen(),
          CategoryDetailScreen.routeName: (context) =>
              const CategoryDetailScreen(),
          ExportJsonPage.routeName: (context) => const ExportJsonPage(),
          ImportJsonScreen.routeName: (context) => const ImportJsonScreen(),
        },
      ),
    );
  }
}
