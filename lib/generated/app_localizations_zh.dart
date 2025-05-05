// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get settings => '设置';

  @override
  String get general => '通用';

  @override
  String get providers => '服务提供商';

  @override
  String get mcpServer => 'MCP 服务器';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get dark => '深色';

  @override
  String get light => '浅色';

  @override
  String get system => '跟随系统';

  @override
  String get languageSettings => '语言设置';

  @override
  String get featureSettings => '功能设置';

  @override
  String get enableArtifacts => '启用人工制品';

  @override
  String get enableArtifactsDescription => '在对话中启用 AI 助手的人工制品，这将使用更多的令牌';

  @override
  String get enableToolUsage => '启用工具使用';

  @override
  String get enableToolUsageDescription => '在对话中启用工具的使用，这将使用更多的令牌';

  @override
  String get themeSettings => '主题设置';

  @override
  String get lightTheme => '浅色主题';

  @override
  String get darkTheme => '深色主题';

  @override
  String get followSystem => '跟随系统';

  @override
  String get showAvatar => '显示头像';

  @override
  String get showAssistantAvatar => '显示助手头像';

  @override
  String get showAssistantAvatarDescription => '在对话中显示 AI 助手的头像';

  @override
  String get showUserAvatar => '显示用户头像';

  @override
  String get showUserAvatarDescription => '在对话中显示用户的头像';

  @override
  String get systemPrompt => '系统提示词';

  @override
  String get systemPromptDescription => '这是与 AI 助手对话的系统提示词，用于设置助手的行为和风格';

  @override
  String get llmKey => 'LLM 密钥';

  @override
  String get toolKey => '工具密钥';

  @override
  String get saveSettings => '保存设置';

  @override
  String get apiKey => 'API 密钥';

  @override
  String enterApiKey(Object provider) {
    return '请输入您的 $provider API 密钥';
  }

  @override
  String get apiKeyValidation => 'API 密钥必须至少包含 10 个字符';

  @override
  String get apiEndpoint => 'API 端点';

  @override
  String get enterApiEndpoint => '请输入 API 端点 URL';

  @override
  String get platformNotSupported => '当前平台不支持 MCP Server';

  @override
  String get mcpServerDesktopOnly => 'MCP Server 仅支持桌面端（Windows、macOS、Linux）';

  @override
  String get searchServer => '搜索服务器...';

  @override
  String get noServerConfigs => '未找到服务器配置';

  @override
  String get addProvider => '添加服务商';

  @override
  String get refresh => '刷新';

  @override
  String get install => '安装';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get command => '命令 或 服务地址';

  @override
  String get arguments => '参数';

  @override
  String get environmentVariables => '环境变量';

  @override
  String get serverName => '服务器名称';

  @override
  String get commandExample => '例如：npx、uvx、https://mcpserver.com';

  @override
  String get argumentsExample => '参数之间用空格分隔，例如：-m mcp.server';

  @override
  String get envVarsFormat => '每行一个，格式：KEY=VALUE';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteServer(Object name) {
    return '您确定要删除服务器 \"$name\" 吗？';
  }

  @override
  String get error => '错误';

  @override
  String commandNotExist(Object command, Object path) {
    return '命令 \"$command\" 不存在，请先安装\n\n当前 PATH：\n$path';
  }

  @override
  String get all => '全部';

  @override
  String get installed => '已安装';

  @override
  String get modelSettings => '模型设置';

  @override
  String temperature(Object value) {
    return '采样温度: $value';
  }

  @override
  String get temperatureTooltip => '采样温度控制输出的随机性：\n• 0.0：适合代码生成和数学解题\n• 1.0：适合数据抽取和分析\n• 1.3：适合通用对话和翻译\n• 1.5：适合创意写作和诗歌创作';

  @override
  String topP(Object value) {
    return '核采样: $value';
  }

  @override
  String get topPTooltip => 'Top P（核采样）是temperature的替代方案。模型只考虑累积概率超过P的标记。建议不要同时修改temperature和top_p。';

  @override
  String get maxTokens => '最大令牌数';

  @override
  String get maxTokensTooltip => '生成的最大令牌数。一个令牌大约等于4个字符。较长的对话需要更多的令牌。';

  @override
  String frequencyPenalty(Object value) {
    return '频率惩罚: $value';
  }

  @override
  String get frequencyPenaltyTooltip => '频率惩罚参数。正值会根据新标记在文本中的现有频率来惩罚它们，降低模型逐字重复同样内容的可能性。';

  @override
  String presencePenalty(Object value) {
    return '存在惩罚: $value';
  }

  @override
  String get presencePenaltyTooltip => '存在惩罚参数。正值会根据新标记是否出现在文本中来惩罚它们，增加模型谈论新主题的可能性。';

  @override
  String get enterMaxTokens => '输入最大令牌数';

  @override
  String get share => '分享';

  @override
  String get modelConfig => '模型配置';

  @override
  String get debug => '调试';

  @override
  String get webSearchTest => '网页搜索测试';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get last7Days => '前 7 天';

  @override
  String get last30Days => '前 30 天';

  @override
  String get earlier => '更早';

  @override
  String get confirmDeleteSelected => '确定要删除选中的对话吗？';

  @override
  String get ok => '确定';

  @override
  String get askMeAnything => '问我任何问题...';

  @override
  String get uploadFiles => '上传文件';

  @override
  String get welcomeMessage => '今天我能帮您什么？';

  @override
  String get copy => '复制';

  @override
  String get copied => '已复制到剪贴板';

  @override
  String get retry => '重试';

  @override
  String get brokenImage => '图片损坏';

  @override
  String toolCall(Object name) {
    return '调用 $name';
  }

  @override
  String toolResult(Object name) {
    return '调用 $name 结果';
  }

  @override
  String get selectModel => '选择模型';

  @override
  String get close => '关闭';

  @override
  String get selectFromGallery => '从图库选择';

  @override
  String get selectFile => '选择文件';

  @override
  String get uploadFile => '上传文件';

  @override
  String get openBrowser => '打开浏览器';

  @override
  String get codeCopiedToClipboard => '代码已复制到剪贴板';

  @override
  String get thinking => '思考中';

  @override
  String get thinkingEnd => '思考结束';

  @override
  String get tool => '工具';

  @override
  String get userCancelledToolCall => '工具执行失败';

  @override
  String get code => '代码';

  @override
  String get preview => '预览';

  @override
  String get loadContentFailed => '加载内容失败，请重试';

  @override
  String get openingBrowser => 'Opening browser';

  @override
  String get functionCallAuth => '工具调用授权';

  @override
  String get allowFunctionExecution => '是否允许执行以下工具:';

  @override
  String parameters(Object params) {
    return '参数: $params';
  }

  @override
  String get allow => '允许';

  @override
  String get loadDiagramFailed => '加载图表失败，请重试';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get chinese => '中文';

  @override
  String get functionRunning => '正在执行工具...';

  @override
  String get thinkingProcess => '思考中';

  @override
  String get thinkingProcessWithDuration => '思考中, 用时';

  @override
  String get thinkingEndWithDuration => '思考完成，用时';

  @override
  String get thinkingEndComplete => '思考完成';

  @override
  String seconds(Object seconds) {
    return '$seconds秒';
  }

  @override
  String get fieldRequired => '此字段为必填项';

  @override
  String get autoApprove => '自动批准';

  @override
  String get verify => '验证密钥';

  @override
  String get howToGet => '如何获取';

  @override
  String get modelList => '模型列表';

  @override
  String get enableModels => '启用模型';

  @override
  String get disableAllModels => '禁用所有模型';

  @override
  String get saveSuccess => '设置保存成功';

  @override
  String get genTitleModel => '标题生成';

  @override
  String get serverNameTooLong => '服务名称长度不能超过 50 个字符';

  @override
  String get confirm => 'Confirm';

  @override
  String get providerName => 'Provider Name';

  @override
  String get apiStyle => 'API Style';

  @override
  String get enterProviderName => 'Enter provider name';

  @override
  String get providerNameRequired => 'Provider name is required';

  @override
  String get addModel => 'Add Model';

  @override
  String get modelName => 'Model Name';

  @override
  String get enterModelName => 'Enter model name';

  @override
  String get noApiConfigs => 'No API configurations available';

  @override
  String get add => 'Add';

  @override
  String get fetch => 'Fetch';

  @override
  String get on => 'ON';

  @override
  String get off => 'OFF';

  @override
  String get apiUrl => 'API URL';

  @override
  String get selectApiStyle => 'Please select API style';

  @override
  String get serverType => '服务类型';

  @override
  String get reset => '重置';

  @override
  String get start => '启动';

  @override
  String get stop => '停止';

  @override
  String newVersionFound(Object version) {
    return '发现新版本 $version';
  }

  @override
  String get newVersionAvailable => '发现新版本';

  @override
  String get updateNow => '立即更新';

  @override
  String get updateLater => '稍后更新';

  @override
  String get ignoreThisVersion => '忽略此版本';

  @override
  String get releaseNotes => '更新内容：';

  @override
  String get openUrlFailed => '无法打开链接';

  @override
  String get checkingForUpdates => '正在检查更新...';

  @override
  String get checkUpdate => '检查更新';
}
