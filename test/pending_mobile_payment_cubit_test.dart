import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/pending_mobile_payment_cubit.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  late String? stored;
  late List<PendingMobilePayment> deposits;
  late bool depositFails;
  late DateTime now;

  PendingMobilePaymentCubit build() => PendingMobilePaymentCubit(
        load: () async => stored,
        save: (value) async => stored = value,
        clear: () async => stored = null,
        deposit: (payment) async {
          if (depositFails) throw Exception('offline');
          deposits.add(payment);
        },
        now: () => now,
        binding: binding,
      );

  void lifecycle(AppLifecycleState state) =>
      binding.handleAppLifecycleStateChanged(state);

  void leaveAndReturn() {
    lifecycle(AppLifecycleState.inactive);
    lifecycle(AppLifecycleState.hidden);
    lifecycle(AppLifecycleState.paused);
    lifecycle(AppLifecycleState.hidden);
    lifecycle(AppLifecycleState.inactive);
    lifecycle(AppLifecycleState.resumed);
  }

  setUp(() {
    stored = null;
    deposits = [];
    depositFails = false;
    now = DateTime(2026, 11, 18, 12);
    lifecycle(AppLifecycleState.resumed);
  });

  Future<PendingMobilePaymentCubit> started() async {
    final cubit = build();
    await cubit.start(fineBoxId: 3, userFineIds: [7, 8], amount: 50);
    return cubit;
  }

  test('asks when the player returns from MobilePay', () async {
    final cubit = await started();
    expect(cubit.state.awaitingAnswer, isFalse);
    expect(stored, isNotNull);

    leaveAndReturn();
    expect(cubit.state.awaitingAnswer, isTrue);
    expect(cubit.state.payment?.amount, 50);
    await cubit.close();
  });

  test('does not ask after a brief interruption without leaving', () async {
    final cubit = await started();
    lifecycle(AppLifecycleState.inactive);
    lifecycle(AppLifecycleState.resumed);
    expect(cubit.state.awaitingAnswer, isFalse);
    await cubit.close();
  });

  test('saying yes deposits the fines and clears the payment', () async {
    final cubit = await started();
    leaveAndReturn();
    await cubit.confirmPaid();

    expect(deposits.single.userFineIds, [7, 8]);
    expect(cubit.state.payment, isNull);
    expect(cubit.state.confirmedCount, 1);
    expect(stored, isNull);
    await cubit.close();
  });

  test('saying no clears the payment without depositing', () async {
    final cubit = await started();
    leaveAndReturn();
    await cubit.declinePaid();

    expect(deposits, isEmpty);
    expect(cubit.state.payment, isNull);
    expect(stored, isNull);
    await cubit.close();
  });

  test('a failed save keeps the payment and asks again next return', () async {
    depositFails = true;
    final cubit = await started();
    leaveAndReturn();
    await cubit.confirmPaid();

    expect(cubit.state.saveFailed, isTrue);
    expect(cubit.state.payment, isNotNull);
    expect(stored, isNotNull);

    leaveAndReturn();
    expect(cubit.state.awaitingAnswer, isTrue);
    await cubit.close();
  });

  test('asks on launch about a payment left from before the app closed',
      () async {
    final first = await started();
    await first.close();

    final cubit = build();
    await cubit.restore();
    expect(cubit.state.awaitingAnswer, isTrue);
    expect(cubit.state.payment?.userFineIds, [7, 8]);
    await cubit.close();
  });

  test('drops a stored payment older than a day', () async {
    final first = await started();
    await first.close();
    now = now.add(const Duration(hours: 25));

    final cubit = build();
    await cubit.restore();
    expect(cubit.state.payment, isNull);
    expect(stored, isNull);
    await cubit.close();
  });

  test('cancel forgets a payment when MobilePay did not open', () async {
    final cubit = await started();
    await cubit.cancel();
    leaveAndReturn();
    expect(cubit.state.awaitingAnswer, isFalse);
    expect(stored, isNull);
    await cubit.close();
  });
}
