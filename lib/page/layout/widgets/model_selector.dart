import 'package:chatmcp/page/layout/widgets/llm_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatmcp/provider/provider_manager.dart';
import 'package:chatmcp/provider/chat_model_provider.dart';
import 'package:chatmcp/llm/model.dart' as llm_model;
import 'package:chatmcp/utils/color.dart';
import 'package:chatmcp/components/widgets/custom_popup.dart';

class ModelSelector extends StatefulWidget {
  const ModelSelector({super.key});

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  // 缓存future避免重复执行
  List<llm_model.Model> _models = [];

  @override
  void initState() {
    super.initState();
    _updateModels();
    // 添加监听器
    ProviderManager.settingsProvider.addListener(_updateModels);
  }

  @override
  void dispose() {
    // 移除监听器避免内存泄漏
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

// 创建一个通知类来监听弹出窗口的打开状态
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
  // 按 provider 对模型进行分组并根据搜索文本过滤
  Map<String, List<llm_model.Model>> _getFilteredModelsByProvider(
      String searchText) {
    final modelsByProvider = <String, List<llm_model.Model>>{};

    // 筛选匹配搜索文本的模型
    final filteredModels = widget.availableModels.where((model) {
      return searchText.isEmpty ||
          model.label.toLowerCase().contains(searchText) ||
          model.providerId.toLowerCase().contains(searchText);
    }).toList();

    for (var model in filteredModels) {
      modelsByProvider.putIfAbsent(model.providerId, () => []).add(model);
    }

    return modelsByProvider;
  }

  // 构建模型列表
  Widget _buildModelList(String searchText) {
    final modelsByProvider = _getFilteredModelsByProvider(searchText);

    if (modelsByProvider.isEmpty) {
      return const PopupEmptyState(message: 'No results found');
    }

    final List<Widget> items = [];

    modelsByProvider.forEach((provider, models) {
      // 添加分隔线
      if (items.isNotEmpty) {
        items.add(const PopupDivider());
      }

      final firstModel = models.first;

      // 添加提供商标题
      items.add(
        PopupGroupHeader(
          title: firstModel.providerName,
          icon: LlmIcon(icon: firstModel.icon),
        ),
      );

      // 添加该提供商下的所有模型
      for (var model in models) {
        items.add(
          PopupListItem(
            onTap: () {
              widget.onModelSelected(model);
              Navigator.of(context).pop();
            },
            isSelected: widget.isCurrentModel(model),
            padding: const EdgeInsets.fromLTRB(32, 6, 16, 6),
            child: Text(
              model.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.isCurrentModel(model)
                        ? AppColors.getTextButtonColor(context)
                        : AppColors.getThemeTextColor(context),
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

    return SearchablePopup(
      searchHint: 'Search',
      contentBuilder: _buildModelList,
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
