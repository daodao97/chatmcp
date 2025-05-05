import 'package:chatmcp/page/layout/widgets/mcp_tools.dart';
import 'package:chatmcp/provider/provider_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:chatmcp/utils/platform.dart';
import 'package:file_picker/file_picker.dart';
import 'package:chatmcp/widgets/upload_menu.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:chatmcp/widgets/ink_icon.dart';
import 'package:chatmcp/utils/color.dart';

class SubmitData {
  final String text;
  final List<PlatformFile> files;

  SubmitData(this.text, this.files);

  @override
  String toString() {
    return 'SubmitData(text: $text, files: $files)';
  }
}

class InputArea extends StatefulWidget {
  final bool isComposing;
  final bool disabled;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<SubmitData> onSubmitted;
  final VoidCallback? onCancel;
  final ValueChanged<List<PlatformFile>>? onFilesSelected;

  const InputArea({
    super.key,
    required this.isComposing,
    required this.disabled,
    required this.onTextChanged,
    required this.onSubmitted,
    this.onFilesSelected,
    this.onCancel,
  });

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  List<PlatformFile> _selectedFiles = [];
  final TextEditingController textController = TextEditingController();
  bool _isImeComposing = false;

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles = [..._selectedFiles, ...result.files];
        });
        widget.onFilesSelected?.call(_selectedFiles);
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles = [..._selectedFiles, ...result.files];
        });
        widget.onFilesSelected?.call(_selectedFiles);
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesSelected?.call(_selectedFiles);
  }

  void _afterSubmitted() {
    textController.clear();
    _selectedFiles.clear();
  }

  String _truncateFileName(String fileName) {
    const int maxLength = 20;
    if (fileName.length <= maxLength) return fileName;

    final extension =
        fileName.contains('.') ? '.${fileName.split('.').last}' : '';
    final nameWithoutExt = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    if (nameWithoutExt.length <= maxLength - extension.length - 3) {
      return fileName;
    }

    final truncatedLength = (maxLength - extension.length - 3) ~/ 2;
    return '${nameWithoutExt.substring(0, truncatedLength)}'
        '...'
        '${nameWithoutExt.substring(nameWithoutExt.length - truncatedLength)}'
        '$extension';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // color: Theme.of(context).cardColor,
        color: AppColors.getInputAreaBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.getInputAreaBorderColor(context), width: 1),
      ),
      margin: const EdgeInsets.only(
          left: 12.0, right: 12.0, top: 2.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedFiles.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0),
              constraints: const BoxConstraints(maxHeight: 65),
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _selectedFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    final isImage = file.extension?.toLowerCase() == 'jpg' ||
                        file.extension?.toLowerCase() == 'jpeg' ||
                        file.extension?.toLowerCase() == 'png' ||
                        file.extension?.toLowerCase() == 'gif';

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.getInputAreaFileItemBackgroundColor(
                              context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.getInputAreaBorderColor(context),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 6.0),
                              child: Row(
                                children: [
                                  Icon(
                                    isImage
                                        ? Icons.image
                                        : Icons.insert_drive_file,
                                    size: 16,
                                    color: AppColors.getInputAreaFileIconColor(
                                        context),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _truncateFileName(file.name),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _removeFile(index),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 6.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppColors.getInputAreaIconColor(
                                        context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getInputAreaBackgroundColor(context),
              ),
              child: Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter) {
                    if (HardwareKeyboard.instance.isShiftPressed) {
                      return KeyEventResult.ignored;
                    }

                    if (_isImeComposing) {
                      return KeyEventResult.ignored;
                    }

                    if (widget.isComposing &&
                        textController.text.trim().isNotEmpty) {
                      widget.onSubmitted(
                          SubmitData(textController.text, _selectedFiles));
                      _afterSubmitted();
                    }
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  enabled: !widget.disabled,
                  controller: textController,
                  onChanged: widget.onTextChanged,
                  maxLines: 5,
                  minLines: 1,
                  onAppPrivateCommand: (value, map) {
                    debugPrint('onAppPrivateCommand: $value');
                  },
                  buildCounter: (context,
                      {required currentLength, required isFocused, maxLength}) {
                    return null;
                  },
                  textInputAction: Platform.isAndroid || Platform.isIOS
                      ? TextInputAction.send
                      : TextInputAction.newline,
                  onSubmitted: Platform.isAndroid || Platform.isIOS
                      ? (text) {
                          if (widget.isComposing && text.trim().isNotEmpty) {
                            widget
                                .onSubmitted(SubmitData(text, _selectedFiles));
                            _afterSubmitted();
                          }
                        }
                      : null,
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      _isImeComposing = newValue.composing != TextRange.empty;
                      return newValue;
                    }),
                  ],
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: AppColors.getInputAreaTextColor(context),
                  ),
                  scrollPhysics: const BouncingScrollPhysics(),
                  decoration: InputDecoration(
                    hintText: l10n.askMeAnything,
                    hintStyle: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.getInputAreaHintTextColor(context),
                    ),
                    filled: true,
                    fillColor: AppColors.getInputAreaBackgroundColor(context),
                    hoverColor: Colors.transparent,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  cursorColor: AppColors.getInputAreaCursorColor(context),
                  mouseCursor: WidgetStateMouseCursor.textable,
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!widget.disabled)
                  Row(
                    children: [
                      FutureBuilder<int>(
                        future: ProviderManager
                            .mcpServerProvider.installedServersCount,
                        builder: (context, snapshot) {
                          return const McpTools();
                        },
                      ),
                      const SizedBox(width: 10),
                      if (kIsMobile) ...[
                        UploadMenu(
                          disabled: widget.disabled,
                          onPickImages: _pickImages,
                          onPickFiles: _pickFiles,
                        ),
                      ] else ...[
                        InkIcon(
                          icon: CupertinoIcons.paperclip,
                          onTap: () {
                            if (widget.disabled) return;
                            _pickFiles();
                          },
                          disabled: widget.disabled,
                          hoverColor: Theme.of(context).hoverColor,
                          tooltip: AppLocalizations.of(context)!.uploadFile,
                        ),
                      ],
                    ],
                  ),
                if (!widget.disabled) ...[
                  const Spacer(),
                  InkIcon(
                    icon: Icons.arrow_circle_up,
                    color: Theme.of(context).iconTheme.color,
                    onTap: () {
                      if (widget.disabled ||
                          textController.text.trim().isEmpty) {
                        return;
                      }
                      widget.onSubmitted(
                          SubmitData(textController.text, _selectedFiles));
                      _afterSubmitted();
                    },
                    tooltip: "send",
                  )
                ] else ...[
                  const Spacer(),
                  InkIcon(
                    icon: CupertinoIcons.stop,
                    onTap: widget.onCancel != null
                        ? () {
                            widget.onCancel!();
                          }
                        : null,
                    tooltip: "cancel",
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
