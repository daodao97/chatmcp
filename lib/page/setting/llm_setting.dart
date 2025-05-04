import 'package:chatmcp/components/widgets/base.dart';
import 'package:chatmcp/llm/llm_factory.dart';
import 'package:chatmcp/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../provider/settings_provider.dart';
import '../../provider/provider_manager.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:chatmcp/page/layout/widgets/llm_icon.dart';

class LLMSettingControllers {
  TextEditingController keyController;
  TextEditingController endpointController;
  String apiStyleController;
  TextEditingController providerNameController;
  List<String> models = [];
  List<String> enabledModels = [];
  String providerId;
  bool custom = false;
  String icon = '';
  String genTitleModel = '';
  LLMSettingControllers({
    required this.keyController,
    required this.endpointController,
    this.apiStyleController = 'openai',
    required this.providerNameController,
    this.providerId = '',
    this.custom = false,
    this.icon = '',
    List<String>? models,
    List<String>? enabledModels,
    this.genTitleModel = '',
  }) {
    this.models = models ?? [];
    this.enabledModels = enabledModels ?? [];
  }

  void dispose() {
    keyController.dispose();
    endpointController.dispose();
    providerNameController.dispose();
  }
}

class KeysSettings extends StatefulWidget {
  const KeysSettings({super.key});

  @override
  State<KeysSettings> createState() => _KeysSettingsState();
}

