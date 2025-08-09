<div align="center">
<img src="./assets/logo.png" alt="logo" width="120" height="120">
<h1>chatmcp</h1>

Platformlar Arası <code>MacOS | Windows | Linux | iOS | Android | Web</code> Yapay Zeka Sohbet İstemcisi

[English](./README.md) | [简体中文](./README_ZH.md) | Türkçe

</div>

## Kurulum

| macOS                                                 | Windows                                               | Linux                                                   | iOS                                                      | Android                                               | Web                                                    |
|-------------------------------------------------------|-------------------------------------------------------|---------------------------------------------------------|----------------------------------------------------------|-------------------------------------------------------|--------------------------------------------------------|
| [İndir](https://github.com/daodao97/chatmcp/releases) | [İndir](https://github.com/daodao97/chatmcp/releases) | [İndir](https://github.com/daodao97/chatmcp/releases) ¹ | [TestFlight](https://testflight.apple.com/join/dCXksFJV) | [İndir](https://github.com/daodao97/chatmcp/releases) | [GitHub Pages](https://daodao97.github.io/chatmcp) ² |

¹ Not: Linux gereksinimleri aşağıdadır (Ubuntu 22.04 ve 24.04)

² Not: Web sürümü tamamen tarayıcınızda çalışır ve sohbet geçmişi ile ayarlar için yerel depolama kullanır.

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

### Linux Gereksinimleri (Ubuntu 22.04 ve 24.04)

ChatMCP AppImage/DEB çalıştırmak için aşağıdaki paketlerin kurulu olması gerekir:

- AppImage (FUSE): `libfuse2`
- GTK 3: `libgtk-3-0`
- Grafik/EGL:
  - Ubuntu 22.04: `libegl1-mesa`, `libgles2`, `libgl1-mesa-dri`, `libglx-mesa0`
  - Ubuntu 24.04: `libegl1`, `libgles2`, `libgl1-mesa-dri`, `libglx-mesa0`
- X11 yardımcıları ve SQLite: `libx11-6`, `xdg-utils`, `libsqlite3-0`

Kurulum komutları:

- Ubuntu 22.04:
```bash
sudo apt install -y libfuse2 libgtk-3-0 libegl1-mesa libgles2 libgl1-mesa-dri libglx-mesa0 libx11-6 xdg-utils libsqlite3-0
```

- Ubuntu 24.04:
```bash
sudo apt install -y libfuse2 libgtk-3-0 libegl1 libgles2 libgl1-mesa-dri libglx-mesa0 libx11-6 xdg-utils libsqlite3-0
```

Opsiyonel (önerilir): `mesa-vulkan-drivers`, `mesa-utils` (glxinfo gibi teşhis araçları)

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
rm -rf ~/.local/share/run.daodao.chatmcp
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

### Web Sürümü Geliştirme ve Dağıtım

#### Yerel Geliştirme
```bash
# Bağımlılıkları yükle
flutter pub get

# Web sürümünü yerel olarak çalıştır
flutter run -d chrome
# veya port belirterek
flutter run -d chrome --web-port 8080
```

#### Web Sürümünü Oluşturma
```bash
# Üretim sürümünü oluştur
flutter build web

# Alt dizin için temel yol belirterek oluştur
flutter build web --base-href /chatmcp/
```

#### GitHub Pages'e Dağıtım
```bash
# 1. Web sürümünü oluştur
flutter build web --base-href /chatmcp/

# 2. build/web dizininin içeriğini gh-pages dalına gönder
# veya GitHub Actions ile otomatik dağıtım kullan
```

Oluşturma tamamlandıktan sonra, dosyalar `build/web` dizininde olacak ve herhangi bir statik web site barındırma hizmetine dağıtılabilir.

## Uygulamanın Temel Özellikleri
* MCP Sunucusu ile Sohbet
* MCP Server Market
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

## MCP Server Market
MCP Server Market'ten dilediğiniz MCP sunucusunu kurabilirsiniz. MCP Server Market, farklı veri türleriyle sohbet etmek için kullanabileceğiniz MCP sunucularının bir koleksiyonudur.

* Ayrıca yeni MCP Server ekleyebilirsiniz : [MCP Server Market](https://github.com/chatmcpclient/mcp_server_market/blob/main/mcp_server_market.json)

[mcp_server_market](https://github.com/chatmcpclient/mcp_server_market) deposunu forklayın ve `mcp_server_market.json` dosyasının sonuna yeni MCP Server ekleyin.

```json
{
    "mcpServers": {
        "existing-mcp-servers": {},
        "your-mcp-server": {
            "command": "uvx",
            "args": [
                "--from",
                "git+https://github.com/username/your-mcp-server",
                "your-mcp-server"
            ]
        }
    }
}
```
Değişikliklerinizi bir Pull Request göndererek paylaşabilirsiniz. PR onaylandıktan sonra MCP Server Market'te görünecektir ve diğer kullanıcılar da aynı anda kullanmaya başlayacaktır.


Geri bildirimleriniz, chatmcp'yi geliştirmemize ve diğer kullanıcıların bilinçli kararlar almasına yardımcı olur.

* Teşekkürler
* MCP
* mcp-cli

## Lisans
Bu proje Apache License 2.0 ile lisanslanmıştır.

## GitHub Yıldız Geçmişi

![](https://api.star-history.com/svg?repos=daodao97/chatmcp&type=Date)

