import 'package:chatmcp/mcp/models/json_rpc_message.dart';

// Define the JSON-RPC response class
class JsonRpcResponse {
  final String jsonrpc;
  final dynamic result;
  final Map<String, dynamic>? error;
  final dynamic id;

  JsonRpcResponse({
    required this.jsonrpc,
    this.result,
    this.error,
    required this.id,
  });

  factory JsonRpcResponse.fromJson(Map<String, dynamic> json) {
    return JsonRpcResponse(
      jsonrpc: json['jsonrpc'] ?? '2.0',
      id: json['id'],
      result: json['result'],
      error: json['error'] != null
          ? Map<String, dynamic>.from(json['error'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'jsonrpc': jsonrpc,
      'id': id,
    };
    // According to the JSON-RPC specification, result and error are mutually exclusive
    if (error != null) {
      data['error'] = error;
    } else {
      // Even if result is null or an empty map, it should be included (if error does not exist)
      data['result'] = result;
    }
    return data;
  }
}

// Function to handle requests
JsonRpcResponse handleRequest(JSONRPCMessage request) {
  dynamic result;
  Map<String, dynamic>? error;

  try {
    switch (request.method) {
      case 'initialize':
        result = {
          'protocolVersion': '1.0',
          'serverInfo': {
            'name': 'mock-server-dart',
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
        break;
      case 'ping':
        result = {}; // Empty object
        break;
      case 'resources/list':
        result = {
          'resources': [
            {
              'name': 'test-resource',
              'uri': 'test://resource',
            },
          ],
        };
        break;
      case 'resources/read':
        // In the actual implementation, the URI should be obtained from request.params
        // final uri = request.params?['uri'];
        // if (uri == null) throw ArgumentError('Missing parameter: uri');
        // ... Read content based on uri ...
        result = {
          'contents': [
            {
              'text': 'test content',
              'uri': 'test://resource', // Use a mock URI
            },
          ],
        };
        break;
      case 'resources/subscribe':
      case 'resources/unsubscribe':
        // In the actual implementation, the subscription/unsubscription logic should be handled
        // final uri = request.params?['uri'];
        // if (uri == null) throw ArgumentError('Missing parameter: uri');
        result = {}; // Return an empty object when successful
        break;
      case 'prompts/list':
        result = {
          'prompts': [
            {
              'name': 'test-prompt',
            },
          ],
        };
        break;
      case 'prompts/get':
        // In the actual implementation, the prompt name/ID should be obtained from request.params
        // final promptName = request.params?['name'];
        result = {
          'messages': [
            {
              'role': 'assistant',
              'content': {
                'type': 'text',
                'text': 'test message',
              },
            },
          ],
        };
        break;
      case 'tools/list':
        result = {
          'tools': [
            {
              'name': 'test-tool',
              'inputSchema': {
                'type': 'object',
                // 'properties': { ... } // You can add schema definitions
              },
              // 'description': 'A test tool' // Optional description
            },
          ],
        };
        break;
      case 'tools/call':
        // In the actual implementation, the tool name and input should be obtained from request.params
        // final toolName = request.params?['tool'];
        // final input = request.params?['input'];
        // if (toolName == null) throw ArgumentError('Missing parameter: tool');
        // ... Execute the tool call ...
        result = {
          'content': [
            {
              'type': 'text',
              'text': 'tool result',
            },
          ],
        };
        break;
      case 'logging/setLevel':
        // In the actual implementation, the log level should be obtained from request.params
        // final level = request.params?['level'];
        // if (level == null) throw ArgumentError('Missing parameter: level');
        result = {}; // Return an empty object when successful
        break;
      case 'completion/complete':
        // In the actual implementation, the information needed for completion should be obtained from request.params
        // final context = request.params?['context'];
        result = {
          'completion': {
            'values': ['test completion'],
          },
        };
        break;
      default:
        error = {
          'code': -32601, // Method not found
          'message': 'Method not found: ${request.method}',
        };
    }
  } catch (e, stackTrace) {
    // Catch any exceptions during the processing and format them as a JSON-RPC error
    print('Error handling request: $e');
    print('Stack trace:\n$stackTrace');
    error = {
      'code': -32603, // Internal error
      'message': 'Internal server error: ${e.toString()}',
      // 'data': stackTrace.toString(), // Optional: Include debugging information
    };
    result = null; // Ensure result is null when an error occurs
  }

  return JsonRpcResponse(
    jsonrpc: '2.0',
    id: request.id,
    result: result,
    error: error,
  );
}

// Example usage (optional, usually placed in a separate test file or main file)
/*
void main() {
  // Simulate a request
  final requestJson = {
    'jsonrpc': '2.0',
    'method': 'initialize',
    'id': 1,
  };
  final request = JsonRpcRequest.fromJson(requestJson);

  // Process the request
  final response = handleRequest(request);

  // Print the response (convert to JSON string)
  print(jsonEncode(response.toJson()));

  // Simulate another request
  final pingRequestJson = {
    'jsonrpc': '2.0',
    'method': 'ping',
    'id': 2,
  };
  final pingRequest = JsonRpcRequest.fromJson(pingRequestJson);
  final pingResponse = handleRequest(pingRequest);
  print(jsonEncode(pingResponse.toJson()));

  // Simulate an error request
  final errorRequestJson = {
    'jsonrpc': '2.0',
    'method': 'unknown_method',
    'id': 3,
  };
  final errorRequest = JsonRpcRequest.fromJson(errorRequestJson);
  final errorResponse = handleRequest(errorRequest);
  print(jsonEncode(errorResponse.toJson()));

  // Simulate a request with parameters (needs corresponding comments in handleRequest to be uncommented)
  // final resourceReadRequestJson = {
  //   'jsonrpc': '2.0',
  //   'method': 'resources/read',
  //   'params': {'uri': 'specific://resource'},
  //   'id': 4,
  // };
  // final resourceReadRequest = JsonRpcRequest.fromJson(resourceReadRequestJson);
  // final resourceReadResponse = handleRequest(resourceReadRequest);
  // print(jsonEncode(resourceReadResponse.toJson()));

  // Simulate a request that causes an internal error (for example, missing parameters and not handled correctly)
  final badParamRequestJson = {
    'jsonrpc': '2.0',
    'method': 'resources/read', // Assume this method requires a uri parameter
    // 'params': {}, // Intentionally not passing parameters
    'id': 5,
  };
    try {
      final badParamRequest = JsonRpcRequest.fromJson(badParamRequestJson);
      final badParamResponse = handleRequest(badParamRequest);
      print(jsonEncode(badParamResponse.toJson()));
    } catch (e) {
      print('Error creating/handling request: $e');
      // In actual applications, the error handling in fromJson or handleRequest will catch this
    }


}
*/
