import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('en'), Locale('tr'), Locale('zh')];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @providers.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get providers;

  /// No description provided for @mcpServer.
  ///
  /// In en, this message translates to:
  /// **'MCP Server'**
  String get mcpServer;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @featureSettings.
  ///
  /// In en, this message translates to:
  /// **'Feature Settings'**
  String get featureSettings;

  /// No description provided for @enableArtifacts.
  ///
  /// In en, this message translates to:
  /// **'Enable Artifacts'**
  String get enableArtifacts;

  /// No description provided for @enableArtifactsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable the artifacts of the AI assistant in the conversation, will use more tokens'**
  String get enableArtifactsDescription;

  /// No description provided for @enableToolUsage.
  ///
  /// In en, this message translates to:
  /// **'Enable Tool Usage'**
  String get enableToolUsage;

  /// No description provided for @enableToolUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable the usage of tools in the conversation, will use more tokens'**
  String get enableToolUsageDescription;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @showAvatar.
  ///
  /// In en, this message translates to:
  /// **'Show Avatar'**
  String get showAvatar;

  /// No description provided for @showAssistantAvatar.
  ///
  /// In en, this message translates to:
  /// **'Show Assistant Avatar'**
  String get showAssistantAvatar;

  /// No description provided for @showAssistantAvatarDescription.
  ///
  /// In en, this message translates to:
  /// **'Show the avatar of the AI assistant in the conversation'**
  String get showAssistantAvatarDescription;

  /// No description provided for @showUserAvatar.
  ///
  /// In en, this message translates to:
  /// **'Show User Avatar'**
  String get showUserAvatar;

  /// No description provided for @showUserAvatarDescription.
  ///
  /// In en, this message translates to:
  /// **'Show the avatar of the user in the conversation'**
  String get showUserAvatarDescription;

  /// No description provided for @systemPrompt.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get systemPrompt;

  /// No description provided for @systemPromptDescription.
  ///
  /// In en, this message translates to:
  /// **'This is the system prompt for the conversation with the AI assistant, used to set the behavior and style of the assistant'**
  String get systemPromptDescription;

  /// No description provided for @llmKey.
  ///
  /// In en, this message translates to:
  /// **'LLM Key'**
  String get llmKey;

  /// No description provided for @toolKey.
  ///
  /// In en, this message translates to:
  /// **'Tool Key'**
  String get toolKey;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your {provider} API Key'**
  String enterApiKey(Object provider);

  /// No description provided for @apiKeyValidation.
  ///
  /// In en, this message translates to:
  /// **'API Key must be at least 10 characters'**
  String get apiKeyValidation;

  /// No description provided for @apiEndpoint.
  ///
  /// In en, this message translates to:
  /// **'API Endpoint'**
  String get apiEndpoint;

  /// No description provided for @enterApiEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Enter API endpoint URL'**
  String get enterApiEndpoint;

  /// No description provided for @apiVersion.
  ///
  /// In en, this message translates to:
  /// **'API Version'**
  String get apiVersion;

  /// No description provided for @enterApiVersion.
  ///
  /// In en, this message translates to:
  /// **'Enter API Version'**
  String get enterApiVersion;

  /// No description provided for @platformNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Current platform does not support MCP Server'**
  String get platformNotSupported;

  /// No description provided for @mcpServerDesktopOnly.
  ///
  /// In en, this message translates to:
  /// **'MCP Server only supports desktop platforms (Windows, macOS, Linux)'**
  String get mcpServerDesktopOnly;

  /// No description provided for @searchServer.
  ///
  /// In en, this message translates to:
  /// **'Search server...'**
  String get searchServer;

  /// No description provided for @noServerConfigs.
  ///
  /// In en, this message translates to:
  /// **'No server configurations found'**
  String get noServerConfigs;

  /// No description provided for @addMcpServer.
  ///
  /// In en, this message translates to:
  /// **'Add MCP Server'**
  String get addMcpServer;

  /// No description provided for @addProvider.
  ///
  /// In en, this message translates to:
  /// **'Add Provider'**
  String get addProvider;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @command.
  ///
  /// In en, this message translates to:
  /// **'Command Or Sever Url'**
  String get command;

  /// No description provided for @arguments.
  ///
  /// In en, this message translates to:
  /// **'Arguments'**
  String get arguments;

  /// No description provided for @environmentVariables.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables'**
  String get environmentVariables;

  /// No description provided for @serverName.
  ///
  /// In en, this message translates to:
  /// **'Server Name'**
  String get serverName;

  /// No description provided for @commandExample.
  ///
  /// In en, this message translates to:
  /// **'For example: npx, uvx, https://mcpserver.com'**
  String get commandExample;

  /// No description provided for @argumentsExample.
  ///
  /// In en, this message translates to:
  /// **'Separate arguments with spaces, use quotes for arguments with spaces, for example: -y obsidian-mcp \'/Users/username/Documents/Obsidian Vault\''**
  String get argumentsExample;

  /// No description provided for @envVarsFormat.
  ///
  /// In en, this message translates to:
  /// **'One per line, format: KEY=VALUE'**
  String get envVarsFormat;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteServer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete server \"{name}\" ?'**
  String confirmDeleteServer(Object name);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @commandNotExist.
  ///
  /// In en, this message translates to:
  /// **'Command \"{command}\" does not exist, please install it first\n\nCurrent PATH:\n{path}'**
  String commandNotExist(Object command, Object path);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installed;

  /// No description provided for @modelSettings.
  ///
  /// In en, this message translates to:
  /// **'Model Settings'**
  String get modelSettings;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature: {value}'**
  String temperature(Object value);

  /// No description provided for @temperatureTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sampling temperature controls the randomness of output:\n• 0.0: Suitable for code generation and math problems\n• 1.0: Suitable for data extraction and analysis\n• 1.3: Suitable for general conversation and translation\n• 1.5: Suitable for creative writing and poetry'**
  String get temperatureTooltip;

  /// No description provided for @topP.
  ///
  /// In en, this message translates to:
  /// **'Top P: {value}'**
  String topP(Object value);

  /// No description provided for @topPTooltip.
  ///
  /// In en, this message translates to:
  /// **'Top P (nucleus sampling) is an alternative to temperature. The model only considers tokens whose cumulative probability exceeds P. It is recommended not to modify both temperature and top_p at the same time.'**
  String get topPTooltip;

  /// No description provided for @maxTokens.
  ///
  /// In en, this message translates to:
  /// **'Max Tokens'**
  String get maxTokens;

  /// No description provided for @maxTokensTooltip.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of tokens to generate. One token is approximately equal to 4 characters. Longer conversations require more tokens.'**
  String get maxTokensTooltip;

  /// No description provided for @frequencyPenalty.
  ///
  /// In en, this message translates to:
  /// **'Frequency Penalty: {value}'**
  String frequencyPenalty(Object value);

  /// No description provided for @frequencyPenaltyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Frequency penalty parameter. Positive values penalize new tokens based on their existing frequency in the text, decreasing the model\'s likelihood of repeating the same content verbatim.'**
  String get frequencyPenaltyTooltip;

  /// No description provided for @presencePenalty.
  ///
  /// In en, this message translates to:
  /// **'Presence Penalty: {value}'**
  String presencePenalty(Object value);

  /// No description provided for @presencePenaltyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Presence penalty parameter. Positive values penalize new tokens based on whether they appear in the text, increasing the model\'s likelihood of talking about new topics.'**
  String get presencePenaltyTooltip;

  /// No description provided for @enterMaxTokens.
  ///
  /// In en, this message translates to:
  /// **'Enter max tokens'**
  String get enterMaxTokens;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @modelConfig.
  ///
  /// In en, this message translates to:
  /// **'Model Config'**
  String get modelConfig;

  /// No description provided for @debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug;

  /// No description provided for @webSearchTest.
  ///
  /// In en, this message translates to:
  /// **'Web Search Test'**
  String get webSearchTest;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @confirmDeleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the selected conversations?'**
  String get confirmDeleteSelected;

  /// No description provided for @confirmThisChat.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the this conversations'**
  String get confirmThisChat;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @askMeAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything...'**
  String get askMeAnything;

  /// No description provided for @uploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload Files'**
  String get uploadFiles;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'How can I help you today?'**
  String get welcomeMessage;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @brokenImage.
  ///
  /// In en, this message translates to:
  /// **'Broken Image'**
  String get brokenImage;

  /// No description provided for @toolCall.
  ///
  /// In en, this message translates to:
  /// **'call {name}'**
  String toolCall(Object name);

  /// No description provided for @toolResult.
  ///
  /// In en, this message translates to:
  /// **'call {name} result'**
  String toolResult(Object name);

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get selectModel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// No description provided for @openBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open Browser'**
  String get openBrowser;

  /// No description provided for @codeCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopiedToClipboard;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @thinkingEnd.
  ///
  /// In en, this message translates to:
  /// **'Thinking End'**
  String get thinkingEnd;

  /// No description provided for @tool.
  ///
  /// In en, this message translates to:
  /// **'Tool'**
  String get tool;

  /// No description provided for @userCancelledToolCall.
  ///
  /// In en, this message translates to:
  /// **'Tool execution failed'**
  String get userCancelledToolCall;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @loadContentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load content, please retry'**
  String get loadContentFailed;

  /// No description provided for @openingBrowser.
  ///
  /// In en, this message translates to:
  /// **'Opening browser'**
  String get openingBrowser;

  /// No description provided for @functionCallAuth.
  ///
  /// In en, this message translates to:
  /// **'Tool Call Authorization'**
  String get functionCallAuth;

  /// No description provided for @allowFunctionExecution.
  ///
  /// In en, this message translates to:
  /// **'Do you want to allow the following tool to execute:'**
  String get allowFunctionExecution;

  /// No description provided for @parameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters: {params}'**
  String parameters(Object params);

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @loadDiagramFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load diagram, please retry'**
  String get loadDiagramFailed;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @functionRunning.
  ///
  /// In en, this message translates to:
  /// **'Running Tool...'**
  String get functionRunning;

  /// No description provided for @thinkingProcess.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinkingProcess;

  /// No description provided for @thinkingProcessWithDuration.
  ///
  /// In en, this message translates to:
  /// **'Thinking, time used'**
  String get thinkingProcessWithDuration;

  /// No description provided for @thinkingEndWithDuration.
  ///
  /// In en, this message translates to:
  /// **'Thinking finished, time used'**
  String get thinkingEndWithDuration;

  /// No description provided for @thinkingEndComplete.
  ///
  /// In en, this message translates to:
  /// **'Thinking finished'**
  String get thinkingEndComplete;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String seconds(Object seconds);

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @autoApprove.
  ///
  /// In en, this message translates to:
  /// **'Auto Approve'**
  String get autoApprove;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify Key'**
  String get verify;

  /// No description provided for @howToGet.
  ///
  /// In en, this message translates to:
  /// **'How to get'**
  String get howToGet;

  /// No description provided for @modelList.
  ///
  /// In en, this message translates to:
  /// **'Model List'**
  String get modelList;

  /// No description provided for @enableModels.
  ///
  /// In en, this message translates to:
  /// **'Enable Models'**
  String get enableModels;

  /// No description provided for @disableAllModels.
  ///
  /// In en, this message translates to:
  /// **'Disable All Models'**
  String get disableAllModels;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get saveSuccess;

  /// No description provided for @genTitleModel.
  ///
  /// In en, this message translates to:
  /// **'Gen Title'**
  String get genTitleModel;

  /// No description provided for @serverNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Server name cannot exceed 50 characters'**
  String get serverNameTooLong;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @providerName.
  ///
  /// In en, this message translates to:
  /// **'Provider Name'**
  String get providerName;

  /// No description provided for @apiStyle.
  ///
  /// In en, this message translates to:
  /// **'API Style'**
  String get apiStyle;

  /// No description provided for @enterProviderName.
  ///
  /// In en, this message translates to:
  /// **'Enter provider name'**
  String get enterProviderName;

  /// No description provided for @providerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Provider name is required'**
  String get providerNameRequired;

  /// No description provided for @addModel.
  ///
  /// In en, this message translates to:
  /// **'Add Model'**
  String get addModel;

  /// No description provided for @modelName.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get modelName;

  /// No description provided for @enterModelName.
  ///
  /// In en, this message translates to:
  /// **'Enter model name'**
  String get enterModelName;

  /// No description provided for @noApiConfigs.
  ///
  /// In en, this message translates to:
  /// **'No API configurations available'**
  String get noApiConfigs;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @fetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get fetch;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @apiUrl.
  ///
  /// In en, this message translates to:
  /// **'API URL'**
  String get apiUrl;

  /// No description provided for @selectApiStyle.
  ///
  /// In en, this message translates to:
  /// **'Please select API style'**
  String get selectApiStyle;

  /// No description provided for @serverType.
  ///
  /// In en, this message translates to:
  /// **'Server Type'**
  String get serverType;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'stop'**
  String get stop;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @newVersionFound.
  ///
  /// In en, this message translates to:
  /// **'New version {version} available'**
  String newVersionFound(Object version);

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get newVersionAvailable;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Update Later'**
  String get updateLater;

  /// No description provided for @ignoreThisVersion.
  ///
  /// In en, this message translates to:
  /// **'Ignore This Version'**
  String get ignoreThisVersion;

  /// No description provided for @releaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release Notes:'**
  String get releaseNotes;

  /// No description provided for @openUrlFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open URL'**
  String get openUrlFailed;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checkingForUpdates;

  /// No description provided for @checkUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Check'**
  String get checkUpdate;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'ChatMCP is a cross-platform AI client, dedicated to making AI accessible to more people.'**
  String get appDescription;

  /// No description provided for @visitWebsite.
  ///
  /// In en, this message translates to:
  /// **'website'**
  String get visitWebsite;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred'**
  String get networkError;

  /// No description provided for @noElementError.
  ///
  /// In en, this message translates to:
  /// **'No element found'**
  String get noElementError;

  /// No description provided for @permissionError.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get timeoutError;

  /// No description provided for @notFoundError.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get notFoundError;

  /// No description provided for @invalidError.
  ///
  /// In en, this message translates to:
  /// **'Invalid request'**
  String get invalidError;

  /// No description provided for @unauthorizedError.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access'**
  String get unauthorizedError;

  /// No description provided for @minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimize;

  /// No description provided for @maximize.
  ///
  /// In en, this message translates to:
  /// **'Maximize'**
  String get maximize;

  /// No description provided for @conversationSettings.
  ///
  /// In en, this message translates to:
  /// **'Conversation Settings'**
  String get conversationSettings;

  /// No description provided for @maxMessages.
  ///
  /// In en, this message translates to:
  /// **'Max Messages'**
  String get maxMessages;

  /// No description provided for @maxMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Limit the maximum number of messages passed to LLM (1-1000)'**
  String get maxMessagesDescription;

  /// No description provided for @maxLoops.
  ///
  /// In en, this message translates to:
  /// **'Max Loops'**
  String get maxLoops;

  /// No description provided for @maxLoopsDescription.
  ///
  /// In en, this message translates to:
  /// **'Limit the maximum number of tool call loops to prevent infinite loops (1-1000)'**
  String get maxLoopsDescription;

  /// No description provided for @mcpServers.
  ///
  /// In en, this message translates to:
  /// **'MCP Servers'**
  String get mcpServers;

  /// No description provided for @getApiKey.
  ///
  /// In en, this message translates to:
  /// **'Get API Key'**
  String get getApiKey;

  /// No description provided for @proxySettings.
  ///
  /// In en, this message translates to:
  /// **'Proxy Settings'**
  String get proxySettings;

  /// No description provided for @enableProxy.
  ///
  /// In en, this message translates to:
  /// **'Enable Proxy'**
  String get enableProxy;

  /// No description provided for @enableProxyDescription.
  ///
  /// In en, this message translates to:
  /// **'When enabled, network requests will go through the configured proxy server'**
  String get enableProxyDescription;

  /// No description provided for @proxyType.
  ///
  /// In en, this message translates to:
  /// **'Proxy Type'**
  String get proxyType;

  /// No description provided for @proxyHost.
  ///
  /// In en, this message translates to:
  /// **'Proxy Host'**
  String get proxyHost;

  /// No description provided for @proxyPort.
  ///
  /// In en, this message translates to:
  /// **'Proxy Port'**
  String get proxyPort;

  /// No description provided for @proxyUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get proxyUsername;

  /// No description provided for @proxyPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get proxyPassword;

  /// No description provided for @enterProxyHost.
  ///
  /// In en, this message translates to:
  /// **'Enter proxy server address'**
  String get enterProxyHost;

  /// No description provided for @enterProxyPort.
  ///
  /// In en, this message translates to:
  /// **'Enter proxy port'**
  String get enterProxyPort;

  /// No description provided for @enterProxyUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username (optional)'**
  String get enterProxyUsername;

  /// No description provided for @enterProxyPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password (optional)'**
  String get enterProxyPassword;

  /// No description provided for @proxyHostRequired.
  ///
  /// In en, this message translates to:
  /// **'Proxy host is required'**
  String get proxyHostRequired;

  /// No description provided for @proxyPortInvalid.
  ///
  /// In en, this message translates to:
  /// **'Proxy port must be between 1-65535'**
  String get proxyPortInvalid;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @dataSync.
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get dataSync;

  /// No description provided for @syncServerRunning.
  ///
  /// In en, this message translates to:
  /// **'Sync server is running'**
  String get syncServerRunning;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @cleanupLogs.
  ///
  /// In en, this message translates to:
  /// **'Cleanup Old Logs'**
  String get cleanupLogs;

  /// No description provided for @cleanupLogsDescription.
  ///
  /// In en, this message translates to:
  /// **'Cleanup log files'**
  String get cleanupLogsDescription;

  /// No description provided for @confirmCleanup.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cleanup'**
  String get confirmCleanup;

  /// No description provided for @confirmCleanupMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete log files? This action cannot be undone.'**
  String get confirmCleanupMessage;

  /// No description provided for @cleanupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Old logs cleanup completed'**
  String get cleanupSuccess;

  /// No description provided for @cleanupFailed.
  ///
  /// In en, this message translates to:
  /// **'Cleanup failed'**
  String get cleanupFailed;

  /// No description provided for @syncServerStopped.
  ///
  /// In en, this message translates to:
  /// **'Sync server stopped'**
  String get syncServerStopped;

  /// No description provided for @scanQRToConnect.
  ///
  /// In en, this message translates to:
  /// **'Other devices scan this QR code to connect:'**
  String get scanQRToConnect;

  /// No description provided for @addressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get addressCopied;

  /// No description provided for @otherDevicesCanScan.
  ///
  /// In en, this message translates to:
  /// **'Other devices can scan this QR code to connect quickly'**
  String get otherDevicesCanScan;

  /// No description provided for @startServer.
  ///
  /// In en, this message translates to:
  /// **'Start Server'**
  String get startServer;

  /// No description provided for @stopServer.
  ///
  /// In en, this message translates to:
  /// **'Stop Server'**
  String get stopServer;

  /// No description provided for @connectToOtherDevices.
  ///
  /// In en, this message translates to:
  /// **'Connect to Other Devices'**
  String get connectToOtherDevices;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to Connect'**
  String get scanQRCode;

  /// No description provided for @connectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Connection History:'**
  String get connectionHistory;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @manualInputAddress.
  ///
  /// In en, this message translates to:
  /// **'Or manually enter server address:'**
  String get manualInputAddress;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverAddress;

  /// No description provided for @syncFromServer.
  ///
  /// In en, this message translates to:
  /// **'Sync from Server'**
  String get syncFromServer;

  /// No description provided for @pushToServer.
  ///
  /// In en, this message translates to:
  /// **'Push to Server'**
  String get pushToServer;

  /// No description provided for @usageInstructions.
  ///
  /// In en, this message translates to:
  /// **'Usage Instructions'**
  String get usageInstructions;

  /// No description provided for @desktopAsServer.
  ///
  /// In en, this message translates to:
  /// **'Desktop as Server:'**
  String get desktopAsServer;

  /// No description provided for @desktopStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Click \"Start Server\" button'**
  String get desktopStep1;

  /// No description provided for @desktopStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Show QR code for mobile to scan'**
  String get desktopStep2;

  /// No description provided for @desktopStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Mobile can sync data after scanning'**
  String get desktopStep3;

  /// No description provided for @mobileConnect.
  ///
  /// In en, this message translates to:
  /// **'Mobile Connection:'**
  String get mobileConnect;

  /// No description provided for @mobileStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Click \"Scan QR Code to Connect\"'**
  String get mobileStep1;

  /// No description provided for @mobileStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Scan the QR code displayed on desktop'**
  String get mobileStep2;

  /// No description provided for @mobileStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Choose sync direction (upload/download)'**
  String get mobileStep3;

  /// No description provided for @uploadDescription.
  ///
  /// In en, this message translates to:
  /// **'• Upload: Push local device data to server'**
  String get uploadDescription;

  /// No description provided for @downloadDescription.
  ///
  /// In en, this message translates to:
  /// **'• Download: Get data from server to local device'**
  String get downloadDescription;

  /// No description provided for @syncContent.
  ///
  /// In en, this message translates to:
  /// **'• Sync Content: Chat history, settings, MCP configs'**
  String get syncContent;

  /// No description provided for @syncServerStarted.
  ///
  /// In en, this message translates to:
  /// **'Sync server started'**
  String get syncServerStarted;

  /// No description provided for @syncServerStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start server'**
  String get syncServerStartFailed;

  /// No description provided for @syncServerStopFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop server'**
  String get syncServerStopFailed;

  /// No description provided for @scanQRCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCodeTitle;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Flash On'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Flash Off'**
  String get flashOff;

  /// No description provided for @aimQRCode.
  ///
  /// In en, this message translates to:
  /// **'Aim the QR code at the scanning frame'**
  String get aimQRCode;

  /// No description provided for @scanSyncQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan the sync QR code displayed on desktop'**
  String get scanSyncQRCode;

  /// No description provided for @manualInputAddressButton.
  ///
  /// In en, this message translates to:
  /// **'Manual Input Address'**
  String get manualInputAddressButton;

  /// No description provided for @manualInputServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Manually Input Server Address'**
  String get manualInputServerAddress;

  /// No description provided for @enterValidServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid server address'**
  String get enterValidServerAddress;

  /// No description provided for @scanSuccessConnectTo.
  ///
  /// In en, this message translates to:
  /// **'Scan successful, connected to: {deviceName}'**
  String scanSuccessConnectTo(Object deviceName);

  /// No description provided for @scanSuccessAddressFilled.
  ///
  /// In en, this message translates to:
  /// **'Scan successful, server address filled'**
  String get scanSuccessAddressFilled;

  /// No description provided for @scannerOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open scanner'**
  String get scannerOpenFailed;

  /// No description provided for @pleaseInputServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Please scan QR code or input server address first'**
  String get pleaseInputServerAddress;

  /// No description provided for @connectingToServer.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server...'**
  String get connectingToServer;

  /// No description provided for @downloadingData.
  ///
  /// In en, this message translates to:
  /// **'Downloading data...'**
  String get downloadingData;

  /// No description provided for @importingData.
  ///
  /// In en, this message translates to:
  /// **'Importing data...'**
  String get importingData;

  /// No description provided for @reinitializingData.
  ///
  /// In en, this message translates to:
  /// **'Reinitializing app data...'**
  String get reinitializingData;

  /// No description provided for @dataSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data sync successful'**
  String get dataSyncSuccess;

  /// No description provided for @preparingData.
  ///
  /// In en, this message translates to:
  /// **'Preparing data...'**
  String get preparingData;

  /// No description provided for @uploadingData.
  ///
  /// In en, this message translates to:
  /// **'Uploading data...'**
  String get uploadingData;

  /// No description provided for @dataPushSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data push successful'**
  String get dataPushSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @pushFailed.
  ///
  /// In en, this message translates to:
  /// **'Push failed'**
  String get pushFailed;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(Object hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);

  /// No description provided for @serverSelected.
  ///
  /// In en, this message translates to:
  /// **'Server selected: {deviceName}'**
  String serverSelected(Object deviceName);

  /// No description provided for @connectionRecordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Connection record deleted'**
  String get connectionRecordDeleted;

  /// No description provided for @viewAllConnections.
  ///
  /// In en, this message translates to:
  /// **'View all {count} connections'**
  String viewAllConnections(Object count);

  /// No description provided for @clearAllHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllHistory;

  /// No description provided for @clearAllConnectionHistory.
  ///
  /// In en, this message translates to:
  /// **'All connection history cleared'**
  String get clearAllConnectionHistory;

  /// No description provided for @unknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown Device'**
  String get unknownDevice;

  /// No description provided for @unknownPlatform.
  ///
  /// In en, this message translates to:
  /// **'Unknown Platform'**
  String get unknownPlatform;

  /// No description provided for @inmemory.
  ///
  /// In en, this message translates to:
  /// **'In Memory'**
  String get inmemory;

  /// No description provided for @toggleSidebar.
  ///
  /// In en, this message translates to:
  /// **'Toggle Sidebar'**
  String get toggleSidebar;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChat;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @noMoreData.
  ///
  /// In en, this message translates to:
  /// **'No more data'**
  String get noMoreData;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'tr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
