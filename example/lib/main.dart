import 'package:bullet_train/bullet_train.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'bloc/bt_bloc.dart';
import 'screen.dart';

final GetIt getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<BulletTrainClient>(
      BulletTrainClient(apiKey: 'EBnVjhp7xvkT5oTLq4q7Ny'));

  getIt.registerFactory(
      () => BtBloc(bt: GetIt.instance.get<BulletTrainClient>()));
}

void main() {
  setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 35, 61, 83),
        accentColor: Color(0xff1c9997),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) =>
            getIt<BtBloc>()..add(BtEvent.started())..add(BtEvent.getFeatures()),
        child: BtScreen(title: 'Bullet Train Example'),
      ),
    );
  }
}
