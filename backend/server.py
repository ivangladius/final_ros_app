#!/bin/env python
import asyncio
import websockets
import json
import argparse
from http.server import SimpleHTTPRequestHandler
from socketserver import TCPServer
import rospy
import os

from frost_msgs.msg import PowertrainCommand
from geometry_msgs.msg import Twist

pub = None

async def echo(websocket, path, mode):
    try:
        async for message in websocket:
            print(f"Raw message received: {message}")
            try:
                data = json.loads(message)
                print(f"Received data: {data}")

                if mode == 'robot':
                    msg = PowertrainCommand()
                    msg.mode = 1
                    msg.enabled = int(data['motorsOn'])
                    msg.trans_vel = float(data['translationalSpeed'])
                    msg.rot_vel = float(data['rotationalSpeed'])
                else:  # turtle mode
                    msg = Twist()
                    msg.linear.x = float(data['translationalSpeed'])
                    msg.angular.z = float(data['rotationalSpeed'])

                pub.publish(msg)
                print(f"Published message to {pub.name}: {msg}")
            except json.JSONDecodeError:
                print(f"Failed to parse JSON: {message}")
            except Exception as e:
                print(f"Error processing message: {e}")
    except websockets.exceptions.ConnectionClosed:
        print("WebSocket connection closed")
    except Exception as e:
        print(f"Unexpected error in echo function: {e}")

# Simple HTTP Server to serve static files
class HTTPServer(TCPServer):
    allow_reuse_address = True

def start_http_server():
    handler = SimpleHTTPRequestHandler
    httpd = HTTPServer(("0.0.0.0", 9999), handler)
    print("HTTP server is running at http://localhost:9999")
    httpd.serve_forever()

async def main(mode):
    global pub

    # Ensure ROS_MASTER_URI is set correctly
    ros_master_uri = os.environ.get('ROS_MASTER_URI', 'http://vnc_ros:11311')
    print(f"Connecting to ROS Master at: {ros_master_uri}")
    os.environ['ROS_MASTER_URI'] = ros_master_uri

    # Set ROS_IP to the container's IP address
    ros_ip = os.environ.get('ROS_IP', '0.0.0.0')
    print(f"Setting ROS_IP to: {ros_ip}")
    os.environ['ROS_IP'] = ros_ip

    # Initialize the ROS node
    rospy.init_node('websocket_to_ros_bridge', anonymous=True)

    # Wait for the ROS master to be available
    while not rospy.is_shutdown():
        try:
            rospy.get_master().getPid()
            print("Successfully connected to ROS Master")
            break
        except Exception as e:
            print(f"Waiting for ROS Master... ({e})")
            await asyncio.sleep(1)

    if mode == 'robot':
        pub = rospy.Publisher('chatter', PowertrainCommand, queue_size=10)
    else:  # turtle mode
        pub = rospy.Publisher('/turtle1/cmd_vel', Twist, queue_size=10)

    print(f"Created publisher: {pub.name}, type: {pub.type}")

    # Start HTTP server in a new thread
    from threading import Thread
    http_server_thread = Thread(target=start_http_server, daemon=True)
    http_server_thread.start()

    print(f"WebSocket server starting on 0.0.0.0:8765")
    async with websockets.serve(lambda ws, path: echo(ws, path, mode), "0.0.0.0", 8765):
        print("WebSocket server is now running")
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run the server in either robot or turtle mode.')
    parser.add_argument('mode', choices=['robot', 'turtle'], help='Mode to run the server in: robot or turtle')
    args = parser.parse_args()

    asyncio.run(main(args.mode))