#!/bin/bash

set -e
# Source ROS setup
source /opt/ros/noetic/setup.bash

# Start roscore with specific binding
roscore &

# Wait for roscore to be up
until rostopic list > /dev/null 2>&1; do
    echo "Waiting for roscore to start..."
    sleep 1
done
echo "roscore is up!"

# Start Xvfb
Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1

# Wait for Xvfb to be up
sleep 2

# Start VNC server on port 5901
x11vnc -display :1 -forever -passwd 1234 -rfbport 5901 &

# Wait for VNC server to be up
sleep 2

# Start turtlesim
rosrun turtlesim turtlesim_node &

# Start noVNC
/root/noVNC/utils/launch.sh --vnc localhost:5901 --listen 6080

# Keep the script running
tail -f /dev/null
