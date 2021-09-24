import '../bloc/flag_bloc.dart';
import '../bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'appbar_title.dart';
import 'content_listview.dart';
import 'multi_fab.dart';

/// Sample screen
class FlagsmithSampleScreen extends StatelessWidget {
  // Screen title
  final String title;
  const FlagsmithSampleScreen({Key? key, this.title = ''}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                context.read<ThemeCubit>().toggle(context);
              },
              icon: const Icon(Icons.change_circle_outlined)),
          title: const AppbarTitle(),
          centerTitle: true,
          bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 0,
              ))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: const SafeArea(
            child: Center(child: ContentListView()),
          ),
        ),
      ),
      persistentFooterButtons: [
        TextButton(
            onPressed: () {
              context.read<FlagBloc>().add(RemoveIdentityFlagEvent());
            },
            child: const Text('No user')),
        TextButton(
            onPressed: () {
              context.read<FlagBloc>().add(
                  const ChangeIdentityFlagEvent(
                  identifier: 'test_another_user'));
            },
            child: const Text('Test')),
        TextButton(
            onPressed: () {
              context.read<FlagBloc>().add(const ChangeIdentityFlagEvent(
                  identifier: 'invalid_users_another_user'));
            },
            child: const Text('Another')),
      ],
      floatingActionButton:
          const MultiFab(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
