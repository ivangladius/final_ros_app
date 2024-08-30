const connectBtn = document.getElementById('connectBtn');
const statusDiv = document.getElementById('status');
let webSocket;

/**
 * The div that will render the joystick.
 */
const joystick = document.getElementById('joystick');
const output = document.getElementById('output');
/**
 * The div containing the joystick
 */
const joystick_container = document.getElementById('joystick-container');

let active = false;
let containerRect = joystick_container.getBoundingClientRect();

joystick.addEventListener('mousedown', startDrag);
document.addEventListener('mousemove', drag);
document.addEventListener('mouseup', endDrag);
// joystick.addEventListener('touchstart', startDrag);
// document.addEventListener('touchmove', drag);
// document.addEventListener('touchend', endDrag);

let joystickX = 0;
let joystickY = 0;

/**
 * Speed Scale Slider
 */
const speedScale = document.getElementById('speedScale');
/**
 * Speed Scale input box
 */
const speedScaleValue = document.getElementById('speedScaleValue');

speedScale.addEventListener('input', () => {
    speedScaleValue.textContent = `${speedScale.value}%`;
    // Add code here to handle the change in speed scale
});

// Max Translational Speed
const maxTranslationalSpeed = document.getElementById('maxTranslationalSpeed');
// Add event listeners if needed

// Max Rotational Speed
const maxRotationalSpeed = document.getElementById('maxRotationalSpeed');
// Add event listeners if needed

// Motors ON/OFF Switch
const motorsSwitch = document.getElementById('motorsSwitch');
motorsSwitch.addEventListener('click', () => {
    // we want to toggle the current motor state
    if (motorsSwitch.getAttribute('data-status') === 'off') {
        // update the displayed motor state
        motorsSwitch.textContent = 'Motors: ON';
        // update the current enabled state
        motorsSwitch.setAttribute('data-status', 'on');
        // Add code to handle motors turning on
    } else {
        motorsSwitch.textContent = 'Motors: OFF';
        motorsSwitch.setAttribute('data-status', 'off');
        // Add code to handle motors turning off
    }
});

let activeTouchId = null; // To track the touch controlling the joystick

/**
 * Handle the start of the touch gesture on the joystick.
 * 
 * We only want to start the gesture if the joystick knob is touched!
 * 
 * @param {*} event 
 */
function startJoystickTouch(event) {
    for (let touch of event.touches) {
        if (isTouchOnJoystick(touch)) {
            activeTouchId = touch.identifier; // Assign the touch controlling the joystick
            moveJoystickToTouchPosition(touch);
            break; // Assuming only one touch controls the joystick at a time
        }
    }
    event.preventDefault();
}

function moveJoystickTouch(event) {
    for (let touch of event.touches) {
        if (touch.identifier === activeTouchId) {
            moveJoystickToTouchPosition(touch);
            break;
        }
    }
    event.preventDefault();
}

function endJoystickTouch(event) {
    if (activeTouchId !== null) {
        for (let touch of event.changedTouches) {
            if (touch.identifier === activeTouchId) {
                resetJoystickPosition();
                activeTouchId = null; // Reset the touch controlling the joystick
                break;
            }
        }
    }
    event.preventDefault();
}

function isTouchOnJoystick(touch) {
    const joystickRect = joystick.getBoundingClientRect();
    const touchX = touch.clientX;
    const touchY = touch.clientY;
    return touchX >= joystickRect.left && touchX <= joystickRect.right &&
           touchY >= joystickRect.top && touchY <= joystickRect.bottom;
}

function moveJoystickToTouchPosition(touch) {
    const containerRect = joystick_container.getBoundingClientRect();
    let x = touch.clientX - containerRect.left - containerRect.width / 2;
    let y = touch.clientY - containerRect.top - containerRect.height / 2;

    // ... Existing logic to limit joystick within container and set position ...
    // Limit joystick to container
    const radius = containerRect.width / 2;
    const distance = Math.min(radius, Math.sqrt(x*x + y*y));
    const angle = Math.atan2(y, x);

    x = distance * Math.cos(angle);
    y = distance * Math.sin(angle);

    joystick.style.left = `${x + radius}px`;
    joystick.style.top = `${y + radius}px`;

    // Normalize coordinates between -1 and 1
    joystickX = x / radius;
    joystickY = -y / radius; // Invert Y axis

    output.textContent = `X: ${joystickX.toFixed(2)}, Y: ${joystickY.toFixed(2)}`;
}

