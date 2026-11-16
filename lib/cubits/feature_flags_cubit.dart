import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/repository/feature_flags_repository.dart';

class FeatureFlagsState extends Equatable {
  final AppFeatureFlags featureFlags;

  const FeatureFlagsState({required this.featureFlags});

  bool get updateRequired => featureFlags.updateRequired;
  bool get maintenanceMode => featureFlags.maintenanceMode;

  @override
  List<Object?> get props => [featureFlags];
}

class FeatureFlagsCubit extends Cubit<FeatureFlagsState> {
  FeatureFlagsCubit({
    required FeatureFlagsRepository repository,
    required AppFeatureFlags initialFeatureFlags,
  })  : _repository = repository,
        super(FeatureFlagsState(featureFlags: initialFeatureFlags));

  final FeatureFlagsRepository _repository;
  StreamSubscription<AppFeatureFlags>? _subscription;
  bool _hasScope = false;
  Object? _scope;

  void startWatching() {
    if (_subscription != null || isClosed) return;

    _subscription = _repository.watchFeatureFlags().listen((featureFlags) {
      if (!isClosed) emit(FeatureFlagsState(featureFlags: featureFlags));
    });
  }

  /// Flags are team-scoped on the server, which resolves the team from the
  /// auth token when the stream connects. Call this whenever the signed-in
  /// user or team may have changed; it reconnects when the scope differs.
  Future<void> updateScope(Object? scope) async {
    if (_hasScope && scope == _scope) return;

    final isInitialScope = !_hasScope;
    _hasScope = true;
    _scope = scope;
    // The first scope is the one the bootstrap fetch and the initial stream
    // connection already used.
    if (isInitialScope && _subscription != null) return;

    await _subscription?.cancel();
    _subscription = null;
    startWatching();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _repository.close();
    return super.close();
  }
}
