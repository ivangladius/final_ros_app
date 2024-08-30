#!/bin/bash

# Define variables
DISPLAY=:1
TURTLESIM_NODE=turtlesim_node
PACKAGE_NAME=turtlesim

# Source ROS setup files
source /opt/ros/noetic/setup.bash

# Source workspace setup if it exists
if [ -f ~/catkin_ws/devel/setup.bash ]; then
    source ~/catkin_ws/devel/setup.bash
fi

# Ensure DISPLAY is set
export DISPLAY=$DISPLAY

# Function to stop existing turtlesim node
stop_existing_turtlesim() {
    echo "Stopping any existing turtlesim node..."
    pkill -f "rosrun $PACKAGE_NAME $TURTLESIM_NODE"
    sleep 2  # Give it a moment to terminate
}

# Function to start turtlesim
start_turtlesim() {
    echo "Starting turtlesim on display $DISPLAY..."
    rosrun $PACKAGE_NAME $TURTLESIM_NODE
}

# Stop any existing instance of turtlesim
stop_existing_turtlesim

# Start turtlesim
start_turtlesim

