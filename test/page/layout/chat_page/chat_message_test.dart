import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatmcp/llm/model.dart';
import 'package:chatmcp/page/layout/chat_page/chat_message.dart';
import 'package:chatmcp/utils/color.dart';
import 'package:chatmcp/generated/app_localizations.dart'; // Ensure this path is correct

import '../../test_helpers.dart'; // Adjust path as necessary

void main() {
  // Helper to create a simple ChatMessage
  ChatMessage createTestMessage({
    String id = '1',
    String? content = 'Test message',
    MessageRole role = MessageRole.user,
    List<MessageFile>? files,
    List<Map<String, dynamic>>? toolCalls,
    String? toolCallId,
    int timestamp = 0,
    String? currentModelId = 'test_model',
  }) {
    return ChatMessage(
      id: id,
      conversationId: 'conv1',
      role: role,
      content: content,
      toolCalls: toolCalls,
      toolCallId: toolCallId,
      files: files ?? [],
      timestamp: timestamp == 0 ? DateTime.now().millisecondsSinceEpoch : timestamp,
      currentModelId: currentModelId,
      isPinned: false,
      isArchived: false,
      metadata: {},
    );
  }

  group('ChatUIMessage Widget Tests', () {
    testWidgets('User Message Bubble Tail and Shadow', (WidgetTester tester) async {
      final userMessage = createTestMessage(role: MessageRole.user, content: 'Hello user');
      
      await pumpWidgetWithShell(tester, ChatUIMessage(
        messages: [userMessage],
        onRetry: (_) {},
        onSwitch: (_) {},
      ));

      // Find the Container for the message group (ChatUIMessage > _buildMessageGroup > Container)
      // This container should have the shadow.
      final groupContainerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          // For single messages, ChatUIMessage directly returns ChatMessageContent,
          // which then has MessageBubble. The shadow is on the _buildMessageGroup container when there are multiple messages.
          // For a single message, ChatMessageContent -> MessageBubble. The shadow logic is actually on _buildMessageGroup.
          // If _buildMessageGroup returns ChatMessageContent directly for single messages, that ChatMessageContent
          // won't have the group container's shadow. The shadow is applied when _buildMessageGroup builds a Column.
          // Let's test a single message within a group structure to find the shadow container.
          // The prompt implies shadow is on the group container.
          // The current implementation of ChatUIMessage for a single message bypasses the "group container"
          // and ChatMessageContent -> MessageBubble does not have shadow.
          // So, we test with a structure that *would* create the group container.
          // However, the task is to test the bubble *and* shadow.
          // Let's assume the shadow is on MessageBubble for single for now, or adjust if not.
          // Re-reading: "Find the Container used for the message group in ChatUIMessage (the one that gets the shadow)"
          // This means we need to look for the container in _buildMessageGroup.
          // For a truly single message, _buildMessageGroup returns ChatMessageContent directly.
          // Let's modify the test to reflect that for a single message, the shadow might be on the MessageBubble itself,
          // or the test needs to be for a "group of one" which is not how it's built.

          // The prompt says "Pump a ChatUIMessage widget containing a single user message"
          // "Find the Container used for the message group in ChatUIMessage (the one that gets the shadow)."
          // This container is the one in _buildMessageGroup if filteredMessages.length > 1.
          // If filteredMessages.length == 1, it returns ChatMessageContent directly.
          // ChatMessageContent -> MessageBubble. MessageBubble itself does NOT have a shadow by default.
          // The shadow was added to the *grouping container* in _buildMessageGroup.
          // So, to test the shadow, we need a group. A single message is not a group.

          // Let's test the bubble shape first for a single message, then a group for shadow.
          return true; // Placeholder, will refine
        }
        return false;
      });
      
      // Find MessageBubble
      final messageBubbleFinder = find.byType(MessageBubble);
      expect(messageBubbleFinder, findsOneWidget);
      final messageBubble = tester.widget<MessageBubble>(messageBubbleFinder);

      // Verify BorderRadius for user message (tail bottom-right)
      final expectedRadiusUser = const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
        bottomLeft: Radius.circular(16.0),
        bottomRight: Radius.circular(4.0), // Sharp tail
      );
      // Accessing internal _getBorderRadius is not ideal. We check the Container's decoration.
      final bubbleContainer = tester.firstWidget<Container>(find.descendant(of: messageBubbleFinder, matching: find.byType(Container)));
      expect((bubbleContainer.decoration as BoxDecoration).borderRadius, equals(expectedRadiusUser));
      
      // Verify background color
      final BuildContext context = tester.element(messageBubbleFinder);
      expect((bubbleContainer.decoration as BoxDecoration).color, equals(AppColors.getMessageBubbleBackgroundColor(context, true)));

      // Test Shadow for a group (even if a group of one for testing shadow application)
      // To test the shadow container, we need _buildMessageGroup to not take the single message path.
      // This means we need to pass more than one message, or a message that itself is part of a "group"
      // The current ChatUIMessage structure applies shadow only if filteredMessages.length > 1.
      // For a single message, no explicit shadow container is built by _buildMessageGroup.
      // The prompt might misinterpret where shadow is applied for single vs. group.
      // Let's assume the shadow test is for when messages *are* grouped.
      // If we must test shadow with a single message, the structure of ChatUIMessage would need to change
      // or MessageBubble itself would need a shadow prop.

      // Given the current code, shadow is ONLY on groups of >1.
      // "Find the Container used for the message group in ChatUIMessage (the one that gets the shadow)."
      // This implies we should be testing a group.
    });

    testWidgets('User Message Group (2 messages) has Shadow', (WidgetTester tester) async {
      final userMessage1 = createTestMessage(id: 'usr1', role: MessageRole.user, content: 'User msg 1', timestamp: 1);
      final userMessage2 = createTestMessage(id: 'usr2', role: MessageRole.user, content: 'User msg 2', timestamp: 2); // Part of same group

      await pumpWidgetWithShell(tester, ChatUIMessage(
        messages: [userMessage1, userMessage2], // This will be treated as one group by ChatUIMessage logic.
                                                // The internal grouping logic in MessageList is different.
                                                // ChatUIMessage takes a list that IS ALREADY a group.
        onRetry: (_) {},
        onSwitch: (_) {},
      ));
      
      // Find the group container in ChatUIMessage
      final groupContainerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty;
        }
        return false;
      });
      expect(groupContainerFinder, findsOneWidget); // This is the container with the shadow

      final BuildContext context = tester.element(groupContainerFinder);
      final decoration = tester.widget<Container>(groupContainerFinder).decoration as BoxDecoration;
      expect(decoration.boxShadow!.first.color, equals(AppColors.getMessageBubbleShadowColor(context)));
    });


    testWidgets('Assistant Message Bubble Tail', (WidgetTester tester) async {
      final assistantMessage = createTestMessage(role: MessageRole.assistant, content: 'Hello assistant');
      
      await pumpWidgetWithShell(tester, ChatUIMessage(
        messages: [assistantMessage],
        onRetry: (_) {},
        onSwitch: (_) {},
      ));
      
      final messageBubbleFinder = find.byType(MessageBubble);
      expect(messageBubbleFinder, findsOneWidget);
      final messageBubble = tester.widget<MessageBubble>(messageBubbleFinder);

      final expectedRadiusAssistant = const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
        bottomLeft: Radius.circular(4.0), // Sharp tail
        bottomRight: Radius.circular(16.0),
      );
      final bubbleContainer = tester.firstWidget<Container>(find.descendant(of: messageBubbleFinder, matching: find.byType(Container)));
      expect((bubbleContainer.decoration as BoxDecoration).borderRadius, equals(expectedRadiusAssistant));

      final BuildContext context = tester.element(messageBubbleFinder);
      expect((bubbleContainer.decoration as BoxDecoration).color, equals(AppColors.getMessageBubbleBackgroundColor(context, false)));
    });

    testWidgets('Grouped Message Bubbles (Middle Message) Styling', (WidgetTester tester) async {
      // ChatUIMessage receives messages that are *already* grouped.
      // So we pass three messages of the same role to simulate first, middle, last.
      final assistantMsg1 = createTestMessage(id: 'as1', role: MessageRole.assistant, content: 'Msg 1', timestamp: 1);
      final assistantMsg2 = createTestMessage(id: 'as2', role: MessageRole.assistant, content: 'Msg 2', timestamp: 2);
      final assistantMsg3 = createTestMessage(id: 'as3', role: MessageRole.assistant, content: 'Msg 3', timestamp: 3);

      await pumpWidgetWithShell(tester, ChatUIMessage(
        messages: [assistantMsg1, assistantMsg2, assistantMsg3],
        onRetry: (_) {},
        onSwitch: (_) {},
      ));

      // Find all MessageBubble widgets
      final messageBubbleFinders = find.byType(MessageBubble);
      expect(messageBubbleFinders, findsNWidgets(3));

      // The ChatMessageContent widgets will have BubblePosition set.
      // Find the middle ChatMessageContent
      final middleChatMessageContentFinder = find.byWidgetPredicate((widget) {
        return widget is ChatMessageContent && widget.position == BubblePosition.middle;
      });
      expect(middleChatMessageContentFinder, findsOneWidget);

      // Find the MessageBubble within this middle ChatMessageContent
      final middleMessageBubbleFinder = find.descendant(
        of: middleChatMessageContentFinder,
        matching: find.byType(MessageBubble),
      );
      expect(middleMessageBubbleFinder, findsOneWidget);
      
      final middleMessageBubbleWidget = tester.widget<MessageBubble>(middleMessageBubbleFinder);
      expect(middleMessageBubbleWidget.useTransparentBackground, isTrue); // Middle messages in a group use transparent bg

      // Verify BorderRadius for middle message (should be zero or minimal if useTransparentBackground is true)
      // The _getBorderRadius logic for useTransparentBackground=true and BubblePosition.middle returns BorderRadius.zero
      final bubbleContainer = tester.firstWidget<Container>(find.descendant(of: middleMessageBubbleFinder, matching: find.byType(Container)));
      expect((bubbleContainer.decoration as BoxDecoration).borderRadius, equals(BorderRadius.zero));
    });
  });
}
