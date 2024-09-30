# Flutter web port
PORT = 8081

# Build the Flutter app
build:
	flutter pub get
	flutter build web

# Start the Flutter web service
start:
	flutter run -d web-server --web-port=$(PORT) --web-hostname=0.0.0.0

# Stop the Flutter web service
stop:
	pkill -f "flutter run"

# Clean the project
clean:
	flutter clean
	rm -rf build
	rm -rf .dart_tool
	rm -f pubspec.lock

.PHONY: build start stop