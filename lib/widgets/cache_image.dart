import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io' show Platform;

class CacheImage extends StatelessWidget {
  final String imageUrl;

  const CacheImage({
    super.key,
    required this.imageUrl,
  });

  Future<void> _downloadImage(BuildContext context) async {
    // 获取全局上下文
    final scaffoldContext = Navigator.of(context).context;
    try {
      if (!scaffoldContext.mounted) return;
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text('start to save image...')),
      );

      // 从缓存中获取文件
      var fileInfo = await DefaultCacheManager().getFileFromCache(imageUrl);
      fileInfo ??= await DefaultCacheManager().downloadFile(imageUrl);

      if (Platform.isAndroid || Platform.isIOS) {
        // todo
      } else {
        // 获取下载目录
        final dir = await getDownloadsDirectory();
        if (dir == null) {
          throw Exception('cannot get download directory');
        }

        // 从URL中提取文件扩展名
        final extension = imageUrl.split('.').last.split('?').first;
        final fileName =
            'image_${DateTime.now().millisecondsSinceEpoch}.$extension';
        final savePath = '${dir.path}/$fileName';

        // 复制文件
        await fileInfo.file.copy(savePath);

        if (!scaffoldContext.mounted) return;
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('image saved to download directory: $fileName'),
            action: SnackBarAction(
              label: 'ok',
              onPressed: () {
                ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (!scaffoldContext.mounted) return;
      Logger.root.severe('save image failed: $e');
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('save image failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'retry',
            textColor: Colors.white,
            onPressed: () => _downloadImage(scaffoldContext),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePreview(context),
      child: CachedNetworkImage(
        height: 200,
        imageUrl: imageUrl,
        placeholder: (context, url) => Container(
          height: 200,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          alignment: Alignment.center,
          child: const Icon(Icons.error),
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white),
                    onPressed: () => _downloadImage(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
