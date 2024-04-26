class_name Player
extends Node
var mon : CharacterBody2D
var wins : int = 0
var losses : int = 0
var player_index : int
var fight_mode : bool

func _ready():
	set_mon()
	set_device()


func update(_delta):
	if fight_mode:
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_A):
			pass
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_X):
			pass
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_B):
			pass
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_Y):
			pass
	else:
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_A):
			pass # press button
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_UP):
			pass
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_RIGHT):
			pass
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_DOWN):
			pass
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_LEFT):
			pass

   
func set_mon():
	mon = get_child(0)

func set_device():
	var controllers = Input.get_connected_joypads()
	if name == "player1":
		player_index = 0
	if name == "player2":
		player_index = 1
	if name == "player3":
		player_index = 2
	if name == "player4":
		player_index = 3


func switch_modes(fight_time):
	if fight_time:
		fight_mode = true
	else:
		fight_mode = false
