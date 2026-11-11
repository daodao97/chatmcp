// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settings => 'Einstellungen';

  @override
  String get general => 'Allgemein';

  @override
  String get providers => 'Anbieter';

  @override
  String get mcpServer => 'MCP Server';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Design';

  @override
  String get dark => 'Dunkel';

  @override
  String get light => 'Hell';

  @override
  String get system => 'System';

  @override
  String get languageSettings => 'Spracheinstellungen';

  @override
  String get featureSettings => 'Funktionseinstellungen';

  @override
  String get enableArtifacts => 'Artifacts aktivieren';

  @override
  String get enableArtifactsDescription => 'Artifacts des KI-Assistenten in der Unterhaltung aktivieren, verbraucht mehr Token';

  @override
  String get enableToolUsage => 'Werkzeugnutzung aktivieren';

  @override
  String get enableToolUsageDescription => 'Nutzung von Werkzeugen in der Unterhaltung aktivieren, verbraucht mehr Token';

  @override
  String get themeSettings => 'Design-Einstellungen';

  @override
  String get lightTheme => 'Helles Design';

  @override
  String get darkTheme => 'Dunkles Design';

  @override
  String get followSystem => 'System folgen';

  @override
  String get showAvatar => 'Avatar anzeigen';

  @override
  String get showAssistantAvatar => 'Assistenten-Avatar anzeigen';

  @override
  String get showAssistantAvatarDescription => 'Avatar des KI-Assistenten in der Unterhaltung anzeigen';

  @override
  String get showUserAvatar => 'Benutzer-Avatar anzeigen';

  @override
  String get showUserAvatarDescription => 'Avatar des Benutzers in der Unterhaltung anzeigen';

  @override
  String get systemPrompt => 'System-Prompt';

  @override
  String get systemPromptDescription =>
      'Dies ist der System-Prompt für die Unterhaltung mit dem KI-Assistenten, wird verwendet um Verhalten und Stil des Assistenten festzulegen';

  @override
  String get llmKey => 'LLM Schlüssel';

  @override
  String get toolKey => 'Werkzeug-Schlüssel';

  @override
  String get saveSettings => 'Einstellungen speichern';

  @override
  String get apiKey => 'API Schlüssel';

  @override
  String enterApiKey(Object provider) {
    return 'Geben Sie Ihren $provider API Schlüssel ein';
  }

  @override
  String get apiKeyValidation => 'API Schlüssel muss mindestens 10 Zeichen haben';

  @override
  String get apiEndpoint => 'API Endpunkt';

  @override
  String get enterApiEndpoint => 'API Endpunkt URL eingeben';

  @override
  String get apiVersion => 'API Version';

  @override
  String get enterApiVersion => 'API Version eingeben';

  @override
  String get platformNotSupported => 'Aktuelle Plattform unterstützt MCP Server nicht';

  @override
  String get mcpServerDesktopOnly => 'MCP Server unterstützt nur Desktop-Plattformen (Windows, macOS, Linux)';

  @override
  String get searchServer => 'Server suchen...';

  @override
  String get noServerConfigs => 'Keine Server-Konfigurationen gefunden';

  @override
  String get addMcpServer => 'MCP-Server hinzufügen';

  @override
  String get addProvider => 'Anbieter hinzufügen';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get install => 'Installieren';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get command => 'Befehl oder Server-URL';

  @override
  String get arguments => 'Argumente';

  @override
  String get environmentVariables => 'Umgebungsvariablen';

  @override
  String get serverName => 'Servername';

  @override
  String get commandExample => 'Zum Beispiel: npx, uvx, https://mcpserver.com';

  @override
  String get argumentsExample =>
      'Argumente durch Leerzeichen trennen, Anführungszeichen für Argumente mit Leerzeichen verwenden, zum Beispiel: -y obsidian-mcp \'/Users/username/Documents/Obsidian Vault\'';

  @override
  String get envVarsFormat => 'Eine pro Zeile, Format: SCHLÜSSEL=WERT';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get confirmDelete => 'Löschen bestätigen';

  @override
  String confirmDeleteServer(Object name) {
    return 'Sind Sie sicher, dass Sie Server \"$name\" löschen möchten?';
  }

  @override
  String get error => 'Fehler';

  @override
  String commandNotExist(Object command, Object path) {
    return 'Befehl \"$command\" existiert nicht, bitte zuerst installieren\n\nAktueller PATH:\n$path';
  }

  @override
  String get all => 'Alle';

  @override
  String get installed => 'Installiert';

  @override
  String get modelSettings => 'Modell-Einstellungen';

  @override
  String temperature(Object value) {
    return 'Temperatur: $value';
  }

  @override
  String get temperatureTooltip =>
      'Sampling-Temperatur kontrolliert die Zufälligkeit der Ausgabe:\n• 0.0: Geeignet für Code-Generierung und Mathe-Probleme\n• 1.0: Geeignet für Datenextraktion und Analyse\n• 1.3: Geeignet für allgemeine Unterhaltung und Übersetzung\n• 1.5: Geeignet für kreatives Schreiben und Poesie';

  @override
  String topP(Object value) {
    return 'Top P: $value';
  }

  @override
  String get topPTooltip =>
      'Top P (Nucleus-Sampling) ist eine Alternative zur Temperatur. Das Modell berücksichtigt nur Token, deren kumulative Wahrscheinlichkeit P überschreitet. Es wird empfohlen, nicht gleichzeitig Temperatur und top_p zu ändern.';

  @override
  String get maxTokens => 'Max Token';

  @override
  String get maxTokensTooltip =>
      'Maximale Anzahl zu generierender Token. Ein Token entspricht etwa 4 Zeichen. Längere Unterhaltungen benötigen mehr Token.';

  @override
  String frequencyPenalty(Object value) {
    return 'Häufigkeits-Bestrafung: $value';
  }

  @override
  String get frequencyPenaltyTooltip =>
      'Häufigkeits-Bestrafungsparameter. Positive Werte bestrafen neue Token basierend auf ihrer vorhandenen Häufigkeit im Text, wodurch die Wahrscheinlichkeit des Modells verringert wird, denselben Inhalt wörtlich zu wiederholen.';

  @override
  String presencePenalty(Object value) {
    return 'Präsenz-Bestrafung: $value';
  }

  @override
  String get presencePenaltyTooltip =>
      'Präsenz-Bestrafungsparameter. Positive Werte bestrafen neue Token basierend darauf, ob sie im Text erscheinen, wodurch die Wahrscheinlichkeit des Modells erhöht wird, über neue Themen zu sprechen.';

  @override
  String get enterMaxTokens => 'Max Token eingeben';

  @override
  String get share => 'Teilen';

  @override
  String get modelConfig => 'Modell-Konfiguration';

  @override
  String get debug => 'Debug';

  @override
  String get webSearchTest => 'Web-Suche Test';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get last7Days => 'Letzte 7 Tage';

  @override
  String get last30Days => 'Letzte 30 Tage';

  @override
  String get earlier => 'Früher';

  @override
  String get confirmDeleteSelected => 'Sind Sie sicher, dass Sie die ausgewählten Unterhaltungen löschen möchten?';

  @override
  String get confirmThisChat => 'Sind Sie sicher, dass Sie diese Unterhaltung löschen möchten?';

  @override
  String get ok => 'OK';

  @override
  String get askMeAnything => 'Fragen Sie mich alles...';

  @override
  String get uploadFiles => 'Dateien hochladen';

  @override
  String get welcomeMessage => 'Wie kann ich Ihnen heute helfen?';

  @override
  String get copy => 'Kopieren';

  @override
  String get copied => 'In Zwischenablage kopiert';

  @override
  String get retry => 'Wiederholen';

  @override
  String get brokenImage => 'Defektes Bild';

  @override
  String toolCall(Object name) {
    return '$name aufrufen';
  }

  @override
  String toolResult(Object name) {
    return '$name Aufruf-Ergebnis';
  }

  @override
  String get selectModel => 'Modell auswählen';

  @override
  String get close => 'Schließen';

  @override
  String get selectFromGallery => 'Aus Galerie auswählen';

  @override
  String get selectFile => 'Datei auswählen';

  @override
  String get uploadFile => 'Datei hochladen';

  @override
  String get openBrowser => 'Browser öffnen';

  @override
  String get codeCopiedToClipboard => 'Code in Zwischenablage kopiert';

  @override
  String get thinking => 'Denkt nach';

  @override
  String get thinkingEnd => 'Denken beendet';

  @override
  String get tool => 'Werkzeug';

  @override
  String get userCancelledToolCall => 'Benutzer hat Werkzeug-Aufruf abgebrochen';

  @override
  String get code => 'Code';

  @override
  String get preview => 'Vorschau';

  @override
  String get loadContentFailed => 'Laden des Inhalts fehlgeschlagen, bitte wiederholen';

  @override
  String get openingBrowser => 'Browser wird geöffnet';

  @override
  String get functionCallAuth => 'Werkzeug-Aufruf-Autorisierung';

  @override
  String get allowFunctionExecution => 'Möchten Sie die Ausführung des folgenden Werkzeugs erlauben:';

  @override
  String parameters(Object params) {
    return 'Parameter: $params';
  }

  @override
  String get allow => 'Erlauben';

  @override
  String get loadDiagramFailed => 'Laden des Diagramms fehlgeschlagen, bitte wiederholen';

  @override
  String get copiedToClipboard => 'In Zwischenablage kopiert';

  @override
  String get chinese => 'Chinesisch';

  @override
  String get turkish => 'Türkisch';

  @override
  String get functionRunning => 'Werkzeug wird ausgeführt...';

  @override
  String get thinkingProcess => 'Denkt nach';

  @override
  String get thinkingProcessWithDuration => 'Denkt nach, Zeit verbraucht';

  @override
  String get thinkingEndWithDuration => 'Denken beendet, Zeit verbraucht';

  @override
  String get thinkingEndComplete => 'Denken beendet';

  @override
  String seconds(Object seconds) {
    return '${seconds}s';
  }

  @override
  String get fieldRequired => 'Dieses Feld ist erforderlich';

  @override
  String get autoApprove => 'Automatisch genehmigen';

  @override
  String get verify => 'Schlüssel verifizieren';

  @override
  String get howToGet => 'Wie man es bekommt';

  @override
  String get modelList => 'Modell-Liste';

  @override
  String get enableModels => 'Modelle aktivieren';

  @override
  String get disableAllModels => 'Alle Modelle deaktivieren';

  @override
  String get saveSuccess => 'Einstellungen erfolgreich gespeichert';

  @override
  String get genTitleModel => 'Titel generieren';

  @override
  String get serverNameTooLong => 'Servername darf nicht länger als 50 Zeichen sein';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get providerName => 'Anbieter-Name';

  @override
  String get apiStyle => 'API-Stil';

  @override
  String get enterProviderName => 'Anbieter-Name eingeben';

  @override
  String get providerNameRequired => 'Anbieter-Name ist erforderlich';

  @override
  String get addModel => 'Modell hinzufügen';

  @override
  String get modelName => 'Modell-Name';

  @override
  String get enterModelName => 'Modell-Name eingeben';

  @override
  String get noApiConfigs => 'Keine API-Konfigurationen verfügbar';

  @override
  String get add => 'Hinzufügen';

  @override
  String get fetch => 'Abrufen';

  @override
  String get on => 'AN';

  @override
  String get off => 'AUS';

  @override
  String get apiUrl => 'API URL';

  @override
  String get selectApiStyle => 'Bitte API-Stil auswählen';

  @override
  String get serverType => 'Server-Typ';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get start => 'Starten';

  @override
  String get stop => 'Stoppen';

  @override
  String get search => 'Suchen';

  @override
  String newVersionFound(Object version) {
    return 'Neue Version $version verfügbar';
  }

  @override
  String get newVersionAvailable => 'Neue Version verfügbar';

  @override
  String get updateNow => 'Jetzt aktualisieren';

  @override
  String get updateLater => 'Später aktualisieren';

  @override
  String get ignoreThisVersion => 'Diese Version ignorieren';

  @override
  String get releaseNotes => 'Versionshinweise:';

  @override
  String get openUrlFailed => 'Öffnen der URL fehlgeschlagen';

  @override
  String get checkingForUpdates => 'Suche nach Updates...';

  @override
  String get checkUpdate => 'Update-Prüfung';

  @override
  String get appDescription => 'ChatMCP ist ein plattformübergreifender KI-Client, der darauf abzielt, KI für mehr Menschen zugänglich zu machen.';

  @override
  String get visitWebsite => 'Website';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get networkError => 'Netzwerkfehler aufgetreten';

  @override
  String get noElementError => 'Kein Element gefunden';

  @override
  String get permissionError => 'Zugriff verweigert';

  @override
  String get unknownError => 'Unbekannter Fehler aufgetreten';

  @override
  String get timeoutError => 'Anfrage-Timeout';

  @override
  String get notFoundError => 'Ressource nicht gefunden';

  @override
  String get invalidError => 'Ungültige Anfrage';

  @override
  String get unauthorizedError => 'Unbefugter Zugriff';

  @override
  String get minimize => 'Minimieren';

  @override
  String get maximize => 'Maximieren';

  @override
  String get conversationSettings => 'Unterhaltungs-Einstellungen';

  @override
  String get maxMessages => 'Max Nachrichten';

  @override
  String get maxMessagesDescription => 'Maximale Anzahl von Nachrichten, die an LLM weitergegeben werden (1-1000)';

  @override
  String get maxLoops => 'Max Schleifen';

  @override
  String get maxLoopsDescription => 'Maximale Anzahl von Werkzeug-Aufruf-Schleifen, um Endlosschleifen zu verhindern (1-1000)';

  @override
  String get mcpServers => 'MCP Server';

  @override
  String get getApiKey => 'API Schlüssel erhalten';

  @override
  String get proxySettings => 'Proxy-Einstellungen';

  @override
  String get enableProxy => 'Proxy aktivieren';

  @override
  String get enableProxyDescription => 'Wenn aktiviert, werden Netzwerkanfragen über den konfigurierten Proxy-Server geleitet';

  @override
  String get proxyType => 'Proxy-Typ';

  @override
  String get proxyHost => 'Proxy-Host';

  @override
  String get proxyPort => 'Proxy-Port';

  @override
  String get proxyUsername => 'Benutzername';

  @override
  String get proxyPassword => 'Passwort';

  @override
  String get enterProxyHost => 'Proxy-Server-Adresse eingeben';

  @override
  String get enterProxyPort => 'Proxy-Port eingeben';

  @override
  String get enterProxyUsername => 'Benutzername eingeben (optional)';

  @override
  String get enterProxyPassword => 'Passwort eingeben (optional)';

  @override
  String get proxyHostRequired => 'Proxy-Host ist erforderlich';

  @override
  String get proxyPortInvalid => 'Proxy-Port muss zwischen 1-65535 liegen';

  @override
  String get saved => 'Gespeichert';

  @override
  String get dataSync => 'Daten-Synchronisation';

  @override
  String get syncServerRunning => 'Sync-Server läuft';

  @override
  String get maintenance => 'Wartung';

  @override
  String get cleanupLogs => 'Alte Logs aufräumen';

  @override
  String get cleanupLogsDescription => 'Log-Dateien aufräumen';

  @override
  String get confirmCleanup => 'Aufräumen bestätigen';

  @override
  String get confirmCleanupMessage => 'Sind Sie sicher, dass Sie Log-Dateien löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cleanupSuccess => 'Aufräumen alter Logs abgeschlossen';

  @override
  String get cleanupFailed => 'Aufräumen fehlgeschlagen';

  @override
  String get syncServerStopped => 'Sync-Server gestoppt';

  @override
  String get scanQRToConnect => 'Andere Geräte scannen diesen QR-Code zum Verbinden:';

  @override
  String get addressCopied => 'Adresse in Zwischenablage kopiert';

  @override
  String get otherDevicesCanScan => 'Andere Geräte können diesen QR-Code scannen, um sich schnell zu verbinden';

  @override
  String get startServer => 'Server starten';

  @override
  String get stopServer => 'Server stoppen';

  @override
  String get connectToOtherDevices => 'Mit anderen Geräten verbinden';

  @override
  String get scanQRCode => 'QR-Code scannen zum Verbinden';

  @override
  String get connectionHistory => 'Verbindungs-Verlauf:';

  @override
  String get connect => 'Verbinden';

  @override
  String get manualInputAddress => 'Oder Server-Adresse manuell eingeben:';

  @override
  String get serverAddress => 'Server-Adresse';

  @override
  String get syncFromServer => 'Vom Server synchronisieren';

  @override
  String get pushToServer => 'Zum Server übertragen';

  @override
  String get usageInstructions => 'Nutzungsanweisungen';

  @override
  String get desktopAsServer => 'Desktop als Server:';

  @override
  String get desktopStep1 => '1. \"Server starten\" Button klicken';

  @override
  String get desktopStep2 => '2. QR-Code für Mobile zum Scannen anzeigen';

  @override
  String get desktopStep3 => '3. Mobile kann nach dem Scannen Daten synchronisieren';

  @override
  String get mobileConnect => 'Mobile-Verbindung:';

  @override
  String get mobileStep1 => '1. \"QR-Code scannen zum Verbinden\" klicken';

  @override
  String get mobileStep2 => '2. QR-Code auf Desktop scannen';

  @override
  String get mobileStep3 => '3. Sync-Richtung wählen (upload/download)';

  @override
  String get uploadDescription => '• Upload: Lokale Gerätedaten zum Server übertragen';

  @override
  String get downloadDescription => '• Download: Daten vom Server auf lokales Gerät holen';

  @override
  String get syncContent => '• Sync-Inhalt: Chat-Verlauf, Einstellungen, MCP-Konfigurationen';

  @override
  String get syncServerStarted => 'Sync-Server gestartet';

  @override
  String get syncServerStartFailed => 'Server-Start fehlgeschlagen';

  @override
  String get syncServerStopFailed => 'Server-Stopp fehlgeschlagen';

  @override
  String get scanQRCodeTitle => 'QR-Code scannen';

  @override
  String get flashOn => 'Blitz an';

  @override
  String get flashOff => 'Blitz aus';

  @override
  String get aimQRCode => 'QR-Code auf den Scan-Rahmen richten';

  @override
  String get scanSyncQRCode => 'Sync QR-Code auf Desktop scannen';

  @override
  String get manualInputAddressButton => 'Adresse manuell eingeben';

  @override
  String get manualInputServerAddress => 'Server-Adresse manuell eingeben';

  @override
  String get enterValidServerAddress => 'Bitte gültige Server-Adresse eingeben';

  @override
  String scanSuccessConnectTo(Object deviceName) {
    return 'Scan erfolgreich, verbunden mit: $deviceName';
  }

  @override
  String get scanSuccessAddressFilled => 'Scan erfolgreich, Server-Adresse ausgefüllt';

  @override
  String get scannerOpenFailed => 'Scanner-Öffnung fehlgeschlagen';

  @override
  String get pleaseInputServerAddress => 'Bitte zuerst QR-Code scannen oder Server-Adresse eingeben';

  @override
  String get connectingToServer => 'Verbindung zum Server...';

  @override
  String get downloadingData => 'Daten werden heruntergeladen...';

  @override
  String get importingData => 'Daten werden importiert...';

  @override
  String get reinitializingData => 'App-Daten werden neu initialisiert...';

  @override
  String get dataSyncSuccess => 'Daten-Synchronisation erfolgreich';

  @override
  String get preparingData => 'Daten werden vorbereitet...';

  @override
  String get uploadingData => 'Daten werden hochgeladen...';

  @override
  String get dataPushSuccess => 'Daten-Übertragung erfolgreich';

  @override
  String get syncFailed => 'Synchronisation fehlgeschlagen';

  @override
  String get pushFailed => 'Übertragung fehlgeschlagen';

  @override
  String get justNow => 'Gerade eben';

  @override
  String minutesAgo(Object minutes) {
    return 'vor $minutes Minuten';
  }

  @override
  String hoursAgo(Object hours) {
    return 'vor $hours Stunden';
  }

  @override
  String daysAgo(Object days) {
    return 'vor $days Tagen';
  }

  @override
  String serverSelected(Object deviceName) {
    return 'Server ausgewählt: $deviceName';
  }

  @override
  String get connectionRecordDeleted => 'Verbindungseintrag gelöscht';

  @override
  String viewAllConnections(Object count) {
    return 'Alle $count Verbindungen anzeigen';
  }

  @override
  String get clearAllHistory => 'Alles löschen';

  @override
  String get clearAllConnectionHistory => 'Gesamter Verbindungs-Verlauf gelöscht';

  @override
  String get unknownDevice => 'Unbekanntes Gerät';

  @override
  String get unknownPlatform => 'Unbekannte Plattform';

  @override
  String get inmemory => 'Im Speicher';

  @override
  String get toggleSidebar => 'Seitenleiste umschalten';

  @override
  String get deleteChat => 'Chat löschen';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get newChat => 'Neuer Chat';

  @override
  String get send => 'Senden';

  @override
  String get more => 'Mehr';

  @override
  String get noMoreData => 'Keine weiteren Daten';
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


  @override
  String loadFailed(Object error) {
    return 'Failed to load: $error';
  }

  @override
  String get noServersAvailable => 'No available servers';

  @override
  String get serverToolsInfo => 'Server tools information';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get loading => 'Loading...';

  @override
  String get noCodePreview => 'No code preview';

  @override
  String get tokenUsage => 'Token Usage';

  @override
  String get shareChatImage => 'Share Chat Image';

  @override
  String get saveChatImage => 'Save chat image';

  @override
  String get invalidUrl => 'Invalid URL';

  @override
  String fetchModelsFailed(Object error) {
    return 'Failed to fetch models: $error';
  }

  @override
  String get deviceAuthorization => 'Device Authorization';

  @override
  String userCode(Object code) {
    return 'User Code: $code';
  }

  @override
  String get enterCodeAt => 'Please enter this code at:';

  @override
  String get deviceCodeFetched => 'Device code fetched successfully';

  @override
  String get deviceCodeFailed => 'Failed to fetch device code';

  @override
  String deviceCodeError(Object error) {
    return 'Error fetching device code: $error';
  }

  @override
  String get getDeviceCode => 'Get Device Code';

  @override
  String get tokenFetched => 'Token fetched successfully';

  @override
  String tokenFetchFailed(Object error) {
    return 'Failed to fetch token: $error';
  }

  @override
  String get getToken => 'Get Token';

  @override
  String get mcpInvalidUrl => 'Server address must be a valid URL';

  @override
  String get mcpInvalidHttpUrl => 'Server address must be a valid HTTP(S) URL';

  @override
  String get mcpMobileRemoteOnly => 'Mobile supports only MCP SSE and Streamable servers';


  @override
  String get alreadyUpToDate => 'You are using the latest version';

  @override
  String get checkUpdatesFailed => 'Could not check for updates';

  @override
  String get savingImage => 'Saving image...';

  @override
  String imageSavedToDownloads(Object fileName) {
    return 'Image saved to Downloads: $fileName';
  }

  @override
  String saveImageFailed(Object error) {
    return 'Failed to save image: $error';
  }

  @override
  String latexError(Object error) {
    return 'LaTeX error: $error';
  }

  @override
  String errorType(Object type) {
    return 'Error type: $type';
  }

  @override
  String get createdWithChatMcp => 'Created with ChatMCP';

}
