lan:
	flutter gen-l10n

dep:
	dart pub global run dependency_validator

upgrade:
	flutter pub upgrade --major-versions

# Android 签名相关命令
android-keystore:
	./scripts/create_keystore.sh

android-verify:
	./scripts/verify_signing.sh

android-apk:
	flutter build apk --release

android-apk-split:
	flutter build apk --release --split-per-abi

android-aab:
	flutter build appbundle --release

android-build: android-apk android-aab

android-build-all: android-apk-split android-aab

android-summary:
	./scripts/build_summary.sh

# 清理构建文件
clean:
	flutter clean
	flutter pub get

# 完整的发布构建
release-android: clean android-verify android-build-all android-summary

.PHONY: lan dep upgrade android-keystore android-verify android-apk android-apk-split android-aab android-build android-build-all android-summary clean release-android