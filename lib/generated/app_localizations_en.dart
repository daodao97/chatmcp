// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get providers => 'Providers';

  @override
  String get mcpServer => 'MCP Server';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get system => 'System';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get featureSettings => 'Feature Settings';

  @override
  String get enableArtifacts => 'Enable Artifacts';

  @override
  String get enableArtifactsDescription => 'Enable the artifacts of the AI assistant in the conversation, will use more tokens';

  @override
  String get enableToolUsage => 'Enable Tool Usage';

  @override
  String get enableToolUsageDescription => 'Enable the usage of tools in the conversation, will use more tokens';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get followSystem => 'Follow System';

  @override
  String get showAvatar => 'Show Avatar';

  @override
  String get showAssistantAvatar => 'Show Assistant Avatar';

  @override
  String get showAssistantAvatarDescription => 'Show the avatar of the AI assistant in the conversation';

  @override
  String get showUserAvatar => 'Show User Avatar';

  @override
  String get showUserAvatarDescription => 'Show the avatar of the user in the conversation';

  @override
  String get systemPrompt => 'System Prompt';

  @override
  String get systemPromptDescription => 'This is the system prompt for the conversation with the AI assistant, used to set the behavior and style of the assistant';

  @override
  String get llmKey => 'LLM Key';

  @override
  String get toolKey => 'Tool Key';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get apiKey => 'API Key';

  @override
  String enterApiKey(Object provider) {
    return 'Enter your $provider API Key';
  }

  @override
  String get apiKeyValidation => 'API Key must be at least 10 characters';

  @override
  String get apiEndpoint => 'API Endpoint';

  @override
  String get enterApiEndpoint => 'Enter API endpoint URL';

  @override
  String get platformNotSupported => 'Current platform does not support MCP Server';

  @override
  String get mcpServerDesktopOnly => 'MCP Server only supports desktop platforms (Windows, macOS, Linux)';

  @override
  String get searchServer => 'Search server...';

  @override
  String get noServerConfigs => 'No server configurations found';

  @override
  String get addProvider => 'Add Provider';

  @override
  String get refresh => 'Refresh';

  @override
  String get install => 'Install';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get command => 'Command Or Sever Url';

  @override
  String get arguments => 'Arguments';

  @override
  String get environmentVariables => 'Environment Variables';

  @override
  String get serverName => 'Server Name';

  @override
  String get commandExample => 'For example: npx, uvx, https://mcpserver.com';

  @override
  String get argumentsExample => 'Separate arguments with spaces, for example: -m mcp.server';

  @override
  String get envVarsFormat => 'One per line, format: KEY=VALUE';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteServer(Object name) {
    return 'Are you sure you want to delete server \"$name\" ?';
  }

  @override
  String get error => 'Error';

  @override
  String commandNotExist(Object command, Object path) {
    return 'Command \"$command\" does not exist, please install it first\n\nCurrent PATH:\n$path';
  }

  @override
  String get all => 'All';

  @override
  String get installed => 'Installed';

  @override
  String get modelSettings => 'Model Settings';

  @override
  String temperature(Object value) {
    return 'Temperature: $value';
  }

  @override
  String get temperatureTooltip => 'Sampling temperature controls the randomness of output:\n• 0.0: Suitable for code generation and math problems\n• 1.0: Suitable for data extraction and analysis\n• 1.3: Suitable for general conversation and translation\n• 1.5: Suitable for creative writing and poetry';

  @override
  String topP(Object value) {
    return 'Top P: $value';
  }

  @override
  String get topPTooltip => 'Top P (nucleus sampling) is an alternative to temperature. The model only considers tokens whose cumulative probability exceeds P. It is recommended not to modify both temperature and top_p at the same time.';

  @override
  String get maxTokens => 'Max Tokens';

  @override
  String get maxTokensTooltip => 'Maximum number of tokens to generate. One token is approximately equal to 4 characters. Longer conversations require more tokens.';

  @override
  String frequencyPenalty(Object value) {
    return 'Frequency Penalty: $value';
  }

  @override
  String get frequencyPenaltyTooltip => 'Frequency penalty parameter. Positive values penalize new tokens based on their existing frequency in the text, decreasing the model\'s likelihood of repeating the same content verbatim.';

  @override
  String presencePenalty(Object value) {
    return 'Presence Penalty: $value';
  }

  @override
  String get presencePenaltyTooltip => 'Presence penalty parameter. Positive values penalize new tokens based on whether they appear in the text, increasing the model\'s likelihood of talking about new topics.';

  @override
  String get enterMaxTokens => 'Enter max tokens';

  @override
  String get share => 'Share';

  @override
  String get modelConfig => 'Model Config';

  @override
  String get debug => 'Debug';

  @override
  String get webSearchTest => 'Web Search Test';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get earlier => 'Earlier';

  @override
  String get confirmDeleteSelected => 'Are you sure you want to delete the selected conversations?';

  @override
  String get ok => 'OK';

  @override
  String get askMeAnything => 'Ask me anything...';

  @override
  String get uploadFiles => 'Upload Files';

  @override
  String get welcomeMessage => 'How can I help you today?';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get retry => 'Retry';

  @override
  String get brokenImage => 'Broken Image';

  @override
  String toolCall(Object name) {
    return 'call $name';
  }

  @override
  String toolResult(Object name) {
    return 'call $name result';
  }

  @override
  String get selectModel => 'Select Model';

  @override
  String get close => 'Close';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get selectFile => 'Select File';

  @override
  String get uploadFile => 'Upload File';

  @override
  String get openBrowser => 'Open Browser';

  @override
  String get codeCopiedToClipboard => 'Code copied to clipboard';

  @override
  String get thinking => 'Thinking';

  @override
  String get thinkingEnd => 'Thinking End';

  @override
  String get tool => 'Tool';

  @override
  String get userCancelledToolCall => 'Tool execution failed';

  @override
  String get code => 'Code';

  @override
  String get preview => 'Preview';

  @override
  String get loadContentFailed => 'Failed to load content, please retry';

  @override
  String get openingBrowser => 'Opening browser';

  @override
  String get functionCallAuth => 'Tool Call Authorization';

  @override
  String get allowFunctionExecution => 'Do you want to allow the following tool to execute:';

  @override
  String parameters(Object params) {
    return 'Parameters: $params';
  }

  @override
  String get allow => 'Allow';

  @override
  String get loadDiagramFailed => 'Failed to load diagram, please retry';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get chinese => 'Chinese';

  @override
  String get functionRunning => 'Running Tool...';

  @override
  String get thinkingProcess => 'Thinking';

  @override
  String get thinkingProcessWithDuration => 'Thinking, time used';

  @override
  String get thinkingEndWithDuration => 'Thinking finished, time used';

  @override
  String get thinkingEndComplete => 'Thinking finished';

  @override
  String seconds(Object seconds) {
    return '${seconds}s';
  }

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get autoApprove => 'Auto Approve';

  @override
  String get verify => 'Verify Key';

  @override
  String get howToGet => 'How to get';

  @override
  String get modelList => 'Model List';

  @override
  String get enableModels => 'Enable Models';

  @override
  String get disableAllModels => 'Disable All Models';

  @override
  String get saveSuccess => 'Settings saved successfully';

  @override
  String get genTitleModel => 'Gen Title';

  @override
  String get serverNameTooLong => 'Server name cannot exceed 50 characters';

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
  String get serverType => 'Server Type';

  @override
  String get reset => 'Reset';

  @override
  String get start => 'Start';

  @override
  String get stop => 'stop';

  @override
  String newVersionFound(Object version) {
    return 'New version $version available';
  }

  @override
  String get newVersionAvailable => 'New version available';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateLater => 'Update Later';

  @override
  String get ignoreThisVersion => 'Ignore This Version';

  @override
  String get releaseNotes => 'Release Notes:';

  @override
  String get openUrlFailed => 'Failed to open URL';

  @override
  String get checkingForUpdates => 'Checking for updates...';

  @override
  String get checkUpdate => 'Update Check';
}
