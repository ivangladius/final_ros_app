# Dockerfile.vnc_ros
# Use the official ROS Noetic base image
FROM ros:noetic-ros-base

# Install necessary packages
RUN apt-get update && apt-get install -y \
    x11vnc \
    xvfb \
    websockify \
    wget \
    tigervnc-standalone-server \
    ros-noetic-turtlesim \
    && rm -rf /var/lib/apt/lists/*

# Download and set up noVNC
RUN wget https://github.com/novnc/noVNC/archive/v1.2.0.tar.gz -O /tmp/noVNC.tar.gz && \
    tar -xzf /tmp/noVNC.tar.gz -C /root && \
    mv /root/noVNC-1.2.0 /root/noVNC && \
    ln -s /root/noVNC/vnc.html /root/noVNC/index.html && \
    rm /tmp/noVNC.tar.gz

# Set up VNC password
RUN mkdir -p /root/.vnc && \
    echo "1234" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Copy start script
COPY start_streaming_turtle.sh /root/start_streaming_turtle.sh
RUN chmod +x /root/start_streaming_turtle.sh

# Set the working directory
WORKDIR /root

# Set the command to run
CMD ["./start_streaming_turtle.sh"]