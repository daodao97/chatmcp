import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:chatmcp/generated/app_localizations.dart';

class UpgradeNotice extends StatefulWidget {
  final Duration checkInterval;
  final bool showOnlyOnce;
  final String owner;
  final String repo;
  final List<String> enablePlatforms;
  final bool showCheckUpdate;
  final bool autoCheck;
  const UpgradeNotice({
    super.key,
    this.checkInterval = const Duration(minutes: 60 * 24),
    this.showOnlyOnce = true,
    this.owner = 'daodao97',
    this.repo = 'chatmcp',
    this.enablePlatforms = const ["android", "macos", "windows", "linux"],
    this.showCheckUpdate = false,
    this.autoCheck = true,
  });

  @override
  State<UpgradeNotice> createState() => _UpgradeNoticeState();
}

class _UpgradeNoticeState extends State<UpgradeNotice> {
  bool _hasNewVersion = false;
  String _newVersion = '';
  String _releaseUrl = '';
  String _releaseNotes = '';
  Timer? _checkTimer;
  bool _isChecking = false;
  final String _dismissPrefix = '_update_dismissed_';
  @override
  void initState() {
    super.initState();

    // If auto check is enabled, delay the initial check and set the timer
    if (widget.autoCheck) {
      // Delay the initial check to avoid performance impact on app startup
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _checkForUpdates();
        }
      });
      _checkTimer =
          Timer.periodic(widget.checkInterval, (_) => _checkForUpdates());
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    // Prevent multiple simultaneous checks
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      // Get local storage
      final prefs = await SharedPreferences.getInstance();

      // Get the current application version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      debugPrint('Current application version: $currentVersion');

      // Check if the user has been notified
      final lastNotifiedVersion = prefs.getString('last_shown_version');
      if (widget.showOnlyOnce &&
          lastNotifiedVersion != null &&
          prefs.getBool('$_dismissPrefix$lastNotifiedVersion') == true) {
        setState(() {
          _isChecking = false;
        });
        return;
      }

      // Get the latest release version from GitHub
      final apiUrl =
          'https://api.github.com/repos/${widget.owner}/${widget.repo}/releases/latest';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion =
            data['tag_name'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
        final htmlUrl = data['html_url'] as String;
        final body = data['body'] as String?;

        debugPrint('Detected GitHub latest version: $latestVersion');

        if (_isNewerVersion(currentVersion, latestVersion)) {
          if (mounted) {
            setState(() {
              _hasNewVersion = true;
              _newVersion = latestVersion;
              _releaseUrl = htmlUrl;
              _releaseNotes = body ?? '';
            });

            // Record the latest notified version
            await prefs.setString('last_shown_version', latestVersion);
          }
        } else if (!widget.autoCheck && mounted) {
          // In manual check mode, display a prompt even if there is no new version
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Already the latest version"),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        debugPrint('GitHub API request failed, status code: ${response.statusCode}');
        if (!widget.autoCheck && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Check update failed"),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Check update error: $e');
      if (!widget.autoCheck && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Check update failed"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  bool _isNewerVersion(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();

      // Ensure the two lists have the same length
      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      while (latestParts.length < 3) {
        latestParts.add(0);
      }

      // Compare version numbers bit by bit
      for (var i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) {
          return true;
        } else if (latestParts[i] < currentParts[i]) {
          return false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Version comparison error: $e');
      return false;
    }
  }

  Future<void> _openReleaseUrl() async {
    if (_releaseUrl.isNotEmpty) {
      final url = Uri.parse(_releaseUrl);
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context)!.openUrlFailed)),
            );
          }
        }
      } catch (e) {
        debugPrint('Open URL error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.openUrlFailed)),
          );
        }
      }
    }
  }

  void _dismissUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_dismissPrefix$_newVersion', true);

    if (mounted) {
      setState(() {
        _hasNewVersion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS && !widget.enablePlatforms.contains("ios")) {
      return const SizedBox.shrink();
    }
    if (Platform.isAndroid && !widget.enablePlatforms.contains("android")) {
      return const SizedBox.shrink();
    }
    if (Platform.isMacOS && !widget.enablePlatforms.contains("macos")) {
      return const SizedBox.shrink();
    }
    if (Platform.isWindows && !widget.enablePlatforms.contains("windows")) {
      return const SizedBox.shrink();
    }
    if (Platform.isLinux && !widget.enablePlatforms.contains("linux")) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool isVeryNarrow = mediaQuery.size.width < 400;
    final bool isNarrow = mediaQuery.size.width < 600 && !isVeryNarrow;

    // If there is a new version, display the update notification
    if (_hasNewVersion) {
      return GestureDetector(
        onTap: () => _showUpdateDialog(context),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isVeryNarrow)
                const Icon(Icons.new_releases, size: 14, color: Colors.red)
              else ...[
                const Icon(Icons.arrow_downward, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                if (isNarrow)
                  const Icon(Icons.new_releases, size: 12, color: Colors.red)
                else
                  Flexible(
                    child: Text(
                      l10n.newVersionFound(_newVersion),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
    }

    // If manual check update is enabled and there is no new version, display the check update button
    if (widget.showCheckUpdate) {
      return GestureDetector(
        onTap: _isChecking ? null : () => _checkForUpdates(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isChecking
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.update, size: 14, color: Colors.grey),
              if (!isVeryNarrow) ...[
                const SizedBox(width: 4),
                Text(
                  _isChecking ? l10n.checkingForUpdates : l10n.checkUpdate,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _showUpdateDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.new_releases, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.newVersionFound(_newVersion)),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.newVersionAvailable),
                if (_releaseNotes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.releaseNotes,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(_releaseNotes,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _dismissUpdate();
                Navigator.of(context).pop();
              },
              child: Text(l10n.ignoreThisVersion),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.updateLater),
            ),
            FilledButton(
              onPressed: () {
                _openReleaseUrl();
                Navigator.of(context).pop();
              },
              child: Text(l10n.updateNow),
            ),
          ],
        );
      },
    );
  }
}
