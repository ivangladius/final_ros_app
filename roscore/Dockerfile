# Use the ROS Noetic base image
FROM ros:noetic-ros-base

# Install curl for health check and roscore explicitly
RUN apt-get update && apt-get install -y \
    curl \
    ros-noetic-ros-core \
    && rm -rf /var/lib/apt/lists/*

# Copy a startup script
COPY start_roscore.sh /start_roscore.sh
RUN chmod +x /start_roscore.sh

# Set the entrypoint to our startup script
CMD ["/start_roscore.sh"]