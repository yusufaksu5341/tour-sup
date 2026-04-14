import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tour_sup/main.dart';

void main() {
  testWidgets('TourSup app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TourSupApp()));
    expect(find.text('TourSup'), findsWidgets);
  });
}
