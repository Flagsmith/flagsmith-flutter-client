part of 'flag_bloc.dart';

/// Simple [FlagState] for [FlagBloc]
class FlagState extends Equatable {
  // Loading state of bloc
  final LoadingState loading;
  // Loaded flag list
  final List<Flag> flags;
  final Identity? identity;

  @override
  List<Object> get props => [loading, flags];

  const FlagState(
      {required this.loading, this.flags = const <Flag>[], this.identity});

  FlagState copyWith(
      {LoadingState? loading, List<Flag>? flags, Identity? identity}) {
    return FlagState(
      loading: loading ?? this.loading,
      flags: flags ?? this.flags,
      identity: identity ?? this.identity,
    );
  }

  /// Initial state
  factory FlagState.initial() =>
      const FlagState(loading: LoadingState.isInitial, flags: []);

  bool isEnabled(String flag) {
    final found = flags.firstWhereOrNull(
        (element) => element.feature.name == flag && element.enabled == true);
    return found?.enabled ?? false;
  }
}
