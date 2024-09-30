import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class PowertrainTab extends StatefulWidget {
  const PowertrainTab({super.key});

  @override
  State<PowertrainTab> createState() => _PowertrainTabState();
}

class _PowertrainTabState extends State<PowertrainTab> {
  WebSocketChannel? channel;
  bool isConnected = false;
  bool isRobotMode = true;
  bool motorsOn = false;

  void _toggleConnection() {
    if (isConnected) {
      _disconnectWebSocket();
    } else {
      _connectWebSocket();
    }
  }

  void _connectWebSocket() {
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8765'));
    channel!.stream.listen(
      (message) {
        print('Received: $message');
      },
      onError: (error) {
        print('Error: $error');
        setState(() => isConnected = false);
      },
      onDone: () {
        print('WebSocket connection closed');
        setState(() => isConnected = false);
      },
    );
    setState(() => isConnected = true);
    print('WebSocket connection attempted');
  }

  void _disconnectWebSocket() {
    channel?.sink.close();
    setState(() => isConnected = false);
    print('WebSocket disconnected');
  }

  void _sendJoystickData(double x, double y) {
    if (!isConnected) return;

    final jsonData = jsonEncode({
      'mode': isRobotMode ? 'robot' : 'turtle',
      'motorsOn': motorsOn ? 1 : 0,
      'translationalSpeed': y,
      'rotationalSpeed': x,
    });

    print('Sending data: $jsonData');
    channel?.sink.add(jsonData);
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Connection status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.error,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Connect/Disconnect button
          ElevatedButton(
            onPressed: _toggleConnection,
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(isConnected ? 'Disconnect' : 'Connect'),
          ),
          const SizedBox(height: 20),
          Joystick(
            onStickDragEnd: () => _sendJoystickData(0, 0),
            listener: (details) {
              print('Joystick moved: x=${details.x}, y=${details.y}');
              _sendJoystickData(details.x, -details.y);
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                value: isRobotMode,
                onChanged: (value) => setState(() => isRobotMode = value),
              ),
              Text(isRobotMode ? 'Robot Mode' : 'Turtle Mode'),
              const SizedBox(width: 20),
              Switch(
                value: motorsOn,
                onChanged: (value) => setState(() => motorsOn = value),
              ),
              const Text('Motors'),
            ],
          ),
        ],
      ),
    );
  }
}
