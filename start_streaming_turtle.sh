#!/bin/bash

# Define variables
DISPLAY=:1
VNC_PORT=5901
NO_VNC_PORT=6080
VNC_PASSWORD_FILE=/root/.vnc/passwd
NO_VNC_DIR=/root/noVNC

# Function to kill existing processes
kill_existing_processes() {
    echo "Killing existing x11vnc, Xvfb, and noVNC processes..."
    pkill -f x11vnc
    pkill -f Xvfb
    pkill -f websockify
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

# Function to wait for processes
wait_for_processes() {
    echo "Waiting for processes to start..."
    sleep 5
}

# Function to check process status
check_process_status() {
    if ! ps -p $XVFB_PID > /dev/null; then
        echo "Xvfb did not start successfully."
        exit 1
    fi

    if ! ps -p $X11VNC_PID > /dev/null; then
        echo "x11vnc did not start successfully."
        exit 1
    fi

    if ! ps -p $NOVNC_PID > /dev/null; then
        echo "noVNC did not start successfully."
        exit 1
    fi
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
wait_for_processes
check_process_status

echo "Setup complete. You can access the VNC stream at http://<VPS_PUBLIC_IP>:$NO_VNC_PORT/vnc.html"

# Keep the script running
tail -f /dev/null
