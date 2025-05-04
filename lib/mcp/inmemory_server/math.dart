import 'package:logging/logging.dart';
import 'dart:math' as math;

import '../inmemory/memory_server.dart';
import '../models/json_rpc_message.dart';

class MathServer extends MemoryServer {
  MathServer() : super(name: 'math-server') {
    addTool(Tool(
      name: 'add',
      description: 'Add two numbers',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Add two numbers',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
          Property(name: 'b', type: ToolInputType.integer),
        ],
        required: ['a', 'b'],
      ),
    ));

    addTool(Tool(
      name: 'subtract',
      description: 'Subtract two numbers',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Subtract two numbers',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
          Property(name: 'b', type: ToolInputType.integer),
        ],
        required: ['a', 'b'],
      ),
    ));

    addTool(Tool(
      name: 'multiply',
      description: 'Multiply two numbers',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Multiply two numbers',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
          Property(name: 'b', type: ToolInputType.integer),
        ],
        required: ['a', 'b'],
      ),
    ));

    addTool(Tool(
      name: 'divide',
      description: 'Divide two numbers',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Divide two numbers',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
          Property(name: 'b', type: ToolInputType.integer),
        ],
        required: ['a', 'b'],
      ),
    ));

    addTool(Tool(
      name: 'power',
      description: 'Power of two numbers',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Power of two numbers',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
          Property(name: 'b', type: ToolInputType.integer),
        ],
        required: ['a', 'b'],
      ),
    ));

    addTool(Tool(
      name: 'sqrt',
      description: 'Square root of a number',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Square root of a number',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));

    addTool(Tool(
      name: 'cbrt',
      description: 'Cube root of a number',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Cube root of a number',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));

    addTool(Tool(
      name: 'abs',
      description: 'Calculate absolute value',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Calculate the absolute value of a number',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));

    addTool(Tool(
      name: 'sin',
      description: 'Calculate sine value',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Calculate the sine of an angle (input in radians)',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));

    addTool(Tool(
      name: 'cos',
      description: 'Calculate cosine value',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Calculate the cosine of an angle (input in radians)',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));

    addTool(Tool(
      name: 'tan',
      description: 'Calculate tangent value',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Calculate the tangent of an angle (input in radians)',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));

    addTool(Tool(
      name: 'log',
      description: 'Calculate logarithm',
      inputSchema: ToolInput(
        type: 'object',
        description:
            'Calculate the logarithm with specific base, defaults to natural logarithm',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
          Property(name: 'base', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));

    addTool(Tool(
      name: 'max',
      description: 'Find maximum value',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Return the maximum of two numbers',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
          Property(name: 'b', type: ToolInputType.integer),
        ],
        required: ['a', 'b'],
      ),
    ));

    addTool(Tool(
      name: 'min',
      description: 'Find minimum value',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Return the minimum of two numbers',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
          Property(name: 'b', type: ToolInputType.integer),
        ],
        required: ['a', 'b'],
      ),
    ));

    addTool(Tool(
      name: 'round',
      description: 'Round to nearest integer',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Round a number to the nearest integer',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));

    addTool(Tool(
      name: 'ceil',
      description: 'Round up to the nearest integer',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Round a number up to the nearest integer',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));

    addTool(Tool(
      name: 'floor',
      description: 'Round down to the nearest integer',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Round a number down to the nearest integer',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));

    addTool(Tool(
      name: 'mod',
      description: 'Modulo operation',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Calculate the remainder of division of two numbers',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
          Property(name: 'b', type: ToolInputType.integer),
        ],
        required: ['a', 'b'],
      ),
    ));

    addTool(Tool(
      name: 'factorial',
      description: 'Calculate factorial',
      inputSchema: ToolInput(
        type: 'object',
        description: 'Calculate the factorial of a non-negative integer',
        properties: [
          Property(name: 'a', type: ToolInputType.integer),
        ],
        required: ['a'],
      ),
    ));
  }

  @override
  Map<String, dynamic> onToolCall(JSONRPCMessage message) {
    String name = message.params?['name'];
    Map<String, dynamic> arguments = message.params?['arguments'];
    Logger.root
        .fine('memory_server onToolCall name: $name arguments: $arguments');
    switch (name) {
      case 'add':
        return {
          'result':
              add(castToNumber(arguments['a']), castToNumber(arguments['b']))
        };
      case 'subtract':
        return {
          'result': subtract(
              castToNumber(arguments['a']), castToNumber(arguments['b']))
        };
      case 'multiply':
        return {
          'result': multiply(
              castToNumber(arguments['a']), castToNumber(arguments['b']))
        };
      case 'divide':
        return {
          'result':
              divide(castToNumber(arguments['a']), castToNumber(arguments['b']))
        };
      case 'power':
        return {
          'result':
              power(castToNumber(arguments['a']), castToNumber(arguments['b']))
        };
      case 'sqrt':
        return {'result': sqrt(castToNumber(arguments['a']))};
      case 'cbrt':
        return {'result': cbrt(castToNumber(arguments['a']))};
      case 'abs':
        return {'result': abs(castToNumber(arguments['a']))};
      case 'sin':
        return {'result': sin(castToNumber(arguments['a']))};
      case 'cos':
        return {'result': cos(castToNumber(arguments['a']))};
      case 'tan':
        return {'result': tan(castToNumber(arguments['a']))};
      case 'log':
        if (arguments.containsKey('base')) {
          return {
            'result': logWithBase(
                castToNumber(arguments['a']), castToNumber(arguments['base']))
          };
        } else {
          return {'result': log(castToNumber(arguments['a']))};
        }
      case 'max':
        return {
          'result':
              max(castToNumber(arguments['a']), castToNumber(arguments['b']))
        };
      case 'min':
        return {
          'result':
              min(castToNumber(arguments['a']), castToNumber(arguments['b']))
        };
      case 'round':
        return {'result': round(castToNumber(arguments['a']))};
      case 'ceil':
        return {'result': ceil(castToNumber(arguments['a']))};
      case 'floor':
        return {'result': floor(castToNumber(arguments['a']))};
      case 'mod':
        return {
          'result':
              mod(castToNumber(arguments['a']), castToNumber(arguments['b']))
        };
      case 'factorial':
        return {'result': factorial(castToNumber(arguments['a']))};
      default:
        return {'result': 'unknown tool'};
    }
  }

  int add(int a, int b) {
    return a + b;
  }

  int subtract(int a, int b) {
    return a - b;
  }

  int multiply(int a, int b) {
    return a * b;
  }

  double divide(int a, int b) {
    return a / b;
  }

  int power(int a, int b) {
    return math.pow(a, b).toInt();
  }

  double sqrt(int a) {
    return math.sqrt(a);
  }

  double cbrt(int a) {
    return math.pow(a, 1 / 3).toDouble();
  }

  int abs(int a) {
    return a.abs();
  }

  double sin(num a) {
    return math.sin(a);
  }

  double cos(num a) {
    return math.cos(a);
  }

  double tan(num a) {
    return math.tan(a);
  }

  double log(num a) {
    return math.log(a);
  }

  double logWithBase(num a, num base) {
    return math.log(a) / math.log(base);
  }

  num max(num a, num b) {
    return math.max(a, b);
  }

  num min(num a, num b) {
    return math.min(a, b);
  }

  int round(num a) {
    return a.round();
  }

  int ceil(num a) {
    return a.ceil();
  }

  int floor(num a) {
    return a.floor();
  }

  int mod(int a, int b) {
    return a % b;
  }

  int factorial(int a) {
    if (a < 0) {
      throw ArgumentError('Factorial cannot be applied to negative numbers');
    }
    if (a <= 1) {
      return 1;
    }
    return a * factorial(a - 1);
  }
}

castToNumber(dynamic value) {
  if (value is int) {
    return value;
  }
  return num.tryParse(value);
}
