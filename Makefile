# Makefile

# Variables
IMAGE_NAME := ros_noetic_project
CONTAINER_NAME := ros_noetic_container
HOST_DIR := $(shell pwd)
CONTAINER_DIR := /workspace

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the Docker container with the current directory mounted and remove it after it stops
run:
	docker run -it --rm --name $(CONTAINER_NAME) -p 5901:5901 -p 6080:6080 -v $(HOST_DIR):$(CONTAINER_DIR) $(IMAGE_NAME)

# Stop the Docker container
stop:
	docker stop $(CONTAINER_NAME)

# Remove the Docker image
clean-image:
	docker rmi $(IMAGE_NAME)

# Rebuild and run the Docker container
rebuild: clean-image build run