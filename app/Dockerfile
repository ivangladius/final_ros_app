# Use the official ROS Noetic base image
FROM ros:noetic-ros-base

# Install necessary packages
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    python3-catkin-tools \
    python3-rospy \
    ros-noetic-std-msgs \
    ros-noetic-geometry-msgs \
    ros-noetic-nav-msgs \
    && rm -rf /var/lib/apt/lists/*

# Set up catkin workspace
RUN mkdir -p /root/catkin_ws/src
WORKDIR /root/catkin_ws
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; catkin init'

# Copy frost_msgs package
COPY frost_msgs /root/catkin_ws/src/frost_msgs

# Build the workspace
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash && catkin build'

# Source the workspace in .bashrc
RUN echo "source /root/catkin_ws/devel/setup.bash" >> /root/.bashrc

WORKDIR /root/app

# Copy application files
COPY . .

# Create virtual environment
RUN python3 -m venv venv

# Activate virtual environment and install dependencies
RUN /bin/bash -c "source venv/bin/activate && pip install -r requirements.txt"

# Make start script executable
RUN chmod +x start.sh

# Copy start.sh script
COPY start.sh /root/app/start.sh
RUN chmod +x /root/app/start.sh

# Set the entrypoint
CMD ["/bin/bash", "-c", "./start.sh"]
