# Update package list and install necessary packages
apt-get update
apt-get install -y ros-noetic-turtlesim tigervnc-standalone-server tigervnc-common websockify novnc supervisor xfce4 xfce4-terminal x11vnc xvfb
apt-get clean

# Set up VNC server with a password
mkdir -p /root/.vnc
x11vnc -storepasswd 1234 /root/.vnc/passwd

# Create supervisor configuration file
cat <<EOF > /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 1024x768x16
autostart=true
autorestart=true
environment=DISPLAY=:1

[program:xvnc]
command=/usr/bin/x11vnc -forever -usepw -display :1
autostart=true
autorestart=true

[program:websockify]
command=/usr/bin/websockify --web=/usr/share/novnc/ 8080 localhost:5900
autostart=true
autorestart=true

[program:turtlesim]
command=/bin/bash -c 'source /opt/ros/noetic/setup.bash && rosrun turtlesim turtlesim_node'
autostart=true
autorestart=true
environment=DISPLAY=:1
EOF

# Start supervisor to run the services
/usr/bin/supervisord