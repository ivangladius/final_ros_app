#!/bin/bash
source /opt/ros/noetic/setup.bash
source /root/catkin_ws/devel/setup.bash

echo "Waiting for roscore..."
until rostopic list > /dev/null 2>&1; do
    echo "Waiting for roscore to start..."
    sleep 1
done
echo "roscore is up!"

echo "Starting app backend..."
/bin/bash -c "source /opt/venv/bin/activate && python3 server.py turtle"