import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';

class LlmSettings extends StatefulWidget {
  const LlmSettings({super.key});

  @override
  State<LlmSettings> createState() => _LlmSettingsState();
}

class _LlmSettingsState extends State<LlmSettings> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _apiEndpointController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _apiEndpointController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.loadSettings();

    final openaiSettings = settings.apiSettings['openai'];
    if (openaiSettings != null) {
      _apiKeyController.text = openaiSettings.apiKey;
      _apiEndpointController.text = openaiSettings.apiEndpoint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OpenAI API Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Please enter your OpenAI API Key',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your OpenAI API Key';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiEndpointController,
              decoration: const InputDecoration(
                labelText: 'API Endpoint',
                hintText: 'https://api.openai.com/v1',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                // if (value == null || value.isEmpty) {
                //   return '请输入 API 地址';
                // }
                // if (!Uri.tryParse(value)!.isAbsolute) {
                //   return '请输入有效的 URL';
                // }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save Settings'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);

      final apiSetting = ApiSetting(
        apiKey: _apiKeyController.text,
        apiEndpoint: _apiEndpointController.text,
      );

      await settings.updateSettings(
        apiSettings: {'openai': apiSetting},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
      }
    }
  }
}