class _KeysSettingsState extends State<KeysSettings> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _selectedProvider = 0;
  bool _hasChanges = false;
  bool _obscureText = true; // 添加密码可见性状态

  final List<LLMSettingControllers> _controllers = [];

  // 记录每个卡片的展开状态
  final Map<int, bool> _expandedState = {};

  final List<LLMProviderSetting> _llmApiConfigs = [];

  void _addModelsWithoutDuplicates(
      LLMSettingControllers controllers, List<String> newModels) {
    for (var model in newModels) {
      if (!controllers.models.contains(model)) {
        controllers.models.add(model);
      }
    }

    if (controllers.enabledModels.isEmpty) {
      controllers.enabledModels.addAll(newModels);
    } else {
      for (var model in newModels) {
        if (!controllers.enabledModels.contains(model)) {
          controllers.enabledModels.add(model);
        }
      }
    }

    controllers.enabledModels.sort((a, b) =>
        controllers.models.indexOf(a) - controllers.models.indexOf(b));
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final apiSettings = await settings.loadSettings();

    setState(() {
      _llmApiConfigs.clear();
      _controllers.clear();
    });

    // 添加所有加载的设置
    for (var apiSetting in apiSettings) {
      setState(() {
        _llmApiConfigs.add(apiSetting);
        // 为每个配置添加一个控制器
        _controllers.add(LLMSettingControllers(
          keyController: TextEditingController(text: apiSetting.apiKey),
          endpointController:
              TextEditingController(text: apiSetting.apiEndpoint),
          apiStyleController: apiSetting.apiStyle ?? 'openai',
          providerNameController:
              TextEditingController(text: apiSetting.providerName ?? ''),
          providerId: apiSetting.providerId ?? '',
          custom: apiSetting.custom,
          models: apiSetting.models ?? [],
          enabledModels: apiSetting.enabledModels ?? [],
          icon: apiSetting.icon,
          genTitleModel: apiSetting.genTitleModel ?? '',
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            onChanged: () {
              if (!_hasChanges) {
                setState(() {
                  _hasChanges = true;
                });
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return isMobile ? _buildMobileLayout() : _buildDesktopLayout();
              },
            ),
          ),
        ),
      ),
    );
  }

  // 构建移动端布局
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // 配置卡片列表
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 4),
            itemCount: _llmApiConfigs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildProviderConfigCard(index),
          ),
        ),
        const SizedBox(height: 12),
        // 底部按钮区域
        Column(
          children: [
            // 保存按钮
            _buildSaveButton(),
            const SizedBox(height: 12),
            // 添加服务器按钮
            _buildAddServerButton(),
          ],
        ),
      ],
    );
  }

  // 构建提供商配置卡片
  Widget _buildProviderConfigCard(int index) {
    final config = _llmApiConfigs[index];
    final controllers = _controllers[index];

    // 初始化展开状态，默认不展开
    _expandedState[index] ??= false;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片头部（点击可折叠）
          InkWell(
            onTap: () {
              setState(() {
                _expandedState[index] = !(_expandedState[index] ?? false);
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildProviderCardHeader(config, controllers),
                  ),
                  Icon(
                    _expandedState[index] ?? false
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    size: 18,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
                ],
              ),
            ),
          ),
          // 展开的配置内容
          if (_expandedState[index] ?? false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: _buildProviderConfigForm(index, showTitle: false),
            ),
        ],
      ),
    );
  }

  // 构建提供商卡片头部
  Widget _buildProviderCardHeader(
      LLMProviderSetting config, LLMSettingControllers controllers) {
    return Row(
      children: [
        LlmIcon(icon: config.icon),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            config.providerName ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (config.custom)
          IconButton(
            icon: const Icon(CupertinoIcons.delete, size: 18),
            color: Colors.red,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _deleteProvider(config),
          ),
      ],
    );
  }

  // 构建保存按钮
  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: _isLoading || !_hasChanges ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: _hasChanges
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          foregroundColor: _hasChanges
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _hasChanges ? 0 : 0,
          padding: EdgeInsets.zero,
        ),
        child: _isLoading
            ? const CupertinoActivityIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.checkmark_circle,
                    size: 18,
                    color: _hasChanges
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  CText(text: l10n.saveSettings),
                ],
              ),
      ),
    );
  }

  // 构建添加服务器按钮
  Widget _buildAddServerButton() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        icon: Icon(
          CupertinoIcons.add_circled,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        label: Text(l10n.addProvider),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _showAddProviderDialog(),
      ),
    );
  }

  // 删除提供商的方法
  void _deleteProvider(LLMProviderSetting config) {
    setState(() {
      final index = _llmApiConfigs.indexOf(config);
      if (index != -1) {
        _llmApiConfigs.removeAt(index);
        _controllers.removeAt(index);
        if (_selectedProvider >= _llmApiConfigs.length) {
          _selectedProvider = _llmApiConfigs.length - 1;
        }
        _hasChanges = true;
      }
    });
  }

  // 构建桌面端布局
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧提供商列表
        SizedBox(
          width: 180,
          child: _buildProviderList(),
        ),
        const SizedBox(width: 12),
        // 右侧配置表单
        Expanded(
          child: _buildDesktopConfigSection(),
        ),
      ],
    );
  }

  // 构建提供商列表
  Widget _buildProviderList() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              // itemExtent: 48.0,
              itemCount: _llmApiConfigs.length,
              itemBuilder: (context, index) {
                final config = _llmApiConfigs[index];
                return _buildProviderListTile(index, config);
              },
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.outline.withAlpha(26),
            height: 1,
          ),
          _buildAddServerListTile(),
        ],
      ),
    );
  }

  // 构建添加服务器列表项
  Widget _buildAddServerListTile() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 40,
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Icon(
              CupertinoIcons.add_circled,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.addProvider,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        onTap: () => _showAddProviderDialog(),
      ),
    );
  }

  // 构建桌面端配置区域
  Widget _buildDesktopConfigSection() {
    return Column(
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withAlpha(26),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _buildProviderConfigForm(_selectedProvider),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSaveButton(),
      ],
    );
  }

  Future<void> _showAddProviderDialog() async {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController providerController =
            TextEditingController();
        return AlertDialog(
          title: Text(l10n.addProvider),
          content: TextField(
            controller: providerController,
            decoration: InputDecoration(
              hintText: l10n.providerName,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final providerName = providerController.text.trim();
                if (providerName.isNotEmpty) {
                  setState(() {
                    String providerId = Uuid().v4();
                    _llmApiConfigs.add(LLMProviderSetting(
                      providerName: providerName,
                      providerId: providerId,
                      apiKey: '',
                      apiEndpoint: '',
                      apiStyle: 'openai',
                      custom: true,
                      models: [],
                      enabledModels: [],
                      icon: '',
                    ));
                    _controllers.add(LLMSettingControllers(
                      keyController: TextEditingController(),
                      endpointController: TextEditingController(),
                      providerNameController:
                          TextEditingController(text: providerName),
                      providerId: providerId,
                      custom: true,
                      models: [],
                      enabledModels: [],
                      icon: '',
                      genTitleModel: '',
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddModelDialog() async {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController modelController = TextEditingController();
        return AlertDialog(
          title: Text(l10n.addModel),
          content: TextField(
            controller: modelController,
            decoration: InputDecoration(
              hintText: l10n.enterModelName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final modelName = modelController.text.trim();
                if (modelName.isNotEmpty) {
                  setState(() {
                    if (_controllers.isNotEmpty) {
                      // 将模型添加到当前选中的提供商
                      final controller = _controllers[_selectedProvider];
                      if (!controller.models.contains(modelName)) {
                        controller.models.add(modelName);
                        controller.enabledModels.add(modelName);
                        _hasChanges = true;
                      }
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProviderListTile(int index, LLMProviderSetting config) {
    final isSelected = _selectedProvider == index;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(31),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      leading: LlmIcon(icon: config.icon),
      title: Text(
        config.providerName ?? '',
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedProvider = index;
        });
      },
    );
  }

  Widget _buildProviderConfigForm(int index, {bool showTitle = true}) {
    // 安全检查：确保索引有效且数组不为空
    if (_llmApiConfigs.isEmpty ||
        _controllers.isEmpty ||
        index < 0 ||
        index >= _llmApiConfigs.length ||
        index >= _controllers.length) {
      // 返回一个空白界面或提示信息
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Text(
          l10n.noApiConfigs,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    final config = _llmApiConfigs[index];
    final controllers = _controllers[index];
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 提供商标题
          if (showTitle) ...[
            Row(
              children: [
                LlmIcon(icon: config.icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    config.providerName ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (config.custom)
                  IconButton(
                    icon: const Icon(CupertinoIcons.delete, size: 18),
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _llmApiConfigs.removeAt(_selectedProvider);
                        _controllers.removeAt(_selectedProvider);
                        if (_selectedProvider >= _llmApiConfigs.length) {
                          _selectedProvider = _llmApiConfigs.length - 1;
                        }
                        _hasChanges = true;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Provider Name
          Text(
            l10n.providerName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controllers.providerNameController,
            decoration: InputDecoration(
              hintText: l10n.enterProviderName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.providerNameRequired;
              }
              if (value.length > 50) {
                return l10n.serverNameTooLong;
              }
              return null;
            },
            maxLength: 50,
            buildCounter: (context,
                {required currentLength, required isFocused, maxLength}) {
              return null; // 隐藏字符计数器
            },
          ),
          const SizedBox(height: 12),

          // API 风格
          if (config.custom) ...[
            Text(
              l10n.apiStyle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: controllers.apiStyleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withAlpha(51),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withAlpha(51),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              isDense: true,
              icon: Icon(
                CupertinoIcons.chevron_down,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              items: [
                DropdownMenuItem(
                  value: 'openai',
                  child: Text(
                    'OpenAI',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'claude',
                  child: Text(
                    'Claude',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'gemini',
                  child: Text(
                    'Gemini',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    controllers.apiStyleController = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.selectApiStyle;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],

          // API URL
          Text(
            l10n.apiUrl,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controllers.endpointController,
            decoration: InputDecoration(
              hintText: l10n.enterApiEndpoint,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // API Key
          Text(
            'API Key',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controllers.keyController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: l10n.enterApiKey(config.providerName ?? ''),
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 10) {
                return l10n.apiKeyValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${l10n.modelList} (${controllers.models.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Spacer(),
              if (kIsDesktop) ...[
                // choose gen title model
                const Gap(size: 12),
                _buildGenTitleModel(controllers),
              ],
              // add custom model
              OutlinedButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 14),
                label: Text(
                  l10n.add,
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 30),
                ),
                onPressed: () {
                  _showAddModelDialog();
                },
              ),
              const SizedBox(width: 8),
              // fetch models
              OutlinedButton.icon(
                icon: const Icon(CupertinoIcons.checkmark_seal, size: 14),
                label: Text(
                  l10n.fetch,
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 30),
                ),
                onPressed: () async {
                  var provider =
                      LLMFactoryHelper.providerMap[controllers.providerId];

                  provider ??=
                      LLMProvider.values.byName(controllers.apiStyleController);

                  final llm = LLMFactory.create(provider,
                      apiKey: controllers.keyController!.text,
                      baseUrl: controllers.endpointController!.text);

                  final models = await llm.models();
                  setState(() {
                    _addModelsWithoutDuplicates(controllers, models);
                    // 设置变更标志
                    _hasChanges = true;
                  });
                },
              ),
              const Gap(size: 8),
              // reset models
              OutlinedButton.icon(
                icon:
                    const Icon(CupertinoIcons.arrow_counterclockwise, size: 14),
                label: Text(l10n.reset, style: const TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 30),
                ),
                onPressed: () async {
                  var provider =
                      LLMFactoryHelper.providerMap[controllers.providerId];

                  provider ??=
                      LLMProvider.values.byName(controllers.apiStyleController);

                  final llm = LLMFactory.create(provider,
                      apiKey: controllers.keyController!.text,
                      baseUrl: controllers.endpointController!.text);

                  final models = await llm.models();
                  setState(() {
                    controllers.models.clear();
                    controllers.enabledModels.clear();
                    _hasChanges = true;

                    _addModelsWithoutDuplicates(controllers, models);
                    // 设置变更标志
                    _hasChanges = true;
                  });
                },
              ),
            ],
          ),

          // 模型列表

          const SizedBox(height: 12),

          if (!kIsDesktop) ...[
            const SizedBox(height: 12),
            _buildGenTitleModel(controllers),
            const SizedBox(height: 12),
          ],

          // 模型列表，直接显示所有模型
          ...controllers.models.map((model) => _buildModelListItem(
              model, controllers.enabledModels.contains(model))),
          const SizedBox(height: 8), // 底部留一些空间
        ],
      ),
    );
  }

  Widget _buildGenTitleModel(LLMSettingControllers controllers) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        width: kIsDesktop ? 180 : double.infinity,
        height: kIsDesktop ? null : 40,
        margin: const EdgeInsets.only(right: 8),
        child: DropdownButtonFormField<String>(
          value: controllers.enabledModels.contains(controllers.genTitleModel)
              ? controllers.genTitleModel
              : (controllers.enabledModels.isNotEmpty
                  ? controllers.enabledModels.first
                  : null),
          decoration: InputDecoration(
            labelText: l10n.genTitleModel,
            labelStyle: TextStyle(fontSize: 12),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withAlpha(51),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withAlpha(51),
              ),
            ),
            isDense: true,
          ),
          icon: Icon(
            CupertinoIcons.chevron_down,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          style: TextStyle(fontSize: 12),
          isExpanded: true,
          items: controllers.enabledModels
              .map((model) => DropdownMenuItem(
                    value: model,
                    child: Text(
                      model,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                controllers.genTitleModel = value;
                _hasChanges = true;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildModelListItem(String modelName, bool isEnabled) {
    if (_selectedProvider < 0 || _selectedProvider >= _controllers.length) {
      return const SizedBox(); // 防止索引错误
    }

    final controllers = _controllers[_selectedProvider];
    final l10n = AppLocalizations.of(context)!;
    // 检查模型是否在启用列表中
    bool modelEnabled = controllers.enabledModels.contains(modelName);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              modelName,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // delete model
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(CupertinoIcons.delete, size: 14),
              color: Colors.red,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  // 从两个列表中删除模型
                  controllers.models.remove(modelName);
                  controllers.enabledModels.remove(modelName);
                  // 设置变更标志
                  _hasChanges = true;
                });
              },
            ),
          ),
          SizedBox(
            width: 50,
            child: FlutterSwitch(
              width: 50.0,
              height: 24.0,
              value: modelEnabled,
              onToggle: (val) {
                setState(() {
                  // 更新模型启用状态
                  if (val) {
                    // 启用模型
                    if (!controllers.enabledModels.contains(modelName)) {
                      controllers.enabledModels.add(modelName);
                      // 确保enabledModels按照models中的顺序排序
                      controllers.enabledModels.sort((a, b) =>
                          controllers.models.indexOf(a) -
                          controllers.models.indexOf(b));
                    }
                  } else {
                    // 禁用模型
                    controllers.enabledModels.remove(modelName);
                  }
                  // 设置变更标志
                  _hasChanges = true;
                });
              },
              toggleSize: 18.0,
              activeColor: Colors.blue,
              inactiveColor: Colors.grey[300]!,
              activeToggleColor: Colors.white,
              inactiveToggleColor: Colors.grey[500]!,
              showOnOff: true,
              activeText: l10n.on,
              inactiveText: l10n.off,
              valueFontSize: 9.0,
              activeTextColor: Colors.white,
              inactiveTextColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final settings = ProviderManager.settingsProvider;

        await settings.updateApiSettings(
            apiSettings: _controllers
                .map((e) => LLMProviderSetting(
                      providerId: e.providerId,
                      providerName: e.providerNameController.text,
                      apiKey: e.keyController.text,
                      apiEndpoint: e.endpointController.text,
                      apiStyle: e.apiStyleController,
                      custom: e.custom,
                      models: e.models,
                      enabledModels: e.enabledModels,
                      icon: e.icon,
                      genTitleModel: e.genTitleModel,
                    ))
                .toList());

        // 重置变更状态
        if (mounted) {
          setState(() {
            _hasChanges = false;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.saveSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
