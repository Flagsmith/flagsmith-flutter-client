import '../di.dart';
import 'package:flagsmith/flagsmith.dart';

import '../bloc/flag_bloc.dart';
import 'package:flutter/material.dart';

class AppbarTitle extends StatelessWidget {
  const AppbarTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getIt.get<FlagsmithClient>().stream(testFeature),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Text('error');
              }
              if (snapshot.hasData) {
                var flag = snapshot.data as Flag;
                return flag.enabled == true
                    ? Image.asset(
                        'res/hero.png',
                        height: 24,
                        fit: BoxFit.contain,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      )
                    : Text(
                        'Flagsmith',
                        style: Theme.of(context).textTheme.headline6,
                      );
              }
              return const SizedBox.shrink();
          }
        });
  }
}
