import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_mobile_app/main.dart';

void main() {
  testWidgets('App starts and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RestaurantApp()); // Changed from MyApp

    // Verify that the login screen is shown
    expect(find.text('Login'), findsOneWidget);
  });
}
