import 'package:fpdt/fpdt.dart';
import 'package:fpdt/riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vouchervault/lib/lib.dart';
import 'package:vouchervault/vouchers/vouchers.dart';

final createVouchersSMProvider = ([VouchersState? initialOverride]) =>
    persistedSMProvider<VouchersState, VouchersContext, String>(
      create: (ref, initial) => StateRTEMachine(
        initialOverride ?? initial ?? VouchersState(IList()),
        VouchersContext(log: ref.watch(vouchersLogProvider)),
      )..evaluate(removeExpired),
      key: 'VouchersBloc',
      fromJson: VouchersState.fromJson,
      toJson: (s) => s.toJson(),
    );

final vouchersSMProvider = createVouchersSMProvider();

final vouchersProvider = Provider(
  (ref) => stateMachineStateProvider(ref, ref.watch(vouchersSMProvider)),
);

final voucherProvider = Provider.autoDispose.family(
  (ref, Option<String> uuid) => ref
      .watch(vouchersProvider)
      .vouchers
      .firstWhereOption((v) => v.uuid == uuid),
);
