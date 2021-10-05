import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:persisted_bloc_stream/persisted_bloc_stream.dart';
import 'package:vouchervault/app/app.dart';
import 'package:vouchervault/models/voucher.dart';

void main({IList<Voucher>? vouchers}) async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) =>
      print('${r.loggerName}: ${r.level.name}: ${r.time}: ${r.message}'));

  PersistedBlocStream.storage = await SharedPreferencesStorage.build();

  runApp(VoucherVaultApp(vouchers: vouchers));
}
