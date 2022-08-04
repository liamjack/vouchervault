import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/task.dart' as T;
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vouchervault/app/app.dart';
import 'package:vouchervault/hooks/hooks.dart';
import 'package:vouchervault/lib/lib.dart';
import 'package:vouchervault/voucher_form/voucher_form.dart';
import 'package:vouchervault/vouchers/vouchers.dart';

part 'voucher_dialog_container.g.dart';

@hcwidget
Widget _voucherDialogContainer(
  BuildContext context,
  WidgetRef ref, {
  required Voucher voucher,
}) {
  // Full brightness unless text barcode
  useFullBrightness(
    routeObserver,
    enabled: voucher.codeType != VoucherCodeType.TEXT,
  );

  // state
  final sm = ref.watch(vouchersSMProvider);
  final v =
      ref.watch(voucherProvider(voucher.uuid)).p(O.getOrElse(() => voucher));

  final onTapBarcode = useCallback(
    () => v.code.p(O.map((code) {
      Clipboard.setData(ClipboardData(text: code));
      Fluttertoast.showToast(msg: 'Copied to clipboard');
    })),
    [v.code],
  );

  final onSpend = useCallback(
    (() => showDialog<String>(
              context: context,
              builder: (context) => const VoucherSpendDialog(),
            ))
        .p(T.map(optionOfString))
        .p(T.map(maybeUpdateBalance(v)))
        .p(T.map(sm.run)),
    [sm, v],
  );

  final onEdit = useCallback(() async {
    final voucher = await Navigator.push<Voucher>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => VoucherFormDialog(initialValue: O.some(v)),
      ),
    );

    O.fromNullable(voucher).p(O.map(update)).p(O.map(sm.run));
  }, [sm, v]);

  final onRemove = useCallback(
    () => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('That you want to remove this voucher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              sm.evaluate(remove(v));
              Navigator.pop(context, true);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    ).then((removed) {
      if (removed != true) return;
      Navigator.pop(context);
    }),
    [sm, v],
  );

  return VoucherDialog(
    voucher: v,
    onTapBarcode: onTapBarcode,
    onEdit: onEdit,
    onClose: () => Navigator.pop(context),
    onRemove: onRemove,
    onSpend: onSpend,
  );
}
