List<Map<String, dynamic>> convertToOpenAITools(
    Map<String, List<Map<String, dynamic>>> toolsByClient) {
  List<Map<String, dynamic>> allTools = [];

  // 合并所有客户端的工具列表
  for (var tools in toolsByClient.values) {
    final openAITools = tools
        .map((tool) => {
              'type': 'function',
              'function': {
                'name': tool['name'].toString(),
                'description': tool['description'].toString(),
                'parameters': Map<String, dynamic>.from(tool['inputSchema']),
              },
            })
        .toList();

    allTools.addAll(openAITools);
  }

  return allTools;
}