function resetJoystickPosition() {
    // ... Logic to reset joystick position to center ...
    joystick.style.left = '50%';
    joystick.style.top = '50%';
    output.textContent = 'X: 0, Y: 0';
    joystickX = 0.0;
    joystickY = 0.0; // Invert Y axis
}

// Attach the touch event handlers
joystick_container.addEventListener('touchstart', startJoystickTouch);
// document.addEventListener('touchstart', startJoystickTouch);
joystick_container.addEventListener('touchmove', moveJoystickTouch);
// document.addEventListener('touchmove', moveJoystickTouch);
joystick_container.addEventListener('touchend', endJoystickTouch);
joystick_container.addEventListener('touchcancel', endJoystickTouch); // Handle touch cancellation

function startDrag(event) {
    active = true;
    containerRect = joystick_container.getBoundingClientRect();
}

function drag(event) {
    if (!active) return;
    event.preventDefault();

    let x = (event.touches ? event.touches[0].clientX : event.clientX) - containerRect.left - containerRect.width / 2;
    let y = (event.touches ? event.touches[0].clientY : event.clientY) - containerRect.top - containerRect.height / 2;

    // Limit joystick to container
    const radius = containerRect.width / 2;
    const distance = Math.min(radius, Math.sqrt(x*x + y*y));
    const angle = Math.atan2(y, x);

    x = distance * Math.cos(angle);
    y = distance * Math.sin(angle);

    joystick.style.left = `${x + radius}px`;
    joystick.style.top = `${y + radius}px`;

    // Normalize coordinates between -1 and 1
    joystickX = x / radius;
    joystickY = -y / radius; // Invert Y axis

    output.textContent = `X: ${joystickX.toFixed(2)}, Y: ${joystickY.toFixed(2)}`;
}

function endDrag() {
    active = false;
    joystick.style.left = '50%';
    joystick.style.top = '50%';
    output.textContent = 'X: 0, Y: 0';
    joystickX = 0.0;
    joystickY = 0.0; // Invert Y axis
}

// Function to update the slider value from touch
function updateSliderFromTouch(touch) {
    const touchX = touch.clientX;
    const sliderRect = speedScale.getBoundingClientRect();
    const newSliderValue = ((touchX - sliderRect.left) / sliderRect.width) * 100;

    speedScale.value = Math.min(100, Math.max(0, newSliderValue)); // Clamp between 0 and 100
    speedScaleValue.textContent = `${Number(speedScale.value).toFixed(0)}%`;
}

// Handling touchstart event
speedScale.addEventListener('touchstart', (event) => {
    for (let touch of event.touches) {
        updateSliderFromTouch(touch);
    }
    event.preventDefault();
});

// Handling touchmove event
speedScale.addEventListener('touchmove', (event) => {
    for (let touch of event.touches) {
        updateSliderFromTouch(touch);
    }
    event.preventDefault();
});

function toggleMotorsTouch(event) {
    for (let touch of event.touches) {
        if (isTouchOnButton(touch, motorsSwitch)) {
            toggleMotors();
            break; // Assuming we want to respond to the first touch
        }
    }
    event.preventDefault();
}

function isTouchOnButton(touch, button) {
    const buttonRect = button.getBoundingClientRect();
    const touchX = touch.clientX;
    const touchY = touch.clientY;
    return touchX >= buttonRect.left && touchX <= buttonRect.right &&
           touchY >= buttonRect.top && touchY <= buttonRect.bottom;
}

function toggleMotors() {
    const isOn = motorsSwitch.getAttribute('data-status') === 'on';
    if (isOn) {
        motorsSwitch.setAttribute('data-status', 'off');
        motorsSwitch.textContent = 'Motors: OFF';
        // Add any additional logic needed when motors turn off
    } else {
        motorsSwitch.setAttribute('data-status', 'on');
        motorsSwitch.textContent = 'Motors: ON';
        // Add any additional logic needed when motors turn on
    }
}


