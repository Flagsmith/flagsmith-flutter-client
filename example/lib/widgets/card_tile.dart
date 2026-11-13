import 'package:flagsmith/flagsmith.dart';
// Deprecated for package:material_ui since Flutter 3.47, which this example
// does not require yet.
// ignore: deprecated_member_use
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
            style: Theme.of(context).textTheme.headlineSmall,
          )
        ],
      ),
    );
  }
}
