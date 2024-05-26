extends Node

class Gamepad:
	var device_id: int = -1
	var connected: bool = false
	
	var left_stick: Vector2 = Vector2.ZERO
	var right_stick: Vector2 = Vector2.ZERO
	
	var button_states: PackedByteArray = [
		0, # JOY_BUTTON_A
		0, # JOY_BUTTON_B
		0, # JOY_BUTTON_X
		0  # JOY_BUTTON_Y
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
			
func _physics_process(delta: float) -> void:
	for gamepad in gamepads:
		if gamepad.connected:
			UpdateControllerState(gamepad.device_id)

func UpdateControllerState(device_id: int) -> void:
	var gamepad: Gamepad = gamepads[device_id]
	gamepad.prev_button_states = gamepad.button_states.duplicate()
	gamepad.left_stick = Vector2(Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X), Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y))
	gamepad.right_stick = Vector2(Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X), Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y))
	for i in range(gamepad.button_states.size()):
		gamepad.button_states[i] = int(Input.is_joy_button_pressed(gamepad.device_id, i))
		
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
