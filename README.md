# chatmcp

AI Chat with [MCP](https://modelcontextprotocol.io/introduction) Server use Any LLM Model

![](./preview.png)

## Usage

1. Configure Your LLM API Key and Endpoint in `Setting` Page
2. Install MCP Server from `MCP Server` Page
3. Chat with MCP Server

## Install

The project is still in development and has not been released to the app store yet. You can install it by:

1. Download the source code
2. Run the project using Flutter


## Development

```bash
flutter pub get
flutter run -d macos
```

download [test.db](./assets/test.db) to test mcp server

![](./assets/test.png)

`~/Documents/mcp_server.json` is the configuration file for the mcp server

## Features

- [x] Chat with MCP Server
- [ ] MCP Server Market
- [ ] Auto install MCP Server
- [ ] SSE MCP Transport Support
- [x] Auto Choose MCP Server
- [ ] Chat History
- [x] OpenAI LLM Model
- [ ] Claude LLM Model
- [ ] LLama LLM Model
- [ ] RAG 
- [ ] Better UI Design

All features are welcome to submit, you can submit your ideas or bugs in [Issues](https://github.com/daodao97/chatmcp/issues)

## MCP Server Market

You can install MCP Server from MCP Server Market, MCP Server Market is a collection of MCP Server, you can use it to chat with different data.

## Thanks

- [MCP](https://modelcontextprotocol.io/introduction)
- [mcp-cli](https://github.com/chrishayuk/mcp-cli)

## License

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) (GPL-3.0).

Key terms:
- Any modified code must be open source
- Modified code must use the same GPL-3.0 license
- Must prominently display the use of GPL license
- No additional restrictions may be added
