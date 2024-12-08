class ToolResponse {
  final List<Tool> tools;

  ToolResponse({required this.tools});

  factory ToolResponse.fromJson(Map<String, dynamic> json) {
    var toolsList = json['tools'] as List;
    List<Tool> tools = toolsList.map((t) => Tool.fromJson(t)).toList();
    return ToolResponse(tools: tools);
  }
}

class Tool {
  final String name;
  final String description;
  final InputSchema inputSchema;

  Tool({
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      name: json['name'],
      description: json['description'],
      inputSchema: InputSchema.fromJson(json['inputSchema']),
    );
  }
}

class InputSchema {
  final String type;
  final Map<String, Property>? properties;
  final List<String>? required;

  InputSchema({
    required this.type,
    this.properties,
    this.required,
  });

  factory InputSchema.fromJson(Map<String, dynamic> json) {
    Map<String, Property>? props;
    if (json['properties'] != null) {
      props = Map.fromEntries(
        (json['properties'] as Map<String, dynamic>).entries.map(
              (e) => MapEntry(e.key, Property.fromJson(e.value)),
            ),
      );
    }

    return InputSchema(
      type: json['type'],
      properties: props,
      required:
          json['required'] != null ? List<String>.from(json['required']) : null,
    );
  }
}

class Property {
  final String type;
  final String? description;

  Property({
    required this.type,
    this.description,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      type: json['type'],
      description: json['description'],
    );
  }
}
