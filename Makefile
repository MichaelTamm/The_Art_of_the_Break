.PHONY: init clean format lint test

init: .flutter-plugins-dependencies lib/main.directories.g.dart

.flutter-plugins-dependencies: pubspec.yaml
	flutter pub get

lib/main.directories.g.dart: lib/use_cases/*.dart
	dart run build_runner build

clean:
	flutter clean
	rm -f lib/main.directories.g.dart

format:
	dart format lib/

lint: .flutter-plugins-dependencies
	dart format --output none --set-exit-if-changed lib/ scripts/ test/
	flutter analyze --no-pub --fatal-warnings

test: .flutter-plugins-dependencies
	flutter test