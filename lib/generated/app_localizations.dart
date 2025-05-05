import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

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
  /// **'Separate arguments with spaces, for example: -m mcp.server'**
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
