import 'di.dart';
import 'widgets/multi_fab.dart';
import 'package:flagsmith/flagsmith.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bloc/flag_bloc.dart';
import 'bloc/theme_cubit.dart';
import 'widgets/screen.dart';


const String testFeature = 'show_title_logo';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupPrefs();
  runApp(FlagsmithSampleApp());
}

ThemeData lightTheme(BuildContext context) {
  var theme = ThemeData.from(
    colorScheme: ColorScheme.light(
      primary: Color(0xff5d60cc),
      primaryVariant: Color(0xff5d60cc),
      secondary: Color(0xFFBFA6E9),
      secondaryVariant: Color(0xFF9D88C0),
    ),
    textTheme: GoogleFonts.varelaRoundTextTheme(
      ThemeData.light().textTheme,
    ),
  );
  return theme.copyWith(
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: TextStyle(
        color: Colors.red,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      actionsIconTheme: IconThemeData(color: Colors.black87),
      iconTheme: IconThemeData(color: Colors.black87),
    ),
  );
}

ThemeData darkTheme(BuildContext context) {
  var theme = ThemeData.from(
    colorScheme: ColorScheme.dark(
      primary: Color(0xff5d60cc),
      primaryVariant: Color(0xff5d60cc),
      secondary: Color(0xFFBFA6E9),
      secondaryVariant: Color(0xFF9D88C0),
      surface: Color(0xFF1a1c26),
      background: Color(0xFF1a1c26),
    ),
    textTheme: GoogleFonts.varelaRoundTextTheme(
      ThemeData.dark().textTheme,
    ),
  );
  return theme.copyWith(
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: TextStyle(
        color: Colors.red,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      actionsIconTheme: IconThemeData(color: Colors.white70),
      iconTheme: IconThemeData(color: Colors.white70),
    ),
  );
}

/// Simple [FlagsmithSampleApp]
class FlagsmithSampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Flagsmith Example',
            theme: lightTheme(context),
            darkTheme: darkTheme(context),
            themeMode: state,
            home: FlagsmithSampleScreen(title: 'Flagsmith Example'),
            builder: (context, child) {
              return BlocProvider(
                  create: (context) =>
                      getIt<FlagBloc>()
                    ..add(PersonalizeFlagEvent()),
                  child: child);
            },
          );
        },
      ),
    );
  }
}
