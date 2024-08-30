#!/bin/env python
import asyncio
import websockets
import json
import argparse
from http.server import SimpleHTTPRequestHandler
from socketserver import TCPServer
import rospy

from frost_msgs.msg import PowertrainCommand
from geometry_msgs.msg import Twist

pub = None

async def echo(websocket, path):
    async for message in websocket:
        data = json.loads(message)
        print(f"Received data: {data}")

        mode = data.get('mode', 'robot')
        if mode == 'robot':
            msg = PowertrainCommand()
            msg.mode = 1
            msg.enabled = int(data['motorsOn'])
            msg.trans_vel = float(data['translationalSpeed'])
            msg.rot_vel = float(data['rotationalSpeed'])
        else:
            msg = Twist()
            msg.linear.x = float(data['translationalSpeed'])
            msg.angular.z = float(data['rotationalSpeed'])

        pub.publish(msg)

# Simple HTTP Server to serve static files
class HTTPServer(TCPServer):
    allow_reuse_address = True

def start_http_server():
    handler = SimpleHTTPRequestHandler
    httpd = HTTPServer(("0.0.0.0", 8000), handler)
    print("HTTP server is running at http://localhost:8000")
    httpd.serve_forever()

async def main(mode):
    global pub

    if mode == 'real':
        pub = rospy.Publisher('chatter', PowertrainCommand, queue_size=10)
    else:
        pub = rospy.Publisher('/turtle1/cmd_vel', Twist, queue_size=10)

    rospy.init_node('talker', anonymous=True)

    # Start HTTP server in a new thread
    from threading import Thread
    http_server_thread = Thread(target=start_http_server, daemon=True)
    http_server_thread.start()

    async with websockets.serve(echo, "0.0.0.0", 8765):
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run the server in either real or turtle mode.')
    parser.add_argument('mode', choices=['real', 'turtle'], help='Mode to run the server in: real or turtle')
    args = parser.parse_args()

    asyncio.run(main(args.mode))