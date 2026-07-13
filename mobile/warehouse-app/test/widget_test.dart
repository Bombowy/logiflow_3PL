import 'package:flutter_test/flutter_test.dart';
import 'package:logiflow_warehouse/main.dart';

void main() {
  testWidgets('displays the LogiFlow warehouse welcome screen', (tester) async {
    await tester.pumpWidget(const LogiFlowApp());

    expect(find.text('LogiFlow 3PL'), findsOneWidget);
    expect(find.text('Warehouse Integration Demo'), findsOneWidget);
  });
}
