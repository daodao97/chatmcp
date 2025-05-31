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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final modelSetting = settingsProvider.modelSetting;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  context,
                  l10n.modelSettings,
                  CupertinoIcons.slider_horizontal_3,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () => _resetModelSettings(settingsProvider),
                      icon: Icon(
                        CupertinoIcons.refresh_thin,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        'Reset',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (tooltip != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                tooltip,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  height: 1.3,
                ),
              ),
            ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.primary.withOpacity(0.15),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withOpacity(0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          if (tooltip != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                tooltip,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  height: 1.3,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: TextEditingController(text: value?.toString() ?? ''),
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: l10n.enterMaxTokens,
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.normal,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
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
