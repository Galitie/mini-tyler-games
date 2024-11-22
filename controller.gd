extends Node

const DEADZONE: float = 0.2

var keyboard_array: Array = [
	KEY_Z,
	KEY_X,
	KEY_C,
	KEY_V,
	KEY_BACKSPACE,
	KEY_PLUS,
	KEY_ENTER,
	KEY_Q,
	KEY_W,
	KEY_A,
	KEY_S,
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4
]

class Gamepad:
	var device_id: int = -1
	var connected: bool = false
	var keyboard_controlled: bool = false
	
	var left_stick: Vector2 = Vector2.ZERO
	var right_stick: Vector2 = Vector2.ZERO
	
	var right_trigger: float
	
	var button_states: PackedByteArray = [
		0, # JOY_BUTTON_A
		0, # JOY_BUTTON_B
		0, # JOY_BUTTON_X
		0, # JOY_BUTTON_Y
		0, # JOY_BUTTON_BACK
		0, # JOY_BUTTON_GUIDE
		0, # JOY_BUTTON_START
		0, # JOY_BUTTON_LEFT_STICK
		0, # JOY_BUTTON_RIGHT_STICK
		0, # JOY_BUTTON_LEFT_SHOULDER
		0, # JOY_BUTTON_RIGHT_SHOULDER
		0, # JOY_BUTTON_DPAD_UP
		0, # JOY_BUTTON_DPAD_DOWN
		0, # JOY_BUTTON_DPAD_LEFT
		0, # JOY_BUTTON_DPAD_RIGHT
	]
	
	var prev_button_states: PackedByteArray = button_states.duplicate()

@onready var gamepads: Array = [
	Gamepad.new(),
	Gamepad.new(),
	Gamepad.new(),
	Gamepad.new()
]

func _ready() -> void:
	var device_ids: Array = Input.get_connected_joypads()
	for id in device_ids:
		if id < gamepads.size():
			gamepads[id].device_id = id
			gamepads[id].connected = true
	if !device_ids.size():
		gamepads[0].keyboard_controlled = true
		gamepads[0].device_id = 0
		gamepads[0].connected = true
			
func _physics_process(_delta: float) -> void:
	for gamepad in gamepads:
		if gamepad.connected:
			UpdateControllerState(gamepad.device_id)

func UpdateControllerState(device_id: int) -> void:
	var gamepad: Gamepad = gamepads[device_id]
	gamepad.prev_button_states = gamepad.button_states.duplicate()
	
	if !gamepad.keyboard_controlled:
		gamepad.left_stick = Vector2(Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X), Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y))
		if gamepad.left_stick.x > -DEADZONE && gamepad.left_stick.x < DEADZONE:
			gamepad.left_stick.x = 0
		if gamepad.left_stick.y > -DEADZONE && gamepad.left_stick.y < DEADZONE:
			gamepad.left_stick.y = 0
		gamepad.right_stick = Vector2(Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X), Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y))
		
		gamepad.right_trigger = Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_RIGHT)
	else:
		var left_stick_x: int = int(Input.is_key_pressed(KEY_RIGHT)) - int(Input.is_key_pressed(KEY_LEFT))
		var left_stick_y: int = int(Input.is_key_pressed(KEY_DOWN)) - int(Input.is_key_pressed(KEY_UP))
		gamepad.left_stick = Vector2(left_stick_x, left_stick_y)
		gamepad.right_trigger = Input.is_key_pressed(KEY_D)
	
	for i in range(gamepad.button_states.size()):
		if !gamepad.keyboard_controlled:
			gamepad.button_states[i] = int(Input.is_joy_button_pressed(gamepad.device_id, i))
		else:
			gamepad.button_states[i] = int(Input.is_key_pressed(keyboard_array[i]))
		
func IsControllerButtonJustPressed(device_id: int, button: int) -> bool:
	if gamepads[device_id].button_states[button] == 1:
		if gamepads[device_id].button_states[button] != gamepads[device_id].prev_button_states[button]:
			return true
	return false
	
func IsControllerButtonJustReleased(device_id: int, button: int) -> bool:
	if gamepads[device_id].button_states[button] == 0:
		if gamepads[device_id].button_states[button] != gamepads[device_id].prev_button_states[button]:
			return true
	return false
	
func IsControllerButtonPressed(device_id: int, button: int) -> bool:
	if gamepads[device_id].button_states[button] == 1:
		return true
	return false

func GetLeftStick(device_id: int) -> Vector2:
	return gamepads[device_id].left_stick
	
func GetRightStick(device_id: int) -> Vector2:
	return gamepads[device_id].right_stick

func GetRightTrigger(device_id: int) -> float:
	return gamepads[device_id].right_trigger
