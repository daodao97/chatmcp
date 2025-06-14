<div align="center">
<img src="./assets/logo.png" alt="logo" width="120" height="120">
<h1>chatmcp</h1>

Platformlar Arası <code>MacOS | Windows | Linux | iOS | Android</code> Yapay Zeka Sohbet İstemcisi

[English](./README.md) | [简体中文](./README_ZH.md) | Türkçe

</div>

## Kurulum

| macOS                                                 | Windows                                               | Linux                                                   | iOS                                                      | Android                                               |
|-------------------------------------------------------|-------------------------------------------------------|---------------------------------------------------------|----------------------------------------------------------|-------------------------------------------------------|
| [İndir](https://github.com/daodao97/chatmcp/releases) | [İndir](https://github.com/daodao97/chatmcp/releases) | [İndir](https://github.com/daodao97/chatmcp/releases) ¹ | [TestFlight](https://testflight.apple.com/join/dCXksFJV) | [İndir](https://github.com/daodao97/chatmcp/releases) |

¹ Not: Linux'ta, `sqflite_common_ffi` paketinin çalışması için `libsqlite3-0` ve `libsqlite3-dev` kütüphanelerini kurmanız
gerekir: https://pub.dev/packages/sqflite_common_ffi

```bash
sudo apt-get install libsqlite3-0 libsqlite3-dev
```

## Dokümantasyon

Ayrıca, chatmcp hakkında daha fazla bilgi edinmek için DeepWiki'yi kullanabilirsiniz.
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/daodao97/chatmcp)
DeepWiki, herhangi bir herkese açık GitHub deposunu tam etkileşimli, kolay anlaşılır bir wiki'ye dönüştüren yapay zeka destekli bir platformdur.
Kodları, dokümantasyonu ve yapılandırma dosyalarını analiz ederek net açıklamalar ve etkileşimli diyagramlar oluşturur, hatta yapay zeka ile
gerçek zamanlı olarak soru-cevap yapmanıza olanak tanır.


## Kullanım

Sisteminizde uvx veya npx'in kurulu olduğundan emin olun.
### MacOS

* uvx için

```shell
brew install uv
```

* npx için

```shell
brew install node
```

### Linux

* uvx için

curl -LsSf https://astral.sh/uv/install.sh | sh

* npx için (apt kullanarak)

```shell
sudo apt update
sudo apt install nodejs npm
```

1. Ayarlar sayfasında LLM API Anahtarınızı ve Uç Noktanızı (Endpoint) yapılandırın.
2. MCP Sunucusu sayfasından bir MCP sunucusu kurun.
3. MCP Sunucusu ile sohbete başlayın.

* stdio mcp sunucusu
![alt text](./docs/mcp_stdio.png)
* sse mcp sunucusu
![alt text](./docs/mcp_sse.png)
* Hata Ayıklama Modu (Debug)
- Kayıtlar (Loglar) & Veriler

macOS:

```bash
~/Library/Application Support/ChatMcp
```

Windows:

```bash
%APPDATA%\ChatMcp
```

Linux:

```bash
~/.local/share/ChatMcp
```

Mobil:

- Uygulama Belgeler Dizini
Uygulamayı sıfırlamak için bu komutları kullanabilirsiniz:

macOS:

```bash
rm -rf ~/Library/Application\ Support/ChatMcp
```

Windows:

```bash
rd /s /q "%APPDATA%\ChatMcp"
```

Linux:

```bash
rm -rf ~/.local/share/ChatMcp
```

## Geliştirici Notları

Flutter paketlerini yükleyin
```shell
flutter pub get
```
Çalıştırmak için: 
- linux:
```shell
flutter run -d linux
```

- macOS:
```shell
flutter run -d macos
```

- Windows:
```shell
flutter run -d macos
```

- Android(emulator or gerçek cihaz):
```shell
flutter run -d "Pixel ..."
```


### Android İmza Yapılandırması
Android uygulamasının yayın sürümünü oluşturmanız gerekiyorsa, imzalama yapılandırmasını yapmalısınız:
- İmza anahtarı oluşturma  
./scripts/create_keystore.sh

- İmza yapılandırmasını doğrulama  
./scripts/verify_signing.sh

- İmzalı APK oluşturma  
flutter build apk --release

- İmzalı App Bundle oluşturma (Google Play için önerilir)  
flutter build appbundle --release

Detaylı imzalama yapılandırması talimatları için bakınız: [Android İmza Yapılandırma Rehberi](https://docs.flutter.dev/deployment/android#sign-the-app).

## Uygulamanın Temel Özellikleri
* MCP Sunucusu ile Sohbet
* MCP Sunucusu Pazaryeri
* MCP Sunucusunu Otomatik Kurulum
* SSE MCP Aktarım Desteği
* Otomatik MCP Sunucusu Seçimi
* Sohbet Geçmişi
* OpenAI LLM Modeli
* Claude LLM Modeli
* OLLama LLM Modeli
* DeepSeek LLM Modeli
* RAG (Retrieval-Augmented Generation)
* Daha İyi Arayüz Tasarımı
* Koyu/Açık Tema

Her türlü özellik önerisine açığız. Fikirlerinizi veya bulduğunuz hataları [Issues](https://github.com/daodao97/chatmcp/issues) sayfasından bize iletebilirsiniz.

* MCP Sunucusu Pazaryeri
MCP Sunucusu Pazaryeri'nden dilediğiniz MCP sunucusunu kurabilirsiniz. MCP Sunucusu Pazaryeri, farklı veri türleriyle sohbet etmek için kullanabileceğiniz MCP sunucularının bir koleksiyonudur.
Geri bildirimleriniz, chatmcp'yi geliştirmemize ve diğer kullanıcıların bilinçli kararlar almasına yardımcı olur.

* Teşekkürler
* MCP
* mcp-cli

## Lisans
Bu proje Apache License 2.0 ile lisanslanmıştır.

## GitHub Yıldız Geçmişi

![](https://api.star-history.com/svg?repos=daodao97/chatmcp&type=Date)

