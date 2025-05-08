<div align="center">
<img src="./macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_128@1x.png" alt="logo">
<h1>chatmcp</h1>

Cross-platform `Macos | Windows | Linux | iOS | Android` AI Chat Client

[English](./README.md) | [简体中文](./README_ZH.md)

</div>

## Install

| macOS | Windows | Linux | iOS | Android |
|-------|---------|-------|------|---------|
| [Release](https://github.com/daodao97/chatmcp/releases) | [Release](https://github.com/daodao97/chatmcp/releases) | [Release](https://github.com/daodao97/chatmcp/releases) ¹ | [TestFlight](https://testflight.apple.com/join/dCXksFJV) | [Release](https://github.com/daodao97/chatmcp/releases) |

¹ Note: On Linux you need to install libsqlite3-0 libsqlite3-dev, as this dependency needs it https://pub.dev/packages/sqflite_common_ffi

```bash
sudo apt-get install libsqlite3-0 libsqlite3-dev
```

## Preview

![Artifact Display](./assets/preview/artifact.gif)
![Thinking Mode](./assets/preview/think.png)
![Generate Image](./assets/preview/gen_img.png)
![LaTeX Support](./assets/preview/latex.png)
![HTML Preview](./assets/preview/html-preview.png)
![Mermaid Diagram](./assets/preview/mermaid.png)
![mcp workflow](./assets/preview/mcp-workerflow.png)
![mcp inmemory](./assets/preview/mcp-inmemory.png)
![MCP Tools](./assets/preview/mcp-tools.png)
![LLM Provider](./assets/preview/llm-provider.png)
![MCP Stdio](./assets/preview/mcp-stdio.png)
![MCP SSE](./assets/preview/mcp-sse.png)


## Usage

Make sure you have installed `uvx` or `npx` in your system

### MacOS
```bash
# uvx
brew install uv

# npx
brew install node 
```

### Linux 
```bash
# uvx
curl -LsSf https://astral.sh/uv/install.sh | sh

# npx (using apt)
sudo apt update
sudo apt install nodejs npm
```

1. Configure Your LLM API Key and Endpoint in `Setting` Page
2. Install MCP Server from `MCP Server` Page
3. Chat with MCP Server

- stdio mcp server
![](./docs/mcp_stdio.png)

- sse mcp server
![](./docs//mcp_sse.png)

## Debug 

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

## Development

```bash
flutter pub get
flutter run -d macos
```

## Features

- [x] Chat with MCP Server
- [ ] MCP Server Market
- [ ] Auto install MCP Server
- [x] SSE MCP Transport Support
- [x] Auto Choose MCP Server
- [x] Chat History
- [x] OpenAI LLM Model
- [x] Claude LLM Model
- [x] OLLama LLM Model
- [x] DeepSeek LLM Model
- [ ] RAG 
- [ ] Better UI Design
- [x] Dark/Light Theme

All features are welcome to submit, you can submit your ideas or bugs in [Issues](https://github.com/daodao97/chatmcp/issues)

## MCP Server Market

You can install MCP Server from MCP Server Market, MCP Server Market is a collection of MCP Server, you can use it to chat with different data.

Your feedback helps us improve chatmcp and helps other users make informed decisions.

## Thanks

- [MCP](https://modelcontextprotocol.io/introduction)
- [mcp-cli](https://github.com/chrishayuk/mcp-cli)

## License

This project is licensed under the [Apache License 2.0](./LICENSE).

## Star History

![](https://api.star-history.com/svg?repos=daodao97/chatmcp&type=Date)