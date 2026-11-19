import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/services/secure_storage_service.dart';

/// Fines a player was sending to MobilePay when they left the app.
class PendingMobilePayment extends Equatable {
  const PendingMobilePayment({
    required this.fineBoxId,
    required this.userFineIds,
    required this.amount,
    required this.startedAt,
  });

  final int fineBoxId;
  final List<int> userFineIds;
  final int amount;
  final DateTime startedAt;

  Map<String, dynamic> toJson() => {
        'fineBoxId': fineBoxId,
        'userFineIds': userFineIds,
        'amount': amount,
        'startedAt': startedAt.toIso8601String(),
      };

  static PendingMobilePayment? tryParse(String? raw) {
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return PendingMobilePayment(
        fineBoxId: json['fineBoxId'] as int,
        userFineIds: (json['userFineIds'] as List).cast<int>(),
        amount: json['amount'] as int,
        startedAt: DateTime.parse(json['startedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [fineBoxId, userFineIds, amount, startedAt];
}

class PendingMobilePaymentState extends Equatable {
  const PendingMobilePaymentState({
    this.payment,
    this.awaitingAnswer = false,
    this.saving = false,
    this.saveFailed = false,
    this.confirmedCount = 0,
  });

  /// The payment the player started in MobilePay, if any.
  final PendingMobilePayment? payment;

  /// The player is back in Kopa and should say whether they paid.
  final bool awaitingAnswer;
  final bool saving;
  final bool saveFailed;

  /// Goes up each time a payment is saved, so screens can refresh.
  final int confirmedCount;

  PendingMobilePaymentState copyWith({
    PendingMobilePayment? Function()? payment,
    bool? awaitingAnswer,
    bool? saving,
    bool? saveFailed,
    int? confirmedCount,
  }) {
    return PendingMobilePaymentState(
      payment: payment != null ? payment() : this.payment,
      awaitingAnswer: awaitingAnswer ?? this.awaitingAnswer,
      saving: saving ?? this.saving,
      saveFailed: saveFailed ?? this.saveFailed,
      confirmedCount: confirmedCount ?? this.confirmedCount,
    );
  }

  @override
  List<Object?> get props =>
      [payment, awaitingAnswer, saving, saveFailed, confirmedCount];
}

/// Remembers a MobilePay payment while the player is in MobilePay and asks
/// them whether they paid when they come back to Kopa.
///
/// MobilePay Box has no payment callback, so the player's answer is the only
/// signal. The pending payment is stored on the device, so the question is
/// also asked if the app was closed while the player was in MobilePay.
class PendingMobilePaymentCubit extends Cubit<PendingMobilePaymentState> {
  PendingMobilePaymentCubit({
    Future<String?> Function()? load,
    Future<void> Function(String value)? save,
    Future<void> Function()? clear,
    Future<void> Function(PendingMobilePayment payment)? deposit,
    DateTime Function()? now,
    WidgetsBinding? binding,
  })  : _load = load ?? SecureStorageService.getPendingMobilePayment,
        _save = save ?? SecureStorageService.setPendingMobilePayment,
        _clear = clear ?? SecureStorageService.deletePendingMobilePayment,
        _deposit = deposit ?? _depositToFineBox,
        _now = now ?? DateTime.now,
        super(const PendingMobilePaymentState()) {
    _lifecycle = AppLifecycleListener(
      binding: binding,
      onStateChange: _onLifecycleChange,
    );
  }

  /// Older payments are dropped instead of asked about.
  static const maxAge = Duration(hours: 24);

  final Future<String?> Function() _load;
  final Future<void> Function(String value) _save;
  final Future<void> Function() _clear;
  final Future<void> Function(PendingMobilePayment payment) _deposit;
  final DateTime Function() _now;
  late final AppLifecycleListener _lifecycle;

  /// Whether the app went to the background after the payment started.
  bool _leftApp = false;

  static Future<void> _depositToFineBox(PendingMobilePayment payment) async {
    await FinesRepository.depositAmountToFineBox(
      payment.fineBoxId,
      payment.amount.toString(),
      payment.userFineIds,
    );
  }

  /// Picks up a payment left over from before the app was closed.
  Future<void> restore() async {
    final payment = PendingMobilePayment.tryParse(await _safe<String?>(_load));
    if (payment == null) return;
    if (_now().difference(payment.startedAt) > maxAge) {
      await _safe(_clear);
      return;
    }
    if (state.payment != null) return;
    emit(state.copyWith(payment: () => payment, awaitingAnswer: true));
  }

  /// Call right before MobilePay opens.
  Future<void> start({
    required int fineBoxId,
    required List<int> userFineIds,
    required int amount,
  }) async {
    final payment = PendingMobilePayment(
      fineBoxId: fineBoxId,
      userFineIds: List.unmodifiable(userFineIds),
      amount: amount,
      startedAt: _now(),
    );
    _leftApp = false;
    emit(PendingMobilePaymentState(
      payment: payment,
      confirmedCount: state.confirmedCount,
    ));
    await _safe(() => _save(jsonEncode(payment.toJson())));
  }

  /// Call when MobilePay could not be opened.
  Future<void> cancel() => _reset();

  /// The player said they paid.
  Future<void> confirmPaid() async {
    final payment = state.payment;
    if (payment == null || state.saving) return;
    emit(state.copyWith(awaitingAnswer: false, saving: true, saveFailed: false));
    try {
      await _deposit(payment);
    } catch (_) {
      // Keep the payment so the player is asked again next time.
      emit(state.copyWith(saving: false, saveFailed: true));
      return;
    }
    await _safe(_clear);
    emit(PendingMobilePaymentState(confirmedCount: state.confirmedCount + 1));
  }

  /// The player said they did not pay.
  Future<void> declinePaid() => _reset();

  void _onLifecycleChange(AppLifecycleState lifecycle) {
    if (state.payment == null) return;
    switch (lifecycle) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _leftApp = true;
      case AppLifecycleState.resumed:
        if (_leftApp && !state.awaitingAnswer && !state.saving) {
          _leftApp = false;
          emit(state.copyWith(awaitingAnswer: true, saveFailed: false));
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _reset() async {
    _leftApp = false;
    emit(PendingMobilePaymentState(confirmedCount: state.confirmedCount));
    await _safe(_clear);
  }

  static Future<T?> _safe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() {
    _lifecycle.dispose();
    return super.close();
  }
}
