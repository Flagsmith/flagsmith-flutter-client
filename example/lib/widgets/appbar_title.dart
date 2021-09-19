import '../bloc/flag_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart';

class AppbarTitle extends StatelessWidget {
  const AppbarTitle({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlagBloc, FlagState>(
      builder: (context, state) {
        return state.isEnabled(testFeature)
            ? TitleRow(
                title: title,
              )
            : Text(
                '$title/false',
                style: Theme.of(context).textTheme.headline5,
              );
      },
    );
  }
}

class TitleRow extends StatelessWidget {
  const TitleRow({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'res/hero.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          '$title/true',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
}
