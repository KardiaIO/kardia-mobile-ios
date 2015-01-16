[![Stories in Ready](https://badge.waffle.io/EKGAPI/KardiaApp.png?label=ready&title=Ready)](https://waffle.io/EKGAPI/KardiaApp)
KardiaApp
=========
## Overview
This is Swift iOS app (built in XCode 6.1.1) is provided as an example for developers intested in the Kardia.io ecosystem. It is currently hard-coded to connect to and read data from RedBearLabs Blend Micro units that are loaded with the firmware recommended by the RedBearLabs website. We <a href="https://github.com/EKGAPI/BLE-Sketch">programmed</a> these units to emit mock data that simulates a real ECG trace. This app connects the phone to the device and relays the data being emitted to the servers (<a href="https://github.com/EKGAPI/webAppEKGAPI">node.js</a> and <a href="https://github.com/EKGAPI/pythonEKGAPI">python</a>) at Kardia.io. The app also listens for and displays analysis coming back from the servers.

## Installation and Usage
Clone the repo and open in XCode. Load the app onto your phone. The app will automatically connect to nearby BLE units with the appropriate service and characteristic UUIDs (see below) and begin streaming data to kardia.io. Analyzed data comes back to the app in real time. Any abnormal events (arrhythmia) will be recorded in the table view that can be accessed by swiping left or right. These events can be deleted by pulling them to the left.

## UUIDs
The app looks for the service UUID 713D0000-503E-4C75-BA94-3148F18D941E which contains the characteristic UUID 713D0002-503E-4C75-BA94-3148F18D941E that corresponds to the data being emitted by the Arduino. These values are defined in the firmware for the Blend Micro linked on the RedBearLabs website.

## Data Format and Flow
Once the app connects to a BLE device (see below for a brief explanation), it registers a listener for changes in the status of the hardware's data characteristic. This data is interpreted as a float and passed to two callback functions. One adds it to a buffer of recent data points for rendering in the graph. The other emits it as a socket event. It is emitted as a JSON object with keys "amplitude" and "time" corresponding to the value received from the hardware and the ISO8601 time the socket event was emitted, respectively.

The app also listens for responses from the server, which are JSON objects that have "heartRate" (self-explanatory) and "statusCode" keys. The status code is looked up in a dictionary defined in ViewController.swift and translated into the main view as statusView.

## Sockets
We use the <a href="https://github.com/nuclearace/Socket.IO-Client-Swift">SocketIOClient</a> library, which wraps the Objective-C library <a href="https://github.com/square/SocketRocket">Socket Rocket</a>. The following events are used:

- Emit "message" to server.
- Listen for "node.js" response from server.
- Emit "/BLEDisconnect" when app is disconnected from hardware.

## Line Charts
We use the <a href="https://github.com/zemirco/swift-linechart">Swift-Linechart</a> library to render the live ECG traces. It did not entirely meet our needs so we modified it as follows:

- Line color changed to white.
- Y-scale modified to better scale our data, which all falls in a fairly narrow range.

## Abnormal Events
When the app registers a fresh abnormality, it records it in the arrhythmiaTimes global, which serves as the data source for the table view. "Fresh" in this case means an event is only recorded if the status being reported by the server *changes* to an abnormal event (in this case, arrhythmia) so that repeated arrhythmia events do not all get logged.

## Roadmap
Please see the issues section of this repo.

---

## For Swift Newbies
### Bluetooth Low-Energy
<a href="http://www.raywenderlich.com/85900/arduino-tutorial-integrating-bluetooth-le-ios-swift">Here</a> is a good tutorial on connecting a BLE device to an iOS device using Swift. In brief, the app starts searching for Bluetooth peripherals that are advertising a specific service UUID. When one is found, it connects and looks for a specific characteristic UUID. If that is found, it begins listening to that data.

### Rendering view updates
Any time the view needs updating, you have to run that code on the main (UI) thread. That's why you'll see blocks of code like this:

    dispatch_async(dispatch_get_main_queue()) {
      // UI-updating code goes here
    }

### Events
Events are handled by the NSNotificationCenter - registering listeners and firing events is pretty self-explanatory. Here's a quick Swift : Javascript translation of terms:

- addObserver : on
- Selector : callback
- name : <event name>
- object : doesn't have a direct JS counterpart; restricts which objects are involved in event interactions.

Example:

    foo.on('bar', doAThing)
becomes

    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("doAThing"), name: "bar", object: nil)


### Misc
Functions can have the same name as long as they have different parameters - this happens often with protocols.

Views can be created and constrained in either Main.storyboard or programmatically in code. This app uses a mixture of the two - the main view is all done in the latter style while the table view uses the former.