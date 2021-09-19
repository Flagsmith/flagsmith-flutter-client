import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);
  void toggle(BuildContext context) {
    if (state == ThemeMode.system) {
      if (Theme.of(context).brightness == Brightness.light) {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.light);
      }
    } else if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }
}
