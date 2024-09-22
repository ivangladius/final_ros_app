#!/bin/bash

# Define variables
DISPLAY=:1
VNC_PORT=5901
NO_VNC_PORT=6080
VNC_PASSWORD_FILE=/root/.vnc/passwd
NO_VNC_DIR=/root/noVNC

# Function to kill existing processes
kill_existing_processes() {
    echo "Killing existing x11vnc, Xvfb, noVNC, roscore, and turtlesim processes..."
    pkill -f x11vnc
    pkill -f Xvfb
    pkill -f websockify
    pkill -f roscore
    pkill -f turtlesim_node
}

# Function to create x11vnc password
create_x11vnc_password() {
    echo "Creating x11vnc password..."
    # Ensure the directory exists
    mkdir -p $(dirname $VNC_PASSWORD_FILE)

    # Check if password file exists
    if [ ! -f $VNC_PASSWORD_FILE ]; then
        echo "Password file not found. Creating a new one..."
        # Set a default password
        echo "1234" | x11vnc -storepasswd -f $VNC_PASSWORD_FILE
    else
        echo "x11vnc password file already exists."
    fi

    # Debugging: Display the contents of the password file
    echo "Contents of $VNC_PASSWORD_FILE:"
    cat $VNC_PASSWORD_FILE
}

# Function to start Xvfb
start_xvfb() {
    echo "Starting Xvfb on display $DISPLAY..."
    Xvfb $DISPLAY -screen 0 1024x768x24 &
    XVFB_PID=$!
}

# Function to start x11vnc
start_x11vnc() {
    echo "Starting x11vnc on display $DISPLAY..."
    x11vnc -display $DISPLAY -rfbauth $VNC_PASSWORD_FILE -N -forever &
    X11VNC_PID=$!
}

# Function to start noVNC with WebSocket
start_noVNC() {
    echo "Starting noVNC on port $NO_VNC_PORT..."
    cd $NO_VNC_DIR
    ./utils/launch.sh --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT &
    NOVNC_PID=$!
}

# Function to start roscore
start_roscore() {
    echo "Starting roscore..."
    source /opt/ros/noetic/setup.bash
    roscore &
    ROSCORE_PID=$!
    sleep 5  # Give roscore some time to start up
}

# Function to start turtlesim
start_turtlesim() {
    echo "Starting turtlesim..."
    source /opt/ros/noetic/setup.bash
    export DISPLAY=$DISPLAY
    rosrun turtlesim turtlesim_node &
    TURTLESIM_PID=$!
}

# Function to handle termination signals
cleanup() {
    echo "Caught termination signal! Cleaning up..."
    kill_existing_processes
    exit 0
}

# Trap termination signals
trap cleanup SIGINT SIGTERM

# Execute functions
kill_existing_processes
create_x11vnc_password
start_xvfb
start_x11vnc
start_noVNC
start_roscore
start_turtlesim

echo "Setup complete. You can access the VNC stream at http://<VPS_PUBLIC_IP>:$NO_VNC_PORT/vnc.html"

# Keep the script running
tail -f /dev/null
