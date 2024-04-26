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
			print(player_index, " pressed A")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_X):
			print(player_index, " pressed X")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_B):
			print(player_index, " pressed B")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_Y):
			print(player_index, " pressed Y")
	else:
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_A):
			print(player_index, " pressed A and tried to select something")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_UP):
			print(player_index, " pressed Dpad up")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_RIGHT):
			print(player_index, " pressed Dpad right")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_DOWN):
			print(player_index, " pressed Dpad down")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_LEFT):
			print(player_index, " pressed Dpad left")

   
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
