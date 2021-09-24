part of 'flag_bloc.dart';

/// Simple [FlagEvent] enum for [FlagBloc]
abstract class FlagEvent extends Equatable {
  const FlagEvent();

  @override
  List<Object> get props => [];
}

/// Notifies bloc to fetch flags from API
class InitFlagEvent extends FlagEvent {}

/// set stream listeners after fetch data
class RegisterFlagEvent extends FlagEvent {}

/// Notifies bloc to fetch flags from API
class FetchFlagEvent extends FlagEvent {}

// Notifies bloc to update user traits
class PersonalizeFlagEvent extends FlagEvent {}

// reload from storage
class ReloadFlagEvent extends FlagEvent {}

// toggle feature
class ToggleFlagEvent extends FlagEvent {}

// Change identity for reloading of a feature flags from api
class ChangeIdentityFlagEvent extends FlagEvent {
  const ChangeIdentityFlagEvent({required this.identifier});
  final String identifier;

  @override
  List<Object> get props => [identifier];
}

// Remove identity for reloading of a feature flags from api
class RemoveIdentityFlagEvent extends FlagEvent {}
