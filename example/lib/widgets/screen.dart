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
  FlagsmithSampleScreen({Key? key, this.title = ''}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                context.read<ThemeCubit>().toggle(context);
              },
              icon: Icon(Icons.change_circle_outlined)),
          title: AppbarTitle(title: title),
          centerTitle: true,
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: const Divider(
                height: 1,
                thickness: 0,
              ))),
      body: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: const SafeArea(
          child: Center(child: ContentListView()),
        ),
      ),
      persistentFooterButtons: [
        TextButton(
            onPressed: () {
              context.read<FlagBloc>().add(RemoveIdentityFlagEvent());
            },
            child: Text('No user')),
        TextButton(
            onPressed: () {
              context.read<FlagBloc>().add(
                  ChangeIdentityFlagEvent(identifier: 'test_another_user'));
            },
            child: Text('test_another_user')),
        TextButton(
            onPressed: () {
              context.read<FlagBloc>().add(ChangeIdentityFlagEvent(
                  identifier: 'invalid_users_another_user'));
            },
            child: Text('invalid_users_another_user')),
      ],
      floatingActionButton:
          const MultiFab(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
