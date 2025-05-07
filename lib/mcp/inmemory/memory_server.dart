import 'package:chatmcp/mcp/models/json_rpc_message.dart';
import 'package:logging/logging.dart';
import 'server.dart';

enum ToolInputType {
  string,
  integer,
  boolean,
  object,
}

class Property {
  String name;
  ToolInputType type;

  Property({
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
    };
  }
}

class ToolInput {
  String type;
  String description;
  List<Property> properties;
  List<String> required;

  ToolInput({
    required this.type,
    required this.description,
    required this.properties,
    required this.required,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'properties': properties.map((property) => property.toJson()).toList(),
    };
  }
}

class Tool {
  String name;
  String description;
  ToolInput inputSchema;

  Tool({
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'inputSchema': inputSchema.toJson(),
    };
  }
}

abstract class MemoryServer {
  String name;

  List<Tool> tools;

  MemoryServer({
    required this.name,
    List<Tool>? tools,
  }) : tools = tools ?? [];

  JSONRPCMessage onmessage(JSONRPCMessage message) {
    var result = {};
    switch (message.method) {
      case 'initialize':
        result = {
          'protocolVersion': '1.0',
          'serverInfo': {
            'name': name,
            'version': '1.0.0',
          },
          'capabilities': {
            'prompts': {
              'listChanged': true,
            },
            'resources': {
              'listChanged': true,
              'subscribe': true,
            },
            'tools': {
              'listChanged': true,
            },
          },
        };
      case 'ping':
        result = {}; // Empty object
      case 'resources/list':
        result = {
          'resources': [],
        };
      case 'resources/read':
        result = {
          'contents': [],
        };
      case 'resources/subscribe':
      case 'resources/unsubscribe':
        result = {}; // Return an empty object when successful
      case 'prompts/list':
        result = {
          'prompts': [],
        };
      case 'prompts/get':
        result = {
          'messages': [],
        };
      case 'tools/list':
        result = {
          'tools': tools.map((tool) => tool.toJson()).toList(),
        };
      case 'tools/call':
        Logger.root.fine('tools/call message: ${message.toJson()}');
        result = {
          "content": onToolCall(message),
        };
      case 'logging/setLevel':
        result = {};
      case 'completion/complete':
        result = {
          'completion': {},
        };
      default:
        result = {
          'code': -32601,
          'message': 'Method not found: ${message.method}',
        };
    }
    return JSONRPCMessage(
      id: message.id,
      jsonrpc: '2.0',
      method: message.method,
      result: result,
    );
  }

  void addTool(Tool tool) {
    tools.add(tool);
  }

  Map<String, dynamic> onToolCall(JSONRPCMessage message);
}
