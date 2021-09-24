import '../bloc/flag_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiFab extends StatelessWidget {
  const MultiFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          mini: true,
          onPressed: () => context.read<FlagBloc>().add(ToggleFlagEvent()),
          child: const Icon(Icons.image),
        ),
        const SizedBox(
          height: 8,
        ),
        FloatingActionButton.extended(
          onPressed: () => context.read<FlagBloc>().add(FetchFlagEvent()),
          tooltip: 'Fetch',
          icon: const Icon(Icons.assignment_returned_outlined),
          label: const Text('Fetch'),
        ),
      ],
    );
  }
}
