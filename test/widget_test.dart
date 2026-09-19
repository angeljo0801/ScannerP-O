import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_po/main.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const ScannerPOApp());
    expect(find.text('Scanner P&O'), findsWidgets);
  });
}
