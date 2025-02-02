import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/reader_task_either.dart' as RTE;
import 'package:fpdt/task_either.dart' as TE;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vouchervault/voucher_form/voucher_form.dart';

typedef BarcodeOp<A> = ReaderTaskEither<MlContext, MlError, A>;

BarcodeOp<List<Barcode>> scan(InputImage image) => TE.tryCatchK(
      (c) => c.barcodeScanner.processImage(image),
      (err, stackTrace) => MlError.mlkitError(op: 'scan', err: err),
    );

BarcodeOp<RecognizedText> ocr(InputImage image) => TE.tryCatchK(
      (c) => c.textRecognizer.processImage(image),
      (err, stackTrace) => MlError.mlkitError(op: 'ocr', err: err),
    );

BarcodeOp<List<EntityAnnotation>> extractEntities(
  String text, {
  List<EntityType> filter = const [],
}) =>
    TE.tryCatchK(
      (c) => c.entityExtractor.annotateText(text, entityTypesFilter: filter),
      (err, stackTrace) => MlError.mlkitError(op: 'extractEntities', err: err),
    );

BarcodeOp<BarcodeResult> extractAll(
  InputImage image, {
  bool embellish = false,
}) =>
    RTE.Do(($, c) async {
      final results = await $(scan(image));

      final result = await $(results.firstOption
          .chain(O.map((b) => BarcodeResult(barcode: b)))
          .chain(RTE.fromOption(() => const MlError.barcodeNotFound())));

      if (embellish) {
        return $(_embellishResult(image: image, result: result));
      }

      return result;
    });

BarcodeOp<BarcodeResult> extractAllFromFile(bool embellish) => pickInputImage
    .p(TE.mapLeft((e) => MlError.pickerError(e)))
    .p(RTE.fromTaskEither)
    .p(RTE.flatMap((i) => extractAll(i, embellish: embellish)));

BarcodeOp<BarcodeResult> _embellishResult({
  required InputImage image,
  required BarcodeResult result,
}) =>
    RTE.Do(($, c) async {
      final rt = await $(ocr(image));

      final annotations = await $(extractEntities(
        rt.text,
        filter: [EntityType.money, EntityType.dateTime],
      ));

      return result.copyWith(
        merchant: extractMerchant(rt),
        balance: extractBalance(annotations),
        expires: extractExpires(rt, annotations),
      );
    });
