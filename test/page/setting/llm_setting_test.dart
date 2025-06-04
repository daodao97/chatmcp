import 'package:flutter/material.dart'; // Required for TextEditingController
import 'package:flutter_test/flutter_test.dart';
import 'package:chatmcp/page/setting/llm_setting.dart';
import 'package:chatmcp/provider/settings_provider.dart'; // Required for LLMProviderSetting

// Helper class to check if dispose was called on TextEditingController
class TestTextEditingController extends TextEditingController {
  bool disposeCalled = false;

  @override
  void dispose() {
    disposeCalled = true;
    super.dispose();
  }
}

// Helper class to check if dispose was called on LLMSettingControllers
class TestLLMSettingControllers extends LLMSettingControllers {
  bool disposeCalledInternal = false;
  final TestTextEditingController testKeyController;
  final TestTextEditingController testEndpointController;
  final TestTextEditingController testProviderNameController;

  TestLLMSettingControllers({
    required this.testKeyController,
    required this.testEndpointController,
    required this.testProviderNameController,
    String apiStyleController = 'openai',
    String providerId = '',
    bool custom = false,
    String icon = '',
    List<String>? models,
    List<String>? enabledModels,
    String genTitleModel = '',
    String link = '',
    int priority = 0,
  }) : super(
          keyController: testKeyController,
          endpointController: testEndpointController,
          providerNameController: testProviderNameController,
          apiStyleController: apiStyleController,
          providerId: providerId,
          custom: custom,
          icon: icon,
          models: models,
          enabledModels: enabledModels,
          genTitleModel: genTitleModel,
          link: link,
          priority: priority,
        );

  @override
  void dispose() {
    super.dispose(); // This will call dispose on the TestTextEditingControllers
    disposeCalledInternal = true;
  }
}

void main() {
  // Ensure Flutter bindings are initialized for tests that might use framework features implicitly.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LLMSettingControllers', () {
    test('dispose calls dispose on all internal TextEditingControllers', () {
      final mockKeyController = TestTextEditingController();
      final mockEndpointController = TestTextEditingController();
      final mockProviderNameController = TestTextEditingController();

      final settingControllers = LLMSettingControllers(
        keyController: mockKeyController,
        endpointController: mockEndpointController,
        providerNameController: mockProviderNameController,
        providerId: 'test_id', // required non-nullable
        // other fields can use defaults or dummy values
      );

      settingControllers.dispose();

      expect(mockKeyController.disposeCalled, isTrue, reason: "keyController.dispose should be called");
      expect(mockEndpointController.disposeCalled, isTrue, reason: "endpointController.dispose should be called");
      expect(mockProviderNameController.disposeCalled, isTrue, reason: "providerNameController.dispose should be called");
    });
  });

  group('_KeysSettingsState', () {
    // Due to the private nature of _KeysSettingsState and its methods,
    // direct unit testing of controller disposal during deletion is challenging without
    // significant refactoring of the production code or complex widget tests.

    // The following is a conceptual test.
    // A true test would involve widget testing to simulate UI interactions
    // or refactoring _KeysSettingsState to make its logic more testable.

    test('Conceptual test: removing a controller from _controllers list should lead to its dispose method being called', () {
      // This test illustrates the principle.
      // In a real scenario, we'd need to either:
      // 1. Use widget testing to interact with the UI and trigger deletion.
      // 2. Refactor _KeysSettingsState to allow more direct testing of its internal logic.

      // Setup:
      final keyController1 = TestTextEditingController();
      final endpointController1 = TestTextEditingController();
      final providerNameController1 = TestTextEditingController();
      final controller1 = TestLLMSettingControllers(
        testKeyController: keyController1,
        testEndpointController: endpointController1,
        testProviderNameController: providerNameController1,
        providerId: 'id1',
        custom: true,
      );

      final keyController2 = TestTextEditingController();
      final endpointController2 = TestTextEditingController();
      final providerNameController2 = TestTextEditingController();
      final controller2 = TestLLMSettingControllers(
        testKeyController: keyController2,
        testEndpointController: endpointController2,
        testProviderNameController: providerNameController2,
        providerId: 'id2',
        custom: true,
      );

      final List<LLMSettingControllers> controllersList = [controller1, controller2];
      final List<LLMProviderSetting> configsList = [
        LLMProviderSetting(providerId: 'id1', providerName: 'Test1', custom: true, apiKey: '', apiEndpoint: ''),
        LLMProviderSetting(providerId: 'id2', providerName: 'Test2', custom: true, apiKey: '', apiEndpoint: ''),
      ];

      // Simulate removal (e.g., as would happen in _deleteProvider or the form's delete button)
      final indexToRemove = 0;
      final LLMProviderSetting configToRemove = configsList[indexToRemove]; // Keep it simple for concept

      // --- Start of logic that would be inside _KeysSettingsState ---
      // final index = _llmApiConfigs.indexOf(configToRemove); // In real code
      // if (index != -1 && index < _controllers.length) {
      //    final removedController = _controllers[index];
      //    _llmApiConfigs.removeAt(index);
      //    _controllers.removeAt(index);
      //    removedController.dispose();
      // }
      // --- End of logic ---

      // Direct simulation for this conceptual test:
      if (indexToRemove < controllersList.length) {
        final TestLLMSettingControllers removedController = controllersList.removeAt(indexToRemove) as TestLLMSettingControllers;
        configsList.removeAt(indexToRemove); // Keep lists in sync for the concept
        removedController.dispose(); // Manually call dispose as it's done in production code
      }

      // Verification:
      expect(controller1.disposeCalledInternal, isTrue,
          reason: "Controller1's internal dispose should be called");
      expect(keyController1.disposeCalled, isTrue,
          reason: "Controller1's keyController.dispose should be called");
      expect(endpointController1.disposeCalled, isTrue,
          reason: "Controller1's endpointController.dispose should be called");
      expect(providerNameController1.disposeCalled, isTrue,
          reason: "Controller1's providerNameController.dispose should be called");

      expect(controller2.disposeCalledInternal, isFalse,
          reason: "Controller2's dispose should NOT be called");
      expect(keyController2.disposeCalled, isFalse);
    });

    // A more complete test would require widget testing:
    // testWidgets('Deleting a provider from UI calls dispose on its LLMSettingControllers', (WidgetTester tester) async {
    //   // 1. Setup SettingsProvider mock
    //   // 2. Pump KeysSettings widget within a MaterialApp and with Providers
    //   // 3. Find a delete button for a custom provider (might need to add one first)
    //   // 4. Tap the delete button
    //   // 5. Verify that the LLMSettingControllers instance associated with that provider had its dispose method called.
    //   //    This would likely involve injecting the TestLLMSettingControllers instances when the mock provider
    //   //    loads the settings, and then retrieving that instance to check its `disposeCalledInternal` flag.
    //   expect(true, isTrue, reason: "Widget test would be needed for full verification of _KeysSettingsState");
    // });
  });
}
