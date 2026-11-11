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
  String get systemPromptDescription =>
      'This is the system prompt for the conversation with the AI assistant, used to set the behavior and style of the assistant';

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
  String get apiVersion => 'API Version';

  @override
  String get enterApiVersion => 'Enter API Version';

  @override
  String get platformNotSupported => 'Current platform does not support MCP Server';

  @override
  String get mcpServerDesktopOnly => 'MCP Server only supports desktop platforms (Windows, macOS, Linux)';

  @override
  String get searchServer => 'Search server...';

  @override
  String get noServerConfigs => 'No server configurations found';

  @override
  String get addMcpServer => 'Add MCP Server';

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
  String get argumentsExample =>
      'Separate arguments with spaces, use quotes for arguments with spaces, for example: -y obsidian-mcp \'/Users/username/Documents/Obsidian Vault\'';

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
  String get temperatureTooltip =>
      'Sampling temperature controls the randomness of output:\n• 0.0: Suitable for code generation and math problems\n• 1.0: Suitable for data extraction and analysis\n• 1.3: Suitable for general conversation and translation\n• 1.5: Suitable for creative writing and poetry';

  @override
  String topP(Object value) {
    return 'Top P: $value';
  }

  @override
  String get topPTooltip =>
      'Top P (nucleus sampling) is an alternative to temperature. The model only considers tokens whose cumulative probability exceeds P. It is recommended not to modify both temperature and top_p at the same time.';

  @override
  String get maxTokens => 'Max Tokens';

  @override
  String get maxTokensTooltip =>
      'Maximum number of tokens to generate. One token is approximately equal to 4 characters. Longer conversations require more tokens.';

  @override
  String frequencyPenalty(Object value) {
    return 'Frequency Penalty: $value';
  }

  @override
  String get frequencyPenaltyTooltip =>
      'Frequency penalty parameter. Positive values penalize new tokens based on their existing frequency in the text, decreasing the model\'s likelihood of repeating the same content verbatim.';

  @override
  String presencePenalty(Object value) {
    return 'Presence Penalty: $value';
  }

  @override
  String get presencePenaltyTooltip =>
      'Presence penalty parameter. Positive values penalize new tokens based on whether they appear in the text, increasing the model\'s likelihood of talking about new topics.';

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
  String get confirmThisChat => 'Are you sure you want to delete the this conversations';

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
  String get turkish => 'Turkish';

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
  String get search => 'Search';

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

  @override
  String get appDescription => 'ChatMCP is a cross-platform AI client, dedicated to making AI accessible to more people.';

  @override
  String get visitWebsite => 'website';

  @override
  String get aboutApp => 'About';

  @override
  String get networkError => 'Network error occurred';

  @override
  String get noElementError => 'No element found';

  @override
  String get permissionError => 'Permission denied';

  @override
  String get unknownError => 'Unknown error occurred';

  @override
  String get timeoutError => 'Request timed out';

  @override
  String get notFoundError => 'Resource not found';

  @override
  String get invalidError => 'Invalid request';

  @override
  String get unauthorizedError => 'Unauthorized access';

  @override
  String get minimize => 'Minimize';

  @override
  String get maximize => 'Maximize';

  @override
  String get conversationSettings => 'Conversation Settings';

  @override
  String get maxMessages => 'Max Messages';

  @override
  String get maxMessagesDescription => 'Limit the maximum number of messages passed to LLM (1-1000)';

  @override
  String get maxLoops => 'Max Loops';

  @override
  String get maxLoopsDescription => 'Limit the maximum number of tool call loops to prevent infinite loops (1-1000)';

  @override
  String get mcpServers => 'MCP Servers';

  @override
  String get getApiKey => 'Get API Key';

  @override
  String get proxySettings => 'Proxy Settings';

  @override
  String get enableProxy => 'Enable Proxy';

  @override
  String get enableProxyDescription => 'When enabled, network requests will go through the configured proxy server';

  @override
  String get proxyType => 'Proxy Type';

  @override
  String get proxyHost => 'Proxy Host';

  @override
  String get proxyPort => 'Proxy Port';

  @override
  String get proxyUsername => 'Username';

  @override
  String get proxyPassword => 'Password';

  @override
  String get enterProxyHost => 'Enter proxy server address';

  @override
  String get enterProxyPort => 'Enter proxy port';

  @override
  String get enterProxyUsername => 'Enter username (optional)';

  @override
  String get enterProxyPassword => 'Enter password (optional)';

  @override
  String get proxyHostRequired => 'Proxy host is required';

  @override
  String get proxyPortInvalid => 'Proxy port must be between 1-65535';

  @override
  String get saved => 'Saved';

  @override
  String get dataSync => 'Data Sync';

  @override
  String get syncServerRunning => 'Sync server is running';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get cleanupLogs => 'Cleanup Old Logs';

  @override
  String get cleanupLogsDescription => 'Cleanup log files';

  @override
  String get confirmCleanup => 'Confirm Cleanup';

  @override
  String get confirmCleanupMessage => 'Are you sure you want to delete log files? This action cannot be undone.';

  @override
  String get cleanupSuccess => 'Old logs cleanup completed';

  @override
  String get cleanupFailed => 'Cleanup failed';

  @override
  String get syncServerStopped => 'Sync server stopped';

  @override
  String get scanQRToConnect => 'Other devices scan this QR code to connect:';

  @override
  String get addressCopied => 'Address copied to clipboard';

  @override
  String get otherDevicesCanScan => 'Other devices can scan this QR code to connect quickly';

  @override
  String get startServer => 'Start Server';

  @override
  String get stopServer => 'Stop Server';

  @override
  String get connectToOtherDevices => 'Connect to Other Devices';

  @override
  String get scanQRCode => 'Scan QR Code to Connect';

  @override
  String get connectionHistory => 'Connection History:';

  @override
  String get connect => 'Connect';

  @override
  String get manualInputAddress => 'Or manually enter server address:';

  @override
  String get serverAddress => 'Server Address';

  @override
  String get syncFromServer => 'Sync from Server';

  @override
  String get pushToServer => 'Push to Server';

  @override
  String get usageInstructions => 'Usage Instructions';

  @override
  String get desktopAsServer => 'Desktop as Server:';

  @override
  String get desktopStep1 => '1. Click \"Start Server\" button';

  @override
  String get desktopStep2 => '2. Show QR code for mobile to scan';

  @override
  String get desktopStep3 => '3. Mobile can sync data after scanning';

  @override
  String get mobileConnect => 'Mobile Connection:';

  @override
  String get mobileStep1 => '1. Click \"Scan QR Code to Connect\"';

  @override
  String get mobileStep2 => '2. Scan the QR code displayed on desktop';

  @override
  String get mobileStep3 => '3. Choose sync direction (upload/download)';

  @override
  String get uploadDescription => '• Upload: Push local device data to server';

  @override
  String get downloadDescription => '• Download: Get data from server to local device';

  @override
  String get syncContent => '• Sync Content: Chat history, settings, MCP configs';

  @override
  String get syncServerStarted => 'Sync server started';

  @override
  String get syncServerStartFailed => 'Failed to start server';

  @override
  String get syncServerStopFailed => 'Failed to stop server';

  @override
  String get scanQRCodeTitle => 'Scan QR Code';

  @override
  String get flashOn => 'Flash On';

  @override
  String get flashOff => 'Flash Off';

  @override
  String get aimQRCode => 'Aim the QR code at the scanning frame';

  @override
  String get scanSyncQRCode => 'Scan the sync QR code displayed on desktop';

  @override
  String get manualInputAddressButton => 'Manual Input Address';

  @override
  String get manualInputServerAddress => 'Manually Input Server Address';

  @override
  String get enterValidServerAddress => 'Please enter a valid server address';

  @override
  String scanSuccessConnectTo(Object deviceName) {
    return 'Scan successful, connected to: $deviceName';
  }

  @override
  String get scanSuccessAddressFilled => 'Scan successful, server address filled';

  @override
  String get scannerOpenFailed => 'Failed to open scanner';

  @override
  String get pleaseInputServerAddress => 'Please scan QR code or input server address first';

  @override
  String get connectingToServer => 'Connecting to server...';

  @override
  String get downloadingData => 'Downloading data...';

  @override
  String get importingData => 'Importing data...';

  @override
  String get reinitializingData => 'Reinitializing app data...';

  @override
  String get dataSyncSuccess => 'Data sync successful';

  @override
  String get preparingData => 'Preparing data...';

  @override
  String get uploadingData => 'Uploading data...';

  @override
  String get dataPushSuccess => 'Data push successful';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get pushFailed => 'Push failed';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes minutes ago';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String serverSelected(Object deviceName) {
    return 'Server selected: $deviceName';
  }

  @override
  String get connectionRecordDeleted => 'Connection record deleted';

  @override
  String viewAllConnections(Object count) {
    return 'View all $count connections';
  }

  @override
  String get clearAllHistory => 'Clear All';

  @override
  String get clearAllConnectionHistory => 'All connection history cleared';

  @override
  String get unknownDevice => 'Unknown Device';

  @override
  String get unknownPlatform => 'Unknown Platform';

  @override
  String get inmemory => 'In Memory';

  @override
  String get toggleSidebar => 'Toggle Sidebar';

  @override
  String get deleteChat => 'Delete Chat';

  @override
  String get selectAll => 'Select All';

  @override
  String get newChat => 'New Chat';

  @override
  String get send => 'Send';

  @override
  String get more => 'More';

  @override
  String get noMoreData => 'No more data';
  @override
  String get oauthRefreshToken => 'Refresh OAuth Token';

  @override
  String get oauthAuthenticated => 'OAuth Authenticated';

  @override
  String get oauthSignIn => 'Authenticate with OAuth';

  @override
  String get oauthTokenRefreshed => 'OAuth token refreshed';

  @override
  String get oauthSignInSuccess => 'OAuth authentication successful';

  @override
  String oauthError(Object error) {
    return 'OAuth error: $error';
  }

  @override
  String get oauthChecking => 'Checking authentication requirements...';

  @override
  String get oauthLoginAfterSave => 'This server requires OAuth authentication. Sign in after saving.';

  @override
  String get oauthSectionTitle => 'Authentication';

  @override
  String get oauthAutomaticLoginInfo => 'After saving a server that requires authentication, you will be prompted to sign in.';

  @override
  String get oauthRequired => 'Authentication Required';

  @override
  String get oauthLoginPrompt => 'This server requires OAuth authentication. Sign in now?';

  @override
  String get oauthLoginNow => 'Log In';

  @override
  String oauthSuccessForServer(Object serverName) {
    return 'Signed in to $serverName';
  }

  @override
  String get oauthNoSuccessResponse => 'Authentication failed: no success response';

  @override
  String oauthSignInFailed(Object error) {
    return 'Authentication failed: $error';
  }

}
