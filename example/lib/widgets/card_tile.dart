import 'package:flagsmith/flagsmith.dart';
import 'package:flutter/material.dart';

class CardTileWidget extends StatelessWidget {
  final Flag item;
  const CardTileWidget({Key? key, required this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.feature.name,
            style: Theme.of(context).textTheme.headline5,
          )
        ],
      ),
    );
  }
}
