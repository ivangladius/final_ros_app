# Use the official ROS Noetic base image
FROM ros:noetic-ros-core

# Install necessary packages
RUN apt-get update && apt-get install -y \
    x11vnc \
    xvfb \
    websockify \
    wget \
    tigervnc-standalone-server \
    ros-noetic-turtlesim \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NO_VNC_PORT=6080

# Copy the start script into the container
COPY start_streaming_turtle.sh /root/start_streaming_turtle.sh

# Make the script executable
RUN chmod +x /root/start_streaming_turtle.sh

# Download and setup noVNC
RUN wget https://github.com/novnc/noVNC/archive/v1.2.0.tar.gz -O /tmp/noVNC.tar.gz && \
    tar -xzf /tmp/noVNC.tar.gz -C /root && \
    mv /root/noVNC-1.2.0 /root/noVNC && \
    rm /tmp/noVNC.tar.gz

# Set up VNC password
RUN mkdir -p /root/.vnc && \
    echo "1234" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Expose the necessary ports
EXPOSE $VNC_PORT $NO_VNC_PORT

# Set the entrypoint to the start script
ENTRYPOINT ["/root/start_streaming_turtle.sh"]