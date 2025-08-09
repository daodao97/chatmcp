<div align="center">
<img src="./assets/logo.png" alt="logo" width="120" height="120">
<h1>chatmcp</h1>

跨平台 `MacOS | Windows | Linux | iOS | Android | Web` AI 聊天客户端

[English](./README.md) | 简体中文 | [Türkçe](./README_TR.md)

</div>

## 安装

| 平台                                                       | 链接                                                          | 说明                                                           |
|-----------------------------------------------------------|---------------------------------------------------------------|---------------------------------------------------------------|
| macOS                                                     | [Release](https://github.com/daodao97/chatmcp/releases)       |                                                               |
| Windows                                                   | [Release](https://github.com/daodao97/chatmcp/releases)       |                                                               |
| Linux                                                     | [Release](https://github.com/daodao97/chatmcp/releases)       | 请参见下方“Linux 运行环境需求” ¹                              |
| iOS                                                       | [TestFlight](https://testflight.apple.com/join/dCXksFJV)      |                                                               |
| Android                                                   | [Release](https://github.com/daodao97/chatmcp/releases)       |                                                               |
| Web                                                       | [GitHub Pages](https://daodao97.github.io/chatmcp)           | 完全在浏览器中运行，使用本地存储保存聊天记录和设置 ²            |

¹ 提示：请参见下方“Linux 运行环境需求（Ubuntu 22.04 与 24.04）”。

² 注意：Web 版本完全在您的浏览器中运行，使用本地存储保存聊天记录和设置。

## 预览

![Artifact Display](./docs/preview/artifact.gif)
![Thinking Mode](./docs/preview/think.webp)
![Generate Image](./docs/preview/gen_img.webp)
![LaTeX Support](./docs/preview/latex.webp)
![HTML Preview](./docs/preview/html-preview.webp)
![Mermaid Diagram](./docs/preview/mermaid.webp)
![mcp workflow](./docs/preview/mcp-workerflow.webp)
![mcp inmemory](./docs/preview/mcp-inmemory.webp)
![MCP Tools](./docs/preview/mcp-tools.webp)
![LLM Provider](./docs/preview/llm-provider.webp)
![MCP Stdio](./docs/preview/mcp-stdio.webp)
![MCP SSE](./docs/preview/mcp-sse.webp)

### 数据同步

ChatMCP 应用程序可以在同一局域网内同步数据

![Data sync](./docs/preview/data-sync.webp)


## 使用方法

确保您的系统中已安装 `uvx` 或 `npx`

```bash
# uvx
brew install uv

# npx
brew install node 
```

### Linux 运行环境需求（Ubuntu 22.04 与 24.04）

在 Ubuntu 及其衍生发行版上运行 ChatMCP 的 AppImage/DEB，请确保安装以下运行时依赖：

- AppImage（FUSE）：`libfuse2`
- GTK 3：`libgtk-3-0`
- 图形/EGL：
  - Ubuntu 22.04：`libegl1-mesa`、`libgles2`、`libgl1-mesa-dri`、`libglx-mesa0`
  - Ubuntu 24.04：`libegl1`、`libgles2`、`libgl1-mesa-dri`、`libglx-mesa0`
- 其他：`libx11-6`、`xdg-utils`、`libsqlite3-0`

安装命令示例：

- Ubuntu 22.04：
```bash
sudo apt install -y libfuse2 libgtk-3-0 libegl1-mesa libgles2 libgl1-mesa-dri libglx-mesa0 libx11-6 xdg-utils libsqlite3-0
```

- Ubuntu 24.04：
```bash
sudo apt install -y libfuse2 libgtk-3-0 libegl1 libgles2 libgl1-mesa-dri libglx-mesa0 libx11-6 xdg-utils libsqlite3-0
```

可选（推荐）：`mesa-vulkan-drivers`、`mesa-utils`（如 glxinfo 等诊断工具）

1. 在"设置"页面配置您的 LLM API 密钥和端点
2. 从"MCP 服务器"页面安装 MCP 服务器
3. 与 MCP 服务器开始对话

- stdio mcp server
![](./docs/mcp_stdio.webp)

- sse mcp server
![](./docs//mcp_sse.webp)


## 调试 

- logs & data

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

Mobile:
- Application Documents Directory

reset app can use this command

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

## 开发

```bash
flutter pub get
flutter run -d macos
```

### Web版本开发和部署

#### 本地开发
```bash
# 安装依赖
flutter pub get

# 本地运行Web版本
flutter run -d chrome
# 或者指定端口
flutter run -d chrome --web-port 8080
```

#### 构建Web版本
```bash
# 构建生产版本
flutter build web

# 构建并指定基础路径（用于部署到子目录）
flutter build web --base-href /chatmcp/
```

#### 部署到GitHub Pages
```bash
# 1. 构建Web版本
flutter build web --base-href /chatmcp/

# 2. 将build/web目录的内容推送到gh-pages分支
# 或者使用GitHub Actions自动部署
```

构建完成后，文件将在 `build/web` 目录中，可以部署到任何静态网站托管服务。

### Android 签名配置

如果您需要构建发布版本的 Android 应用，请配置签名：

```bash
# 生成签名密钥
./scripts/create_keystore.sh

# 验证签名配置
./scripts/verify_signing.sh

# 构建签名的 APK
flutter build apk --release

# 构建签名的 App Bundle（推荐用于 Google Play）
flutter build appbundle --release
```

详细的签名配置说明请参考：[Android 签名配置指南](./docs/android-signing.md)

## 功能特性

- [x] 与 MCP 服务器对话
- [ ] MCP 服务器市场
- [ ] 自动安装 MCP 服务器
- [x] SSE MCP 传输支持
- [x] 自动选择 MCP 服务器
- [x] 聊天历史
- [x] OpenAI LLM 模型
- [x] Claude LLM 模型
- [x] OLLama LLM 模型
- [x] DeepSeek LLM 模型
- [ ] RAG 
- [ ] 更好的 UI 设计
- [x] 深色/浅色主题

欢迎提交任何功能建议，您可以在 [Issues](https://github.com/daodao97/chatmcp/issues) 中提交您的想法或错误报告。

## MCP 服务器市场

您可以从 MCP 服务器市场安装 MCP 服务器。MCP 服务器市场是 MCP 服务器的集合，您可以用它来与不同的数据进行对话。


您也可以在 [MCP 服务器市场](https://github.com/chatmcpclient/mcp_server_market/blob/main/mcp_server_market.json) 中添加新的 MCP 服务器。

创建 [mcp_server_market](https://github.com/chatmcpclient/mcp_server_market) 的 fork 并添加您的 MCP 服务器到 `mcp_server_market.json` 文件的末尾。

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
您可以向 [mcp_server_market](https://github.com/chatmcpclient/mcp_server_market) 仓库发送 Pull Request 以将您的 MCP 服务器添加到市场。在您的 PR 被合并后，您的 MCP 服务器将可在市场使用，其他用户可以立即使用它。 

您的反馈有助于我们改进 chatmcp，也能帮助其他用户做出明智的决定。


## 致谢

- [MCP](https://modelcontextprotocol.io/introduction)
- [mcp-cli](https://github.com/chrishayuk/mcp-cli)

## 许可证

本项目采用 [Apache License 2.0](./LICENSE) 许可证。

## Star History

![](https://api.star-history.com/svg?repos=daodao97/chatmcp&type=Date)