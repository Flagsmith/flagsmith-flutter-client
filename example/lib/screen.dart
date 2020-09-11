import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

import 'bloc/bt_bloc.dart';

class BtScreen extends StatelessWidget {
  final String title;
  BtScreen({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BtBloc, BtState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: state.state == LoadingState.isLoding
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () {
                      context.bloc<BtBloc>().add(BtEvent.getFeatures());
                      return;
                    },
                    child: ListView.separated(
                        padding: const EdgeInsets.all(8.0),
                        separatorBuilder: (context, index) => Divider(
                              height: 1,
                              indent: 16,
                            ),
                        itemCount: state.flags.length,
                        itemBuilder: (context, index) {
                          var color = state.flags[index].feature.name == 'color'
                              ? Hexcolor(state.flags[index].stateValue)
                              : Colors.black;

                          return SwitchListTile(
                            title: Text(
                              '${state.flags[index].feature.name} | ${state.flags[index].stateValue}',
                              style: TextStyle(color: color),
                            ),
                            subtitle: Text(
                                '${state.flags[index].enabled ? 'ON' : 'OFF'} ${state.flags[index].toString()}'),
                            value: state.flags[index].enabled,
                            onChanged: null,
                          );
                        }),
                  ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () =>
                  context.bloc<BtBloc>().add(BtEvent.getFeatures()),
              tooltip: 'Fetch',
              icon: Icon(Icons.add),
              label: Text('Fetch'),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        });
  }
}
