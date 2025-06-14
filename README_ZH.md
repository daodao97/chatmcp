<div align="center">
<img src="./assets/logo.png" alt="logo" width="120" height="120">
<h1>chatmcp</h1>

跨平台 `MacOS | Windows | Linux | iOS | Android` AI 聊天客户端

[English](./README.md) | 简体中文 | [Türkçe](./README_TR.md)

</div>

## 安装

桌面端：MacOS | Windows | Linux [release](https://github.com/daodao97/chatmcp/releases)

  注意：在 Linux 系统上，您需要安装 libsqlite3-0 和 libsqlite3-dev，因为依赖包 https://pub.dev/packages/sqflite_common_ffi 需要这些库

  ```bash
  sudo apt-get install libsqlite3-0 libsqlite3-dev
  ```

iOS：[TestFlight](https://testflight.apple.com/join/dCXksFJV)

Android：[release](https://github.com/daodao97/chatmcp/releases)

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


## 使用方法

确保您的系统中已安装 `uvx` 或 `npx`

```bash
# uvx
brew install uv

# npx
brew install node 
```

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
```

## 开发

```bash
flutter pub get
flutter run -d macos
```

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

您的反馈有助于我们改进 chatmcp，也能帮助其他用户做出明智的决定。

## 致谢

- [MCP](https://modelcontextprotocol.io/introduction)
- [mcp-cli](https://github.com/chrishayuk/mcp-cli)

## 许可证

本项目采用 [Apache License 2.0](./LICENSE) 许可证。

## Star History

![](https://api.star-history.com/svg?repos=daodao97/chatmcp&type=Date)