# Variables
IMAGE_NAME = flutter-web-app
CONTAINER_NAME = flutter-web-container
PORT = 8080
CURRENT_DIR = $(shell pwd)

# Phony targets
.PHONY: build run stop rm clean rebuild logs rebuild-app

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the Docker container
run:
	docker run -it --rm \
		-p $(PORT):8080 \
		--name $(CONTAINER_NAME) \
		-v $(CURRENT_DIR):/app \
		-e TERM=xterm-256color \
		$(IMAGE_NAME)

# Stop the Docker container
stop:
	docker stop $(CONTAINER_NAME)

# Remove the Docker container
rm:
	docker rm $(CONTAINER_NAME)

# Clean up (stop and remove the container)
clean: stop rm

# Rebuild the Docker image and run the container
rebuild: clean build run

# Show logs from the container
logs:
	docker logs -f $(CONTAINER_NAME)

# Attach to the container
attach:
	docker attach --sig-proxy=false $(CONTAINER_NAME)

# Trigger a rebuild of the Flutter app
rebuild-app:
	docker exec -it $(CONTAINER_NAME) flutter pub get
	docker exec -it $(CONTAINER_NAME) flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0 --debug

# Clean the project
clean:
	flutter clean
	rm -rf build
	rm -rf .dart_tool
	rm -f pubspec.lock