import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:chatmcp/widgets/ink_icon.dart';
import 'package:chatmcp/utils/color.dart';
import 'package:chatmcp/components/widgets/custom_popup.dart';

class UploadMenu extends StatelessWidget {
  final bool disabled;
  final VoidCallback onPickImages;
  final VoidCallback onPickFiles;

  const UploadMenu({
    super.key,
    required this.disabled,
    required this.onPickImages,
    required this.onPickFiles,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BasePopup(
      showArrow: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: disabled
                ? null
                : () {
                    Navigator.of(context).pop();
                    onPickImages();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkIcon(icon: CupertinoIcons.photo),
                  const SizedBox(width: 12),
                  Text(
                    t.selectFromGallery,
                    style: TextStyle(
                      color: AppColors.getThemeTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: disabled
                ? null
                : () {
                    Navigator.of(context).pop();
                    onPickFiles();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkIcon(icon: CupertinoIcons.doc),
                  const SizedBox(width: 12),
                  Text(
                    t.selectFile,
                    style: TextStyle(
                      color: AppColors.getThemeTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      maxWidth: 200,
      child: InkIcon(
        icon: CupertinoIcons.plus_app,
        onTap: disabled ? null : null,
        disabled: disabled,
        hoverColor: Theme.of(context).hoverColor,
        tooltip: t.uploadFile,
      ),
    );
  }
}
