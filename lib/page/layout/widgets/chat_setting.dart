import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:chatmcp/provider/settings_provider.dart';
import 'package:chatmcp/generated/app_localizations.dart';

class ChatSetting extends StatelessWidget {
  const ChatSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final modelSetting = settingsProvider.modelSetting;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSectionTitle(
                  context,
                  l10n.modelSettings,
                  CupertinoIcons.slider_horizontal_3,
                ),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          Theme.of(context).colorScheme.outline.withAlpha(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSliderWithLabel(
                        context: context,
                        label: l10n.temperature(
                            modelSetting.temperature.toStringAsFixed(2)),
                        value: modelSetting.temperature,
                        min: 0.0,
                        max: 2.0,
                        onChanged: (value) => _updateModelSettings(
                          settingsProvider,
                          temperature: value,
                        ),
                        tooltip: l10n.temperatureTooltip,
                      ),
                      _buildDivider(context),
                      _buildSliderWithLabel(
                        context: context,
                        label: l10n.topP(modelSetting.topP.toStringAsFixed(2)),
                        value: modelSetting.topP,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) => _updateModelSettings(
                          settingsProvider,
                          topP: value,
                        ),
                        tooltip: l10n.topPTooltip,
                      ),
                      _buildDivider(context),
                      _buildNumberInput(
                        context: context,
                        label: l10n.maxTokens,
                        value: modelSetting.maxTokens,
                        onChanged: (value) => _updateModelSettings(
                          settingsProvider,
                          maxTokens: value,
                        ),
                        tooltip: l10n.maxTokensTooltip,
                      ),
                      _buildDivider(context),
                      _buildSliderWithLabel(
                        context: context,
                        label: l10n.frequencyPenalty(
                            modelSetting.frequencyPenalty.toStringAsFixed(2)),
                        value: modelSetting.frequencyPenalty,
                        min: -2.0,
                        max: 2.0,
                        onChanged: (value) => _updateModelSettings(
                          settingsProvider,
                          frequencyPenalty: value,
                        ),
                        tooltip: l10n.frequencyPenaltyTooltip,
                      ),
                      _buildDivider(context),
                      _buildSliderWithLabel(
                        context: context,
                        label: l10n.presencePenalty(
                            modelSetting.presencePenalty.toStringAsFixed(2)),
                        value: modelSetting.presencePenalty,
                        min: -2.0,
                        max: 2.0,
                        onChanged: (value) => _updateModelSettings(
                          settingsProvider,
                          presencePenalty: value,
                        ),
                        tooltip: l10n.presencePenaltyTooltip,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _resetModelSettings(settingsProvider),
                    icon: const Icon(CupertinoIcons.refresh_thin),
                    label: Text('Reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outline.withAlpha(50),
    );
  }

  Widget _buildSliderWithLabel({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    String? tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (tooltip != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tooltip,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
                ),
              ),
            ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required BuildContext context,
    required String label,
    required int? value,
    required ValueChanged<int?> onChanged,
    String? tooltip,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (tooltip != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tooltip,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value?.toString() ?? ''),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: l10n.enterMaxTokens,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(20),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(20),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                onChanged(null);
              } else {
                onChanged(int.tryParse(value));
              }
            },
          ),
        ],
      ),
    );
  }

  void _updateModelSettings(
    SettingsProvider provider, {
    double? temperature,
    int? maxTokens,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
  }) {
    final currentSettings = provider.modelSetting;
    provider.updateModelSettings(
      temperature: temperature != null
          ? _roundToOneDecimal(temperature)
          : currentSettings.temperature,
      maxTokens: maxTokens,
      topP: topP != null ? _roundToOneDecimal(topP) : currentSettings.topP,
      frequencyPenalty: frequencyPenalty != null
          ? _roundToOneDecimal(frequencyPenalty)
          : currentSettings.frequencyPenalty,
      presencePenalty: presencePenalty != null
          ? _roundToOneDecimal(presencePenalty)
          : currentSettings.presencePenalty,
    );
  }

  /// 将double值四舍五入到小数点后一位
  double _roundToOneDecimal(double value) {
    return (value * 10).round() / 10;
  }

  Future<void> _resetModelSettings(SettingsProvider provider) async {
    await provider.resetModelSettings();
  }
}
