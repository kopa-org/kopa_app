import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/utils/app_analytics.dart';

/// The user's product analytics choice on this device.
///
/// State is `null` while the stored choice loads.
class AnalyticsPreferenceCubit extends Cubit<bool?> {
  AnalyticsPreferenceCubit({
    Future<bool> Function()? load,
    Future<void> Function(bool enabled)? save,
  })  : _load = load ?? AppAnalytics.isEnabled,
        _save = save ?? AppAnalytics.setEnabled,
        super(null);

  final Future<bool> Function() _load;
  final Future<void> Function(bool enabled) _save;

  Future<void> load() async {
    emit(await _load());
  }

  Future<void> setEnabled(bool enabled) async {
    final previous = state;
    emit(enabled);
    try {
      await _save(enabled);
    } catch (_) {
      emit(previous);
    }
  }
}
