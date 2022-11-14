import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/providers/test_provider.dart';
import 'package:todo/providers/throw_away_task_provider.dart';
import 'package:todo/screens/categories_screen.dart';
import 'package:todo/screens/category_detail_screen.dart';
import 'package:todo/screens/home_screen.dart';
import 'package:todo/screens/routine_detail_screen.dart';
import 'package:todo/screens/settings_screen.dart';
import 'package:todo/screens/task_detail_screen.dart';
import 'app_colour.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: AppColour.colorCustom,
    //statusBarBrightness: Brightness.light,
    //statusBarIconBrightness: Brightness.dark,
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        title: 'Flutter Demo', // TODO rename/ rebrand
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', 'US'),
          Locale('en', 'GB'),
        ],
        theme: ThemeData(
          primarySwatch: AppColour.colorCustom,
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            backgroundColor: AppColour.colorCustom,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: AppColour.colorCustom,
          ),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.white30),
            labelStyle: TextStyle(color: Colors.white),
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionHandleColor: Colors.white70,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (ctx) => HomeScreen(),
          RoutineDetailScreen.routeName: (context) => RoutineDetailScreen(),
          TaskDetailScreen.routeName: (context) => TaskDetailScreen(),
          SettingsScreen.routeName: (context) => SettingsScreen(),
          CategoriesScreen.routeName: (context) => CategoriesScreen(),
          CategoryDetailScreen.routeName: (context) => CategoryDetailScreen(),
        },
      ),
    );
  }
}
