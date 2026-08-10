import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/repository/feature_flags_repository.dart';

class FeatureFlagsState {
  final AppFeatureFlags featureFlags;

  const FeatureFlagsState({required this.featureFlags});

  bool get updateRequired => featureFlags.updateRequired;
}

class FeatureFlagsCubit extends Cubit<FeatureFlagsState> {
  FeatureFlagsCubit({
    required FeatureFlagsRepository repository,
    required AppFeatureFlags initialFeatureFlags,
  })  : _repository = repository,
        super(FeatureFlagsState(featureFlags: initialFeatureFlags));

  final FeatureFlagsRepository _repository;
  StreamSubscription<AppFeatureFlags>? _subscription;

  void startWatching() {
    if (_subscription != null) return;

    _subscription = _repository.watchFeatureFlags().listen((featureFlags) {
      emit(FeatureFlagsState(featureFlags: featureFlags));
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _repository.close();
    return super.close();
  }
}
