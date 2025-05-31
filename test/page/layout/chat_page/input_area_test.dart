import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatmcp/page/layout/chat_page/input_area.dart';
import 'package:chatmcp/utils/color.dart';
import 'package:provider/provider.dart'; // If InputArea uses Provider directly, though unlikely for these props
import 'package:chatmcp/provider/provider_manager.dart'; // For McpTools, might need mocking if not handled by shell

import '../../test_helpers.dart'; // Adjust path as necessary

// Mock McpServerProvider for McpTools if it's deeply integrated and not easily bypassed
// For now, pumpWidgetWithShell should provide SettingsProvider.
// McpTools has a FutureBuilder for ProviderManager.mcpServerProvider.installedServersCount.
// This might require specific mocking for ProviderManager if not covered.
// For simplicity, we'll assume McpTools doesn't break the InputArea test for now,
// or its UI is simple enough not to interfere with finding TextField/SendButton.


void main() {
  group('InputArea Widget Tests', () {
    testWidgets('Input Field Border Radius', (WidgetTester tester) async {
      await pumpWidgetWithShell(tester, InputArea(
        isComposing: false,
        disabled: false,
        onTextChanged: (_) {},
        onSubmitted: (_) {},
      ));

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      final textField = tester.widget<TextField>(textFieldFinder);
      expect(textField.decoration, isNotNull);
      expect(textField.decoration!.border, isA<OutlineInputBorder>());

      // Check enabledBorder specifically as that's what's visible by default
      final enabledBorder = textField.decoration!.enabledBorder as OutlineInputBorder?;
      expect(enabledBorder, isNotNull);
      expect(enabledBorder!.borderRadius, BorderRadius.circular(24.0));

      // Check focusedBorder as well for consistency
      final focusedBorder = textField.decoration!.focusedBorder as OutlineInputBorder?;
      expect(focusedBorder, isNotNull);
      expect(focusedBorder!.borderRadius, BorderRadius.circular(24.0));
    });

    testWidgets('Send Button Icon Change and Animation Presence', (WidgetTester tester) async {
      // Need to use a stateful wrapper to manage the text controller for this test effectively
      // or call tester.enterText and pump.

      String currentText = "";
      SubmitData? submittedData;

      await pumpWidgetWithShell(tester, InputArea(
        isComposing: currentText.isNotEmpty,
        disabled: false,
        onTextChanged: (text) {
          currentText = text;
        },
        onSubmitted: (data) {
          submittedData = data;
        },
      ));

      // Find the AnimatedSwitcher
      final animatedSwitcherFinder = find.byType(AnimatedSwitcher);
      expect(animatedSwitcherFinder, findsOneWidget);

      // Initially, text is empty, send button should be the 'disabled' looking one
      // The AnimatedSwitcher switches between two InkIcon widgets based on textController.text.trim().isEmpty
      var sendButtonFinder = find.byWidgetPredicate(
        (widget) => widget is InkIcon && widget.icon == Icons.send && widget.onTap == null
      );
      expect(sendButtonFinder, findsOneWidget, reason: "Finds disabled send button initially");

      InkIcon sendButton = tester.widget<InkIcon>(sendButtonFinder);
      final BuildContext context = tester.element(sendButtonFinder);
      expect(sendButton.iconColor, equals(AppColors.getInputAreaIconColor(context)), reason: "Initial send button color is for disabled state");

      // Enter text into the TextField
      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, 'Hello');
      // The InputArea's internal textController listener calls setState, so pump should rebuild.
      await tester.pump();

      // After entering text, the send button should be the 'enabled' one
      sendButtonFinder = find.byWidgetPredicate(
        (widget) => widget is InkIcon && widget.icon == Icons.send && widget.onTap != null
      );
      expect(sendButtonFinder, findsOneWidget, reason: "Finds enabled send button after text entry");

      sendButton = tester.widget<InkIcon>(sendButtonFinder);
      // Re-fetch context as widget tree might have changed
      final BuildContext enabledContext = tester.element(sendButtonFinder);
      expect(sendButton.iconColor, equals(Theme.of(enabledContext).primaryColor), reason: "Send button color changes to primaryColor when enabled");

      // Tap the send button
      await tester.tap(sendButtonFinder);
      await tester.pumpAndSettle(); // Process animations and state changes

      // Verify onSubmitted was called
      expect(submittedData, isNotNull);
      expect(submittedData!.text, equals('Hello'));

      // After submission, text should be empty again, and button disabled
      // The _afterSubmitted clears the controller, which should trigger listener & rebuild
      sendButtonFinder = find.byWidgetPredicate(
        (widget) => widget is InkIcon && widget.icon == Icons.send && widget.onTap == null
      );
      expect(sendButtonFinder, findsOneWidget, reason: "Finds disabled send button after submission");
    });
  });
}
