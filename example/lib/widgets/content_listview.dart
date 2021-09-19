import '../bloc/flag_bloc.dart';
import '../enum/loading_state.dart';
import 'package:flagsmith/flagsmith.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentListView extends StatelessWidget {
  const ContentListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FlagBloc>().add(FetchFlagEvent());
        return null;
      },
      child: BlocBuilder<FlagBloc, FlagState>(
        builder: (context, state) {
          if (state.loading == LoadingState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            separatorBuilder: (context, index) => divider,
            itemCount: state.flags.length,
            itemBuilder: (context, index) {
              var item = state.flags[index];
              return ContentListViewRow(
                key: ValueKey(item.hashCode),
                item: item,
              );
            },
          );
        },
      ),
    );
  }
}

const divider = Divider(
  height: 1,
  indent: 16,
);

class ContentListViewRow extends StatelessWidget {
  const ContentListViewRow({Key? key, required this.item}) : super(key: key);
  final Flag item;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
        title: Text(item.feature.description ?? item.feature.name),
        subtitle: Text(
            'feature: ${item.feature.name}  \nstateValue: ${item.stateValue} initialValue: ${item.feature.initialValue}'),
        value: item.enabled ?? false,
        onChanged: (bool value) {});
  }
}
