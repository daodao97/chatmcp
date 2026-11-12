// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (ru).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get settings => 'Настройки';

  @override
  String get general => 'Общие';

  @override
  String get providers => 'Провайдеры';

  @override
  String get mcpServer => 'MCP-серверы';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get dark => 'Тёмная';

  @override
  String get light => 'Светлая';

  @override
  String get system => 'Системная';

  @override
  String get languageSettings => 'Язык интерфейса';

  @override
  String get featureSettings => 'Дополнительные функции';

  @override
  String get enableArtifacts => 'Артефакты';

  @override
  String get enableArtifactsDescription => 'Позволяет ИИ создавать артефакты в чате. Может увеличить расход токенов.';

  @override
  String get enableToolUsage => 'Использовать инструменты';

  @override
  String get enableToolUsageDescription => 'Разрешает ИИ вызывать инструменты в чате. Может увеличить расход токенов.';

  @override
  String get themeSettings => 'Оформление';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get followSystem => 'Системная тема';

  @override
  String get showAvatar => 'Аватары в чате';

  @override
  String get showAssistantAvatar => 'Показывать аватар ассистента';

  @override
  String get showAssistantAvatarDescription => 'Отображать аватар ИИ-ассистента рядом с его сообщениями';

  @override
  String get showUserAvatar => 'Показывать мой аватар';

  @override
  String get showUserAvatarDescription => 'Отображать ваш аватар рядом с вашими сообщениями';

  @override
  String get systemPrompt => 'Системный промпт';

  @override
  String get systemPromptDescription => 'Определяет поведение и стиль ответов ИИ-ассистента';

  @override
  String get llmKey => 'Ключ LLM';

  @override
  String get toolKey => 'Ключ инструмента';

  @override
  String get saveSettings => 'Сохранить настройки';

  @override
  String get apiKey => 'API-ключ';

  @override
  String enterApiKey(Object provider) {
    return 'Введите API-ключ $provider';
  }

  @override
  String get apiKeyValidation => 'API-ключ должен содержать не менее 10 символов';

  @override
  String get apiEndpoint => 'Адрес API';

  @override
  String get enterApiEndpoint => 'Введите адрес API';

  @override
  String get apiVersion => 'Версия API';

  @override
  String get enterApiVersion => 'Введите версию API';

  @override
  String get platformNotSupported => 'MCP-серверы не поддерживаются на этой платформе';

  @override
  String get mcpServerDesktopOnly => 'MCP-серверы доступны только на компьютере (Windows, macOS, Linux)';

  @override
  String get searchServer => 'Поиск серверов...';

  @override
  String get noServerConfigs => 'Серверы не найдены';

  @override
  String get addMcpServer => 'Добавить MCP сервер';

  @override
  String get addProvider => 'Добавить провайдера';

  @override
  String get refresh => 'Обновить';

  @override
  String get install => 'Установить';

  @override
  String get edit => 'Изменить';

  @override
  String get delete => 'Удалить';

  @override
  String get command => 'Команда или URL';

  @override
  String get arguments => 'Аргументы';

  @override
  String get environmentVariables => 'Переменные окружения';

  @override
  String get serverName => 'Название сервера';

  @override
  String get commandExample => 'Например: npx, uvx или https://mcpserver.com';

  @override
  String get argumentsExample => 'Разделяйте аргументы пробелами, а аргументы с пробелами заключайте в кавычки. Пример: -y obsidian-mcp \'/Users/username/Documents/Obsidian Vault\'';

  @override
  String get envVarsFormat => 'По одной переменной в строке: KEY=VALUE';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get confirmDelete => 'Подтвердить удаление';

  @override
  String confirmDeleteServer(Object name) {
    return 'Удалить сервер «$name»?';
  }

  @override
  String get error => 'Ошибка';

  @override
  String commandNotExist(Object command, Object path) {
    return 'Команда «$command» не найдена. Сначала установите её.\n\nТекущий PATH:\n$path';
  }

  @override
  String get all => 'Все';

  @override
  String get installed => 'Установленные';

  @override
  String get modelSettings => 'Настройки модели';

  @override
  String temperature(Object value) {
    return 'Температура: $value';
  }

  @override
  String get temperatureTooltip => 'Определяет разнообразие ответов. Чем ниже значение, тем предсказуемее результат. Высокие значения подходят для творческих задач.';

  @override
  String topP(Object value) {
    return 'Top P: $value';
  }

  @override
  String get topPTooltip => 'Ограничивает выбор токенов по их суммарной вероятности. Чем ниже значение, тем предсказуемее ответ. Обычно изменяют либо Top P, либо температуру.';

  @override
  String get maxTokens => 'Лимит токенов';

  @override
  String get maxTokensTooltip => 'Максимальное число токенов в ответе модели. Токен может быть словом, частью слова или знаком.';

  @override
  String frequencyPenalty(Object value) {
    return 'Штраф за частоту: $value';
  }

  @override
  String get frequencyPenaltyTooltip => 'Снижает вероятность повторения токенов. Чем чаще токен уже встречался в тексте, тем сильнее штраф при положительном значении.';

  @override
  String presencePenalty(Object value) {
    return 'Штраф за присутствие: $value';
  }

  @override
  String get presencePenaltyTooltip => 'Снижает вероятность повторного использования токенов, уже встречавшихся в тексте, независимо от частоты. Помогает переходить к новым темам.';

  @override
  String get enterMaxTokens => 'Введите лимит токенов';

  @override
  String get share => 'Поделиться';

  @override
  String get modelConfig => 'Настройки модели';

  @override
  String get debug => 'Отладка';

  @override
  String get webSearchTest => 'Проверка веб-поиска';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get last7Days => 'Последние 7 дней';

  @override
  String get last30Days => 'Последние 30 дней';

  @override
  String get earlier => 'Ранее';

  @override
  String get confirmDeleteSelected => 'Удалить выбранные чаты?';

  @override
  String get confirmThisChat => 'Удалить этот чат';

  @override
  String get ok => 'ОК';

  @override
  String get askMeAnything => 'Напишите сообщение...';

  @override
  String get uploadFiles => 'Прикрепить файлы';

  @override
  String get welcomeMessage => 'Чем могу помочь?';

  @override
  String get copy => 'Копировать';

  @override
  String get copied => 'Скопировано';

  @override
  String get retry => 'Повторить';

  @override
  String get brokenImage => 'Не удалось загрузить изображение';

  @override
  String toolCall(Object name) {
    return 'Вызов инструмента: $name';
  }

  @override
  String toolResult(Object name) {
    return 'Результат вызова: $name';
  }

  @override
  String get selectModel => 'Выбрать модель';

  @override
  String get close => 'Закрыть';

  @override
  String get selectFromGallery => 'Выбрать из галереи';

  @override
  String get selectFile => 'Выбрать файл';

  @override
  String get uploadFile => 'Прикрепить файл';

  @override
  String get openBrowser => 'Открыть в браузере';

  @override
  String get codeCopiedToClipboard => 'Код скопирован';

  @override
  String get thinking => 'Размышляет';

  @override
  String get thinkingEnd => 'Размышление завершено';

  @override
  String get tool => 'Инструмент';

  @override
  String get userCancelledToolCall => 'Вызов инструмента отменён';

  @override
  String get code => 'Код';

  @override
  String get preview => 'Просмотр';

  @override
  String get loadContentFailed => 'Не удалось загрузить содержимое. Повторите попытку';

  @override
  String get openingBrowser => 'Открытие браузера...';

  @override
  String get functionCallAuth => 'Запуск инструмента';

  @override
  String get allowFunctionExecution => 'Разрешить выполнение инструмента?';

  @override
  String parameters(Object params) {
    return 'Параметры: $params';
  }

  @override
  String get allow => 'Разрешить';

  @override
  String get loadDiagramFailed => 'Не удалось загрузить диаграмму. Повторите попытку';

  @override
  String get copiedToClipboard => 'Скопировано';

  @override
  String get chinese => 'Китайский';

  @override
  String get turkish => 'Турецкий';

  @override
  String get functionRunning => 'Выполнение инструмента...';

  @override
  String get thinkingProcess => 'Размышляет';

  @override
  String get thinkingProcessWithDuration => 'Размышляет';

  @override
  String get thinkingEndWithDuration => 'Размышлял';

  @override
  String get thinkingEndComplete => 'Размышление завершено';

  @override
  String seconds(Object seconds) {
    return '$seconds с';
  }

  @override
  String get fieldRequired => 'Обязательное поле';

  @override
  String get autoApprove => 'Автоподтверждение';

  @override
  String get verify => 'Проверить ключ';

  @override
  String get howToGet => 'Как получить';

  @override
  String get modelList => 'Модели';

  @override
  String get enableModels => 'Включить модели';

  @override
  String get disableAllModels => 'Отключить все модели';

  @override
  String get saveSuccess => 'Настройки сохранены';

  @override
  String get genTitleModel => 'Модель заголовков';

  @override
  String get serverNameTooLong => 'Не более 50 символов';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get providerName => 'Название провайдера';

  @override
  String get apiStyle => 'Тип API';

  @override
  String get enterProviderName => 'Введите название провайдера';

  @override
  String get providerNameRequired => 'Укажите название провайдера';

  @override
  String get addModel => 'Добавить модель';

  @override
  String get modelName => 'Название модели';

  @override
  String get enterModelName => 'Введите название модели';

  @override
  String get noApiConfigs => 'Нет настроек API';

  @override
  String get add => 'Добавить';

  @override
  String get fetch => 'Загрузить';

  @override
  String get on => 'Вкл.';

  @override
  String get off => 'Выкл.';

  @override
  String get apiUrl => 'Адрес API';

  @override
  String get selectApiStyle => 'Выберите тип API';

  @override
  String get serverType => 'Тип сервера';

  @override
  String get reset => 'Сбросить';

  @override
  String get start => 'Запустить';

  @override
  String get stop => 'Остановить';

  @override
  String get search => 'Поиск';

  @override
  String newVersionFound(Object version) {
    return 'Доступна версия $version';
  }

  @override
  String get newVersionAvailable => 'Доступна новая версия';

  @override
  String get updateNow => 'Обновить сейчас';

  @override
  String get updateLater => 'Позже';

  @override
  String get ignoreThisVersion => 'Пропустить эту версию';

  @override
  String get releaseNotes => 'Что нового:';

  @override
  String get openUrlFailed => 'Не удалось открыть ссылку';

  @override
  String get checkingForUpdates => 'Проверка обновлений...';

  @override
  String get checkUpdate => 'Проверить обновления';

  @override
  String get appDescription => 'ChatMCP — кроссплатформенный ИИ-клиент, который делает искусственный интеллект доступнее.';

  @override
  String get visitWebsite => 'Сайт';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get networkError => 'Ошибка сети';

  @override
  String get noElementError => 'Элемент не найден';

  @override
  String get permissionError => 'Доступ запрещён';

  @override
  String get unknownError => 'Неизвестная ошибка';

  @override
  String get timeoutError => 'Превышено время ожидания';

  @override
  String get notFoundError => 'Ресурс не найден';

  @override
  String get invalidError => 'Некорректный запрос';

  @override
  String get unauthorizedError => 'Нет прав доступа';

  @override
  String get minimize => 'Свернуть';

  @override
  String get maximize => 'Развернуть';

  @override
  String get conversationSettings => 'Настройки чата';

  @override
  String get maxMessages => 'Лимит сообщений';

  @override
  String get maxMessagesDescription => 'Максимум сообщений, передаваемых модели (1–1000)';

  @override
  String get maxLoops => 'Лимит циклов';

  @override
  String get maxLoopsDescription => 'Максимум циклов вызова инструментов (1–1000). Защищает от зацикливания';

  @override
  String get mcpServers => 'MCP-серверы';

  @override
  String get getApiKey => 'Получить API-ключ';

  @override
  String get proxySettings => 'Прокси-сервер';

  @override
  String get enableProxy => 'Использовать прокси';

  @override
  String get enableProxyDescription => 'Направлять сетевые запросы приложения через указанный прокси-сервер';

  @override
  String get proxyType => 'Тип прокси';

  @override
  String get proxyHost => 'Адрес прокси-сервера';

  @override
  String get proxyPort => 'Порт';

  @override
  String get proxyUsername => 'Имя пользователя';

  @override
  String get proxyPassword => 'Пароль';

  @override
  String get enterProxyHost => 'Введите адрес прокси-сервера';

  @override
  String get enterProxyPort => 'Введите порт прокси-сервера';

  @override
  String get enterProxyUsername => 'Имя пользователя (необязательно)';

  @override
  String get enterProxyPassword => 'Пароль (необязательно)';

  @override
  String get proxyHostRequired => 'Укажите адрес прокси-сервера';

  @override
  String get proxyPortInvalid => 'Номер порта должен быть от 1 до 65535';

  @override
  String get saved => 'Сохранено';

  @override
  String get dataSync => 'Синхронизация';

  @override
  String get syncServerRunning => 'Сервер синхронизации запущен';

  @override
  String get maintenance => 'Обслуживание';

  @override
  String get cleanupLogs => 'Удалить журналы';

  @override
  String get cleanupLogsDescription => 'Удалить файлы журналов приложения';

  @override
  String get confirmCleanup => 'Удалить журналы?';

  @override
  String get confirmCleanupMessage => 'Файлы журналов будут удалены без возможности восстановления.';

  @override
  String get cleanupSuccess => 'Файлы журналов удалены';

  @override
  String get cleanupFailed => 'Не удалось удалить файлы журналов';

  @override
  String get syncServerStopped => 'Сервер синхронизации остановлен';

  @override
  String get scanQRToConnect => 'Отсканируйте этот QR-код на другом устройстве:';

  @override
  String get addressCopied => 'Адрес скопирован';

  @override
  String get otherDevicesCanScan => 'Другие устройства могут подключиться по этому QR-коду';

  @override
  String get startServer => 'Запустить сервер';

  @override
  String get stopServer => 'Остановить сервер';

  @override
  String get connectToOtherDevices => 'Подключить другие устройства';

  @override
  String get scanQRCode => 'Сканировать QR-код';

  @override
  String get connectionHistory => 'История подключений';

  @override
  String get connect => 'Подключиться';

  @override
  String get manualInputAddress => 'Или введите адрес сервера:';

  @override
  String get serverAddress => 'Адрес сервера';

  @override
  String get syncFromServer => 'Скачать с сервера';

  @override
  String get pushToServer => 'Отправить на сервер';

  @override
  String get usageInstructions => 'Как пользоваться';

  @override
  String get desktopAsServer => 'Компьютер — сервер:';

  @override
  String get desktopStep1 => '1. Нажмите «Запустить сервер»';

  @override
  String get desktopStep2 => '2. На экране появится QR-код';

  @override
  String get desktopStep3 => '3. Отсканируйте код телефоном для синхронизации';

  @override
  String get mobileConnect => 'Подключение телефона:';

  @override
  String get mobileStep1 => '1. Нажмите «Сканировать QR-код»';

  @override
  String get mobileStep2 => '2. Отсканируйте QR-код на компьютере';

  @override
  String get mobileStep3 => '3. Выберите направление синхронизации';

  @override
  String get uploadDescription => '• Отправка: данные устройства передаются на сервер';

  @override
  String get downloadDescription => '• Загрузка: данные скачиваются с сервера на устройство';

  @override
  String get syncContent => '• Синхронизируются: история чатов, настройки, MCP-серверы';

  @override
  String get syncServerStarted => 'Сервер синхронизации запущен';

  @override
  String get syncServerStartFailed => 'Не удалось запустить сервер';

  @override
  String get syncServerStopFailed => 'Не удалось остановить сервер';

  @override
  String get scanQRCodeTitle => 'Сканирование QR-кода';

  @override
  String get flashOn => 'Включить фонарик';

  @override
  String get flashOff => 'Выключить фонарик';

  @override
  String get aimQRCode => 'Наведите камеру на QR-код';

  @override
  String get scanSyncQRCode => 'Отсканируйте QR-код с компьютера';

  @override
  String get manualInputAddressButton => 'Ввести адрес вручную';

  @override
  String get manualInputServerAddress => 'Ввод адреса сервера';

  @override
  String get enterValidServerAddress => 'Введите корректный адрес сервера';

  @override
  String scanSuccessConnectTo(Object deviceName) {
    return 'Найден сервер: $deviceName';
  }

  @override
  String get scanSuccessAddressFilled => 'QR-код считан, адрес сервера заполнен';

  @override
  String get scannerOpenFailed => 'Не удалось открыть сканер';

  @override
  String get pleaseInputServerAddress => 'Сначала отсканируйте QR-код или введите адрес';

  @override
  String get connectingToServer => 'Подключение к серверу...';

  @override
  String get downloadingData => 'Скачивание данных...';

  @override
  String get importingData => 'Импорт данных...';

  @override
  String get reinitializingData => 'Переинициализация данных приложения...';

  @override
  String get dataSyncSuccess => 'Данные синхронизированы';

  @override
  String get preparingData => 'Подготовка данных...';

  @override
  String get uploadingData => 'Отправка данных...';

  @override
  String get dataPushSuccess => 'Данные отправлены';

  @override
  String get syncFailed => 'Ошибка синхронизации';

  @override
  String get pushFailed => 'Не удалось отправить данные';

  @override
  String get justNow => 'Только что';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes мин. назад';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours ч. назад';
  }

  @override
  String daysAgo(Object days) {
    return '$days дн. назад';
  }

  @override
  String serverSelected(Object deviceName) {
    return 'Выбран сервер: $deviceName';
  }

  @override
  String get connectionRecordDeleted => 'Запись удалена';

  @override
  String viewAllConnections(Object count) {
    return 'Все подключения ($count)';
  }

  @override
  String get clearAllHistory => 'Очистить историю';

  @override
  String get clearAllConnectionHistory => 'История подключений очищена';

  @override
  String get unknownDevice => 'Неизвестное устройство';

  @override
  String get unknownPlatform => 'Неизвестная платформа';

  @override
  String get inmemory => 'Встроенные';

  @override
  String get toggleSidebar => 'Показать/скрыть панель';

  @override
  String get deleteChat => 'Удалить чат';

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get newChat => 'Новый чат';

  @override
  String get send => 'Отправить';

  @override
  String get more => 'Ещё';

  @override
  String get noMoreData => 'Больше нет чатов';

  @override
  String get oauthRefreshToken => 'Обновить OAuth-токен';

  @override
  String get oauthAuthenticated => 'Вход через OAuth выполнен';

  @override
  String get oauthSignIn => 'Войти через OAuth';

  @override
  String get oauthTokenRefreshed => 'Токен обновлён';

  @override
  String get oauthSignInSuccess => 'Авторизация выполнена';

  @override
  String oauthError(Object error) {
    return 'Ошибка OAuth: $error';
  }

  @override
  String get oauthChecking => 'Проверка авторизации...';

  @override
  String get oauthLoginAfterSave => 'Сервер требует авторизации через OAuth. После сохранения появится запрос на вход.';

  @override
  String get oauthSectionTitle => 'Авторизация';

  @override
  String get oauthAutomaticLoginInfo => 'Если сервер требует авторизации, после сохранения появится запрос на вход.';

  @override
  String get oauthRequired => 'Требуется авторизация';

  @override
  String get oauthLoginPrompt => 'Сервер требует авторизации через OAuth. Войти сейчас?';

  @override
  String get oauthLoginNow => 'Войти';

  @override
  String oauthSuccessForServer(Object serverName) {
    return 'Вход на сервер «$serverName» выполнен';
  }

  @override
  String get oauthNoSuccessResponse => 'Не удалось войти: нет подтверждения авторизации';

  @override
  String oauthSignInFailed(Object error) {
    return 'Не удалось войти: $error';
  }

  @override
  String loadFailed(Object error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String get noServersAvailable => 'Нет доступных серверов';

  @override
  String get serverToolsInfo => 'Информация об инструментах сервера';

  @override
  String get noResultsFound => 'Ничего не найдено';

  @override
  String get loading => 'Загрузка...';

  @override
  String get noCodePreview => 'Предпросмотр недоступен';

  @override
  String get tokenUsage => 'Расход токенов';

  @override
  String get shareChatImage => 'Поделиться изображением чата';

  @override
  String get saveChatImage => 'Сохранить изображение чата';

  @override
  String get invalidUrl => 'Некорректный URL';

  @override
  String fetchModelsFailed(Object error) {
    return 'Не удалось загрузить модели: $error';
  }

  @override
  String get deviceAuthorization => 'Авторизация устройства';

  @override
  String userCode(Object code) {
    return 'Код для входа: $code';
  }

  @override
  String get enterCodeAt => 'Введите этот код на сайте:';

  @override
  String get deviceCodeFetched => 'Код получен';

  @override
  String get deviceCodeFailed => 'Не удалось получить код';

  @override
  String deviceCodeError(Object error) {
    return 'Ошибка получения кода: $error';
  }

  @override
  String get getDeviceCode => 'Получить код';

  @override
  String get tokenFetched => 'Токен получен';

  @override
  String tokenFetchFailed(Object error) {
    return 'Не удалось получить токен: $error';
  }

  @override
  String get getToken => 'Получить токен';

  @override
  String get mcpInvalidUrl => 'Укажите корректный URL сервера';

  @override
  String get mcpInvalidHttpUrl => 'Укажите корректный URL сервера (http/https)';

  @override
  String get mcpMobileRemoteOnly => 'На мобильных устройствах доступны только MCP-серверы SSE и Streamable';

  @override
  String get alreadyUpToDate => 'Установлена последняя версия';

  @override
  String get checkUpdatesFailed => 'Не удалось проверить обновления';

  @override
  String get savingImage => 'Сохранение изображения...';

  @override
  String imageSavedToDownloads(Object fileName) {
    return 'Изображение сохранено в «Загрузки»: $fileName';
  }

  @override
  String saveImageFailed(Object error) {
    return 'Не удалось сохранить изображение: $error';
  }

  @override
  String latexError(Object error) {
    return 'Ошибка LaTeX: $error';
  }

  @override
  String errorType(Object type) {
    return 'Тип ошибки: $type';
  }

  @override
  String get createdWithChatMcp => 'Создано в ChatMCP';

}
