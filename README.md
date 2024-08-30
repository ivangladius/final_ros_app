# FRoST Webapp

This ROS application can be used for controlling the rover from any mobile device.
The core component is a web server implemented in python that serves a website, consisting of javascript and HTML.

The webapp itself connects to the web server via websockets and exchanges JSON payload with the rover commands.
Currently only the powertrain (track drive) command is implemented. But other components can be included as well if their command or status interface is implemented in ROS.

The main requirement for controlling rover components over ROS topics is that they implement some kind of delegation:
The component should be able to differentiate between (real) groundstation commands and commands by other applications (autonomy, this remote control application) for avoiding collisions.

## Dependencies

Currently the dependencies are not documented.
Have a look in the imports of the main python file `server.py`.

## Starting the Webapp

The process is as simple as running:

```python server.py```

## Accessing the Webapp

By default the webserver listens for the 0.0.0.0:8000 address. This means that the webapp can be accessed by any address of the host computer.

The easiest way (e.g. on the rover) for accessing the webapp is by entering the mDNS (e.g. with avahi bonjour) address: on the rover it's `ai-core.local:8000`.

## ToDo's

* Adding status messages to the webapp (velocities for powertrain)
* Adding more components (e.g. robotarm - but a better implementation for the robotarm control chain command interface in ROS is needed)
* Tidying up the interface
* Improving the responsiveness of the layout (e.g. for tables, smaller screens)
* Adding auto connect and auto reconnect for websockets
* Adding command delegation (for multiple connected devices)

And the crazy ones:
* Implementing camera streams?
