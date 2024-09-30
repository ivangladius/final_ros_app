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
    git \
    curl \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    wget \
    ca-certificates \
    gnupg \
    iproute2 \
    net-tools \
    iputils-ping \
    traceroute \
    nmap \
    netcat \
    tcpdump \
    telnet \
    dnsutils \
    whois \
    htop \
    iftop \
    iotop \
    vim \
    nano \
    tmux \
    screen \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set up catkin workspace
RUN mkdir -p /root/catkin_ws/src
WORKDIR /root/catkin_ws
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; catkin init'

# Copy frost_msgs package
COPY frost_msgs /root/catkin_ws/src/frost_msgs

# Build the workspace
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash && catkin build'

# Create virtual environment in /opt
RUN python3 -m venv /opt/venv

# Activate virtual environment and install dependencies
COPY requirements.txt /tmp/requirements.txt
RUN /bin/bash -c "source /opt/venv/bin/activate && pip install -r /tmp/requirements.txt"

# Source the workspace and activate venv in .bashrc
RUN echo "source /root/catkin_ws/devel/setup.bash" >> /root/.bashrc && \
    echo "source /opt/venv/bin/activate" >> /root/.bashrc

WORKDIR /root/app

# Copy the application code
COPY . /root/app

# Copy start script
COPY start.sh /root/app/start.sh
RUN chmod +x /root/app/start.sh

# Set the entrypoint to keep the container running
CMD ["./start.sh"]
