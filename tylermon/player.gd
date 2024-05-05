class_name Player
extends Node
var mon : CharacterBody2D
var wins : int = 0
var total : int
var player_index : int
var fight_mode : bool
var current_place : int

const STATE = preload("res://tylermon/mon.gd")


func _ready():
	set_mon()
	set_device()


func _process(_delta):
	if !fight_mode:
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_A):
			if Input.is_action_just_pressed("tylermon_accept"):
				print("player ", player_index, " pressed X")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_UP):
			print("player ", player_index, " pressed Dpad up")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_RIGHT):
			print("player ", player_index, " pressed Dpad right")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_DOWN):
			print("player ", player_index, " pressed Dpad down")
		if Input.is_joy_button_pressed(player_index,JOY_BUTTON_DPAD_LEFT):
			print("player ", player_index, " pressed Dpad left")

   
func set_mon():
	mon = get_child(0)


func set_device():
	if name == "player0":
		player_index = 0
	if name == "player1":
		player_index = 1
	if name == "player2":
		player_index = 2
	if name == "player3":
		player_index = 3


func switch_modes(fight_time):
	if fight_time:
		fight_mode = true
	else:
		fight_mode = false
