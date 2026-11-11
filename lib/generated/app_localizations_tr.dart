// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get settings => 'Ayarlar';

  @override
  String get general => 'Genel';

  @override
  String get providers => 'Sağlayıcılar';

  @override
  String get mcpServer => 'MCP Sunucusu';

  @override
  String get language => 'Dil';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Koyu';

  @override
  String get light => 'Açık';

  @override
  String get system => 'Sistem';

  @override
  String get languageSettings => 'Dil Ayarları';

  @override
  String get featureSettings => 'Özellik Ayarları';

  @override
  String get enableArtifacts => 'Artifact\'leri Etkinleştir';

  @override
  String get enableArtifactsDescription => 'Sohbette yapay zeka asistanının Artifact\'lerini etkinleştirir, bu özellik daha fazla token kullanır.';

  @override
  String get enableToolUsage => 'Araç Kullanımını Etkinleştir';

  @override
  String get enableToolUsageDescription => 'Sohbette araçların kullanımını etkinleştirir, bu özellik daha fazla token kullanır.';

  @override
  String get themeSettings => 'Tema Ayarları';

  @override
  String get lightTheme => 'Açık Tema';

  @override
  String get darkTheme => 'Koyu Tema';

  @override
  String get followSystem => 'Sistem Ayarlarına Uygula';

  @override
  String get showAvatar => 'Avatar Gösterimi';

  @override
  String get showAssistantAvatar => 'Asistan Avatarını Göster';

  @override
  String get showAssistantAvatarDescription => 'Sohbette yapay zeka asistanının avatarını gösterir.';

  @override
  String get showUserAvatar => 'Kullanıcı Avatarını Göster';

  @override
  String get showUserAvatarDescription => 'Sohbette kullanıcının avatarını gösterir.';

  @override
  String get systemPrompt => 'Sistem Prompt';

  @override
  String get systemPromptDescription => 'Bu, yapay zeka asistanının davranışını ve tarzını belirlemek için kullanılan sistem yönergesidir.';

  @override
  String get llmKey => 'LLM Anahtarı';

  @override
  String get toolKey => 'Araç Anahtarı';

  @override
  String get saveSettings => 'Ayarları Kaydet';

  @override
  String get apiKey => 'API Anahtarı';

  @override
  String enterApiKey(Object provider) {
    return '$provider API Anahtarınızı Girin';
  }

  @override
  String get apiKeyValidation => 'API Anahtarı en az 10 karakter olmalıdır.';

  @override
  String get apiEndpoint => 'API Uç Noktası';

  @override
  String get enterApiEndpoint => 'API uç noktası URL\'sini girin';

  @override
  String get apiVersion => 'API Versiyonu';

  @override
  String get enterApiVersion => 'API versiyonunu girin';

  @override
  String get platformNotSupported => 'Mevcut platform MCP Sunucusunu desteklemiyor.';

  @override
  String get mcpServerDesktopOnly => 'MCP Sunucusu yalnızca masaüstü platformlarını (Windows, macOS, Linux) destekler.';

  @override
  String get searchServer => 'Sunucu ara...';

  @override
  String get noServerConfigs => 'Sunucu yapılandırması bulunamadı.';

  @override
  String get addMcpServer => 'MCP Sunucusu Ekle';

  @override
  String get addProvider => 'Sağlayıcı Ekle';

  @override
  String get refresh => 'Yenile';

  @override
  String get install => 'Yükle';

  @override
  String get edit => 'Düzenle';

  @override
  String get delete => 'Sil';

  @override
  String get command => 'Komut veya Sunucu Adresi';

  @override
  String get arguments => 'Argümanlar';

  @override
  String get environmentVariables => 'Ortam Değişkenleri';

  @override
  String get serverName => 'Sunucu Adı';

  @override
  String get commandExample => 'Örneğin: npx, uvx, https://mcpserver.com';

  @override
  String get argumentsExample =>
      'Argümanları boşlukla ayırın. Boşluk içerenler için tırnak işareti kullanın, örn: -y obsidian-mcp \'/Kullanıcılar/kullaniciadi/Belgeler/Obsidian Kasası\'';

  @override
  String get envVarsFormat => 'Her satıra bir tane, ANAHTAR=DEĞER formatında';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get confirmDelete => 'Silmeyi Onayla';

  @override
  String confirmDeleteServer(Object name) {
    return '\"$name\" adlı sunucuyu silmek istediğinize emin misiniz?';
  }

  @override
  String get error => 'Hata';

  @override
  String commandNotExist(Object command, Object path) {
    return '\"$command\" komutu bulunamadı. Lütfen önce bu komutu yükleyin.\n\nMevcut PATH:\n$path';
  }

  @override
  String get all => 'Tümü';

  @override
  String get installed => 'Yüklü';

  @override
  String get modelSettings => 'Model Ayarları';

  @override
  String temperature(Object value) {
    return 'Temperature: $value';
  }

  @override
  String get temperatureTooltip =>
      'Temperature , çıktının rastgeleliğini kontrol eder:\n• 0.0: Kod üretimi ve matematiksel problemler için idealdir.\n• 1.0: Veri çıkarma ve analiz için uygundur.\n• 1.3: Genel sohbet ve çeviri için uygundur.\n• 1.5: Yaratıcı yazarlık ve şiir için harikadır.';

  @override
  String topP(Object value) {
    return 'Çekirdek Örnekleme (Top P): $value';
  }

  @override
  String get topPTooltip =>
      'Top P (Çekirdek Örnekleme), sıcaklık parametresine bir alternatiftir. Model, yalnızca kümülatif olasılığı P\'yi aşan token\'ları dikkate alır. Sıcaklık ve top_p değerlerini aynı anda değiştirmeniz önerilmez.';

  @override
  String get maxTokens => 'Maksimum Token';

  @override
  String get maxTokensTooltip =>
      'Üretilecek maksimum token sayısı. Bir token yaklaşık 4 karaktere eşittir. Daha uzun sohbetler daha fazla token gerektirir.';

  @override
  String frequencyPenalty(Object value) {
    return 'Frequency Cezası: $value';
  }

  @override
  String get frequencyPenaltyTooltip =>
      'Frequency cezası parametresi. Pozitif değerler, metindeki mevcut frekanslarına göre yeni token\'ları cezalandırarak modelin aynı içeriği kelimesi kelimesine tekrarlama olasılığını azaltır.';

  @override
  String presencePenalty(Object value) {
    return 'Presence Cezası: $value';
  }

  @override
  String get presencePenaltyTooltip =>
      'Presence cezası parametresi. Pozitif değerler, metinde daha önce geçip geçmediklerine göre yeni token\'ları cezalandırarak modelin yeni konular hakkında konuşma olasılığını artırır.';

  @override
  String get enterMaxTokens => 'Maksimum token sayısını girin';

  @override
  String get share => 'Paylaş';

  @override
  String get modelConfig => 'Model Ayarları';

  @override
  String get debug => 'Debug Modu';

  @override
  String get webSearchTest => 'Web Araması Testi';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get last7Days => 'Son 7 Gün';

  @override
  String get last30Days => 'Son 30 Gün';

  @override
  String get earlier => 'Daha Eski';

  @override
  String get confirmDeleteSelected => 'Seçili sohbetleri silmek istediğinize emin misiniz?';

  @override
  String get confirmThisChat => 'Bu sohbetleri silmek istediğinize emin misiniz?';

  @override
  String get ok => 'Tamam';

  @override
  String get askMeAnything => 'Aklındakini sor...';

  @override
  String get uploadFiles => 'Dosya Yükle';

  @override
  String get welcomeMessage => 'Bugün sana nasıl yardımcı olabilirim?';

  @override
  String get copy => 'Kopyala';

  @override
  String get copied => 'Panoya kopyalandı!';

  @override
  String get retry => 'Yeniden Dene';

  @override
  String get brokenImage => 'Bozuk Resim';

  @override
  String toolCall(Object name) {
    return '$name çağrılıyor';
  }

  @override
  String toolResult(Object name) {
    return '$name çağrısının sonucu';
  }

  @override
  String get selectModel => 'Model Seç';

  @override
  String get close => 'Kapat';

  @override
  String get selectFromGallery => 'Galeriden Seç';

  @override
  String get selectFile => 'Dosya Seç';

  @override
  String get uploadFile => 'Dosya Yükle';

  @override
  String get openBrowser => 'Tarayıcıda Aç';

  @override
  String get codeCopiedToClipboard => 'Kod panoya kopyalandı.';

  @override
  String get thinking => 'Düşünüyor...';

  @override
  String get thinkingEnd => 'Düşünme tamamlandı.';

  @override
  String get tool => 'Araç';

  @override
  String get userCancelledToolCall => 'Araç çalıştırılamadı.';

  @override
  String get code => 'Kod';

  @override
  String get preview => 'Önizleme';

  @override
  String get loadContentFailed => 'İçerik yüklenemedi, lütfen tekrar deneyin.';

  @override
  String get openingBrowser => 'Tarayıcı açılıyor...';

  @override
  String get functionCallAuth => 'Araç Kullanım İzni';

  @override
  String get allowFunctionExecution => 'Aşağıdaki aracın çalışmasına izin veriyor musunuz?';

  @override
  String parameters(Object params) {
    return 'Parametreler: $params';
  }

  @override
  String get allow => 'İzin Ver';

  @override
  String get loadDiagramFailed => 'Diyagram yüklenemedi, lütfen tekrar deneyin.';

  @override
  String get copiedToClipboard => 'Panoya kopyalandı.';

  @override
  String get chinese => 'Çince';

  @override
  String get turkish => 'Türkçe';

  @override
  String get functionRunning => 'Araç çalıştırılıyor...';

  @override
  String get thinkingProcess => 'Düşünme Süreci ...';

  @override
  String get thinkingProcessWithDuration => 'Düşünme, geçen süre';

  @override
  String get thinkingEndWithDuration => 'Düşünme tamamlandı, geçen süre';

  @override
  String get thinkingEndComplete => 'Düşünme tamamlandı';

  @override
  String seconds(Object seconds) {
    return '${seconds}sn';
  }

  @override
  String get fieldRequired => 'Bu alan zorunludur.';

  @override
  String get autoApprove => 'Otomatik Onayla';

  @override
  String get verify => 'Anahtarı Doğrula';

  @override
  String get howToGet => 'Nasıl alınır?';

  @override
  String get modelList => 'Model Listesi';

  @override
  String get enableModels => 'Modelleri Etkinleştir';

  @override
  String get disableAllModels => 'Tüm Modelleri Devre Dışı Bırak';

  @override
  String get saveSuccess => 'Ayarlar başarıyla kaydedildi!';

  @override
  String get genTitleModel => 'Başlık Oluşturma Modeli';

  @override
  String get serverNameTooLong => 'Sunucu adı 50 karakterden uzun olamaz.';

  @override
  String get confirm => 'Onayla';

  @override
  String get providerName => 'Sağlayıcı Adı';

  @override
  String get apiStyle => 'API Tarzı';

  @override
  String get enterProviderName => 'Sağlayıcı adını girin';

  @override
  String get providerNameRequired => 'Sağlayıcı adı zorunludur.';

  @override
  String get addModel => 'Model Ekle';

  @override
  String get modelName => 'Model Adı';

  @override
  String get enterModelName => 'Model adını girin';

  @override
  String get noApiConfigs => 'Kullanılabilir API yapılandırması yok.';

  @override
  String get add => 'Ekle';

  @override
  String get fetch => 'Getir';

  @override
  String get on => 'AÇIK';

  @override
  String get off => 'KAPALI';

  @override
  String get apiUrl => 'API Adresi';

  @override
  String get selectApiStyle => 'Lütfen bir API tarzı seçin';

  @override
  String get serverType => 'Sunucu Türü';

  @override
  String get reset => 'Sıfırla';

  @override
  String get start => 'Başlat';

  @override
  String get stop => 'Durdur';

  @override
  String get search => 'Ara';

  @override
  String newVersionFound(Object version) {
    return 'Yeni bir $version sürümü mevcut!';
  }

  @override
  String get newVersionAvailable => 'Yeni Sürüm Mevcut';

  @override
  String get updateNow => 'Şimdi Güncelle';

  @override
  String get updateLater => 'Daha Sonra';

  @override
  String get ignoreThisVersion => 'Bu Sürümü Atla';

  @override
  String get releaseNotes => 'Sürüm Notları:';

  @override
  String get openUrlFailed => 'Bağlantı açılamadı.';

  @override
  String get checkingForUpdates => 'Güncellemeler kontrol ediliyor...';

  @override
  String get checkUpdate => 'Güncellemeleri Kontrol Et';

  @override
  String get appDescription => 'ChatMCP, yapay zekayı daha fazla insana ulaştırmayı hedefleyen, platformlar arası bir yapay zeka istemcisidir.';

  @override
  String get visitWebsite => 'Web Sitesi';

  @override
  String get aboutApp => 'Hakkında';

  @override
  String get networkError => 'Ağ bağlantı hatası. Lütfen internetinizi kontrol edip tekrar deneyin.';

  @override
  String get noElementError => 'Eşleşen içerik bulunamadı, lütfen tekrar deneyin.';

  @override
  String get permissionError => 'Yetersiz izin. Lütfen ayarlarınızı kontrol edin.';

  @override
  String get unknownError => 'Bilinmeyen bir hata oluştu.';

  @override
  String get timeoutError => 'İstek zaman aşımına uğradı. Lütfen bir süre sonra tekrar deneyin.';

  @override
  String get notFoundError => 'İstenen kaynak bulunamadı.';

  @override
  String get invalidError => 'Geçersiz istek veya parametre.';

  @override
  String get unauthorizedError => 'Yetkisiz erişim. Lütfen izinlerinizi kontrol edin.';

  @override
  String get minimize => 'Küçült';

  @override
  String get maximize => 'Büyüt';

  @override
  String get conversationSettings => 'Sohbet Ayarları';

  @override
  String get maxMessages => 'Maksimum Mesaj Sayısı';

  @override
  String get maxMessagesDescription => 'LLM\'e gönderilecek maksimum mesaj sayısını sınırlar (1-1000).';

  @override
  String get maxLoops => 'Maksimum Döngü Sayısı';

  @override
  String get maxLoopsDescription => 'Sonsuz döngüleri önlemek için araç çağırma döngü sayısını sınırlar (1-1000).';

  @override
  String get mcpServers => 'MCP Sunucuları';

  @override
  String get getApiKey => 'API Anahtarı Al';

  @override
  String get proxySettings => 'Proxy Ayarları';

  @override
  String get enableProxy => 'Proxy\'yi Etkinleştir';

  @override
  String get enableProxyDescription => 'Etkinleştirildiğinde, ağ istekleri yapılandırılan proxy sunucu üzerinden gidecektir';

  @override
  String get proxyType => 'Proxy Türü';

  @override
  String get proxyHost => 'Proxy Adresi';

  @override
  String get proxyPort => 'Proxy Portu';

  @override
  String get proxyUsername => 'Kullanıcı Adı';

  @override
  String get proxyPassword => 'Şifre';

  @override
  String get enterProxyHost => 'Proxy sunucu adresini girin';

  @override
  String get enterProxyPort => 'Proxy portunu girin';

  @override
  String get enterProxyUsername => 'Kullanıcı adını girin (isteğe bağlı)';

  @override
  String get enterProxyPassword => 'Şifreyi girin (isteğe bağlı)';

  @override
  String get proxyHostRequired => 'Proxy adresi zorunludur';

  @override
  String get proxyPortInvalid => 'Proxy portu 1-65535 arasında olmalıdır';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get dataSync => 'Veri Senkronizasyonu';

  @override
  String get syncServerRunning => 'Senkronizasyon sunucusu çalışıyor';

  @override
  String get maintenance => 'Bakım';

  @override
  String get cleanupLogs => 'Eski Günlükleri Temizle';

  @override
  String get cleanupLogsDescription => 'Günlük dosyalarını temizle';

  @override
  String get confirmCleanup => 'Temizlemeyi Onayla';

  @override
  String get confirmCleanupMessage => 'Günlük dosyalarını silmek istediğinize emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get cleanupSuccess => 'Eski günlükler temizlendi';

  @override
  String get cleanupFailed => 'Temizleme başarısız';

  @override
  String get syncServerStopped => 'Senkronizasyon sunucusu durduruldu';

  @override
  String get scanQRToConnect => 'Diğer cihazlar bağlanmak için bu QR kodu tarayabilir:';

  @override
  String get addressCopied => 'Adres panoya kopyalandı';

  @override
  String get otherDevicesCanScan => 'Diğer cihazlar hızlı bağlantı için bu QR kodu tarayabilir';

  @override
  String get startServer => 'Sunucuyu Başlat';

  @override
  String get stopServer => 'Sunucuyu Durdur';

  @override
  String get connectToOtherDevices => 'Diğer Cihazlara Bağlan';

  @override
  String get scanQRCode => 'QR Kod Tarayarak Bağlan';

  @override
  String get connectionHistory => 'Bağlantı Geçmişi:';

  @override
  String get connect => 'Bağlan';

  @override
  String get manualInputAddress => 'Veya sunucu adresini manuel olarak girin:';

  @override
  String get serverAddress => 'Sunucu Adresi';

  @override
  String get syncFromServer => 'Sunucudan Senkronize Et';

  @override
  String get pushToServer => 'Sunucuya Gönder';

  @override
  String get usageInstructions => 'Kullanım Talimatları';

  @override
  String get desktopAsServer => 'Masaüstü Sunucu Olarak:';

  @override
  String get desktopStep1 => '1. \"Sunucuyu Başlat\" düğmesine tıklayın';

  @override
  String get desktopStep2 => '2. Mobil cihazın taraması için QR kodu gösterin';

  @override
  String get desktopStep3 => '3. Mobil cihaz tarama sonrası veri senkronizasyonu yapabilir';

  @override
  String get mobileConnect => 'Mobil Bağlantı:';

  @override
  String get mobileStep1 => '1. \"QR Kod Tarayarak Bağlan\" düğmesine tıklayın';

  @override
  String get mobileStep2 => '2. Masaüstünde gösterilen QR kodu tarayın';

  @override
  String get mobileStep3 => '3. Senkronizasyon yönünü seçin (yükleme/indirme)';

  @override
  String get uploadDescription => '• Yükleme: Yerel cihaz verilerini sunucuya gönder';

  @override
  String get downloadDescription => '• İndirme: Sunucudan yerel cihaza veri al';

  @override
  String get syncContent => '• Senkronizasyon İçeriği: Sohbet geçmişi, ayarlar, MCP yapılandırmaları';

  @override
  String get syncServerStarted => 'Senkronizasyon sunucusu başlatıldı';

  @override
  String get syncServerStartFailed => 'Sunucu başlatılamadı';

  @override
  String get syncServerStopFailed => 'Sunucu durdurulamadı';

  @override
  String get scanQRCodeTitle => 'QR Kod Tarama';

  @override
  String get flashOn => 'Flaş Açık';

  @override
  String get flashOff => 'Flaş Kapalı';

  @override
  String get aimQRCode => 'QR kodu tarama çerçevesine hizalayın';

  @override
  String get scanSyncQRCode => 'Masaüstünde gösterilen senkronizasyon QR kodunu tarayın';

  @override
  String get manualInputAddressButton => 'Manuel Adres Girişi';

  @override
  String get manualInputServerAddress => 'Sunucu Adresini Manuel Olarak Girin';

  @override
  String get enterValidServerAddress => 'Lütfen geçerli bir sunucu adresi girin';

  @override
  String scanSuccessConnectTo(Object deviceName) {
    return 'Tarama başarılı, bağlanıldı: $deviceName';
  }

  @override
  String get scanSuccessAddressFilled => 'Tarama başarılı, sunucu adresi dolduruldu';

  @override
  String get scannerOpenFailed => 'Tarayıcı açılamadı';

  @override
  String get pleaseInputServerAddress => 'Lütfen önce QR kodu tarayın veya sunucu adresi girin';

  @override
  String get connectingToServer => 'Sunucuya bağlanıyor...';

  @override
  String get downloadingData => 'Veri indiriliyor...';

  @override
  String get importingData => 'Veri içe aktarılıyor...';

  @override
  String get reinitializingData => 'Uygulama verileri yeniden başlatılıyor...';

  @override
  String get dataSyncSuccess => 'Veri senkronizasyonu başarılı';

  @override
  String get preparingData => 'Veri hazırlanıyor...';

  @override
  String get uploadingData => 'Veri yükleniyor...';

  @override
  String get dataPushSuccess => 'Veri gönderimi başarılı';

  @override
  String get syncFailed => 'Senkronizasyon başarısız';

  @override
  String get pushFailed => 'Gönderim başarısız';

  @override
  String get justNow => 'Az önce';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes dakika önce';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours saat önce';
  }

  @override
  String daysAgo(Object days) {
    return '$days gün önce';
  }

  @override
  String serverSelected(Object deviceName) {
    return 'Sunucu seçildi: $deviceName';
  }

  @override
  String get connectionRecordDeleted => 'Bağlantı kaydı silindi';

  @override
  String viewAllConnections(Object count) {
    return 'Tüm $count bağlantıyı görüntüle';
  }

  @override
  String get clearAllHistory => 'Tümünü Temizle';

  @override
  String get clearAllConnectionHistory => 'Tüm bağlantı geçmişi temizlendi';

  @override
  String get unknownDevice => 'Bilinmeyen Cihaz';

  @override
  String get unknownPlatform => 'Bilinmeyen Platform';

  @override
  String get inmemory => 'En Memoria';

  @override
  String get toggleSidebar => 'Kenar Çubuğunu Değiştir';

  @override
  String get deleteChat => 'Sohbeti Sil';

  @override
  String get selectAll => 'Tümünü Seç';

  @override
  String get newChat => 'Yeni Sohbet';

  @override
  String get send => 'Gönder';

  @override
  String get more => 'Daha Fazla';

  @override
  String get noMoreData => 'Daha fazla veri yok';
}