connectBtn.addEventListener('click', () => {
    if (!webSocket || webSocket.readyState === WebSocket.CLOSED) {
        webSocket = new WebSocket('ws://192.168.2.24:8765');

        webSocket.onopen = () => {
            console.log('WebSocket connection opened');
            statusDiv.textContent = 'Status: Connected';
        };

        webSocket.onmessage = (event) => {
            console.log('Message from server:', event.data);
        };

        webSocket.onclose = (event) => {
            console.log('WebSocket connection closed:', event);
            statusDiv.textContent = 'Status: Disconnected';
        };

        webSocket.onerror = (error) => {
            console.error('WebSocket error:', error);
        };
    } else {
        console.log('WebSocket is already connected');
    }
});

// Attach touch event handler to the button
motorsSwitch.addEventListener('touchstart', toggleMotorsTouch);

window.addEventListener("gamepadconnected", (e) => {
    console.log("Gamepad connected:", e.gamepad);

    // Start polling gamepad
    requestAnimationFrame(updateGamepadStatus);
});

function updateGamepadStatus() {
    const gamepads = navigator.getGamepads();
    if (gamepads[0]) {
        const gamepad = gamepads[0];

        // Example: Update the slider value (speed scale) based on the first axis
        // Assuming gamepad.axes[0] ranges from -1 (left) to 1 (right)
        const speedScaleValue = (gamepad.axes[0] + 1) * 50; // Convert to range 0-100
        speedScale.value = speedScaleValue;
        speedScaleValueSpan.textContent = `${speedScaleValue.toFixed(0)}%`;

        // Example: Update max translational and rotational speed inputs
        // Assuming gamepad.buttons are used to increment/decrement speed
        if (gamepad.buttons[0].pressed) { // Button 0 increases translational speed
            maxTranslationalSpeed.value = parseFloat(maxTranslationalSpeed.value) + 0.1;
        }
        if (gamepad.buttons[1].pressed) { // Button 1 decreases translational speed
            maxTranslationalSpeed.value = parseFloat(maxTranslationalSpeed.value) - 0.1;
        }

        // Add similar logic for rotational speed and other controls as needed

        requestAnimationFrame(updateGamepadStatus);
    }
}


function sendData() {
    if (webSocket && webSocket.readyState === WebSocket.OPEN) {
        const scale = speedScale.value / 100;
        const maxTransSpeed = parseFloat(maxTranslationalSpeed.value) || 0;
        const maxRotSpeed = parseFloat(maxRotationalSpeed.value) || 0;

        // Correct the joystick values for translational and rotational speeds
        const translationalSpeed = maxTransSpeed * scale * joystickY; // Positive Y should move forward
        const rotationalSpeed = (maxRotSpeed * scale * -joystickX) / 180.0 * Math.PI; // Negative X should turn left

        const mode = document.getElementById('modeSelector').value;

        const data = {
            translationalSpeed: translationalSpeed.toFixed(2),
            rotationalSpeed: rotationalSpeed.toFixed(2),
            motorsOn: motorsSwitch.getAttribute('data-status') === 'on',
            mode: mode
        };

        webSocket.send(JSON.stringify(data));
        console.log('Data sent:', data);
    } else {
        console.error('WebSocket is not open');
    }
}

function openTab(evt, componentName) {
    var i, tabcontent, tablinks;
    
    // Hide all tab content by default
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "none";
    }
    
    // Remove the background color of all tablinks/buttons
    tablinks = document.getElementsByClassName("tablinks");
    for (i = 0; i < tablinks.length; i++) {
      tablinks[i].className = tablinks[i].className.replace(" active", "");
    }
    
    // Show the specific tab content and add an "active" class to the button that opened the tab
    document.getElementById(componentName).style.display = "block";
    evt.currentTarget.className += " active";
}
  
// Optionally, call openTab for the first tab so it shows when the page loads
document.addEventListener("DOMContentLoaded", function() {
    document.querySelector('.tablinks').click();
});

// Set up the timer
const interval = 100; // Adjust the interval in milliseconds as needed
setInterval(sendData, interval);