import 'package:chatmcp/page/layout/widgets/llm_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatmcp/provider/provider_manager.dart';
import 'package:chatmcp/provider/chat_model_provider.dart';
import 'package:chatmcp/llm/model.dart' as llm_model;
import 'package:flutter_popup/flutter_popup.dart';
import 'package:chatmcp/utils/color.dart';

class ModelSelector extends StatefulWidget {
  const ModelSelector({super.key});

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  // Cache future to avoid repeated execution
  List<llm_model.Model> _models = [];

  @override
  void initState() {
    super.initState();
    _updateModels();
    // Add listener
    ProviderManager.settingsProvider.addListener(_updateModels);
  }

  @override
  void dispose() {
    // Remove listener to avoid memory leaks
    ProviderManager.settingsProvider.removeListener(_updateModels);
    super.dispose();
  }

  void _updateModels() {
    setState(() {
      _models = ProviderManager.settingsProvider.availableModels;
    });
  }

  bool isCurrentModel(llm_model.Model model) {
    return model.name == ProviderManager.chatModelProvider.currentModel.name &&
        model.providerId ==
            ProviderManager.chatModelProvider.currentModel.providerId;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatModelProvider>(
      builder: (context, chatModelProvider, child) {
        return ModelSelectorPopup(
          availableModels: _models,
          isCurrentModel: isCurrentModel,
          onModelSelected: (model) {
            ProviderManager.chatModelProvider.currentModel = model;
          },
        );
      },
    );
  }
}

// Create a notification class to listen to the open status of the popup window
class PopupNotification extends Notification {
  final bool opened;
  PopupNotification(this.opened);
}

class ModelSelectorPopup extends StatefulWidget {
  final List<llm_model.Model> availableModels;
  final bool Function(llm_model.Model) isCurrentModel;
  final void Function(llm_model.Model) onModelSelected;

  const ModelSelectorPopup({
    super.key,
    required this.availableModels,
    required this.isCurrentModel,
    required this.onModelSelected,
  });

  @override
  State<ModelSelectorPopup> createState() => _ModelSelectorPopupState();
}

class _ModelSelectorPopupState extends State<ModelSelectorPopup> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Group models by provider and filter by search text
  Map<String, List<llm_model.Model>> _getFilteredModelsByProvider() {
    final modelsByProvider = <String, List<llm_model.Model>>{};

    // Filter models matching the search text
    final filteredModels = widget.availableModels.where((model) {
      return _searchText.isEmpty ||
          model.label.toLowerCase().contains(_searchText) ||
          model.providerId.toLowerCase().contains(_searchText);
    }).toList();

    for (var model in filteredModels) {
      modelsByProvider.putIfAbsent(model.providerId, () => []).add(model);
    }

    return modelsByProvider;
  }

  // Build model list
  Widget _buildModelList() {
    final modelsByProvider = _getFilteredModelsByProvider();

    if (modelsByProvider.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'No results found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.getInactiveTextColor(context),
                ),
          ),
        ),
      );
    }

    final List<Widget> items = [];

    modelsByProvider.forEach((provider, models) {
      // Add a divider
      if (items.isNotEmpty) {
        items.add(Divider(
          height: 1,
          indent: 8,
          endIndent: 8,
          color: AppColors.getCodePreviewBorderColor(context),
        ));
      }

      final firstModel = models.first;

      // Add provider title
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
          child: Row(
            children: [
              LlmIcon(icon: firstModel.icon),
              const SizedBox(width: 8),
              Text(
                firstModel.providerName,
                style: TextStyle(
                  color: AppColors.getThemeTextColor(context),
                ),
              ),
            ],
          ),
        ),
      );

      // Add all models under this provider
      for (var model in models) {
        items.add(
          InkWell(
            onTap: () {
              widget.onModelSelected(model);
              // Clear the search box content
              _searchController.clear();
              _searchText = '';
              // Close the popup
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 6, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      model.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.isCurrentModel(model)
                                ? AppColors.getTextButtonColor(context)
                                : AppColors.getThemeTextColor(context),
                          ),
                    ),
                  ),
                  if (widget.isCurrentModel(model))
                    Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.getTextButtonColor(context),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    });

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentModel = widget.availableModels.firstWhere(
      (model) => widget.isCurrentModel(model),
      orElse: () => llm_model.Model(
        name: '',
        label: 'Loading...',
        providerId: '',
        icon: '',
        providerName: '',
        apiStyle: '',
      ),
    );

    return CustomPopup(
      showArrow: true,
      arrowColor: AppColors.getSidebarBackgroundColor(context),
      backgroundColor: AppColors.getSidebarBackgroundColor(context),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter popupSetState) {
          return Container(
            constraints: BoxConstraints(
              maxWidth: 280,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search box
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                  child: TextField(
                    controller: _searchController,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.getThemeTextColor(context),
                        ),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.getInactiveTextColor(context),
                              ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 16,
                        color: AppColors.getInactiveTextColor(context),
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.getSidebarBackgroundColor(context),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                    ),
                    onChanged: (value) {
                      popupSetState(() {
                        _searchText = value.toLowerCase();
                      });
                    },
                  ),
                ),
                // Model list
                Flexible(
                  child: _buildModelList(),
                ),
              ],
            ),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Row(
                children: [
                  LlmIcon(icon: currentModel.icon),
                  const SizedBox(width: 4),
                  Text(
                    currentModel.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.getThemeTextColor(context),
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 18,
              color: AppColors.getInactiveTextColor(context),
            ),
          ],
        ),
      ),
    );
  }
}
