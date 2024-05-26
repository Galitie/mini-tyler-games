class_name Player
extends Node
var mon : CharacterBody2D
var wins : int = 0
var fight_mode : bool
var current_place : int
@export var controller_port: int

const STATE = preload("res://tylermon/mon.gd")


func _ready():
	set_mon()


func _process(_delta):
	pass
	#if !fight_mode:
		#if Input.is_joy_button_pressed(controller_port,JOY_BUTTON_A):
			#if Input.is_action_just_pressed("tylermon_accept"):
				#print("player ", controller_port, " pressed X")
		#if Input.is_joy_button_pressed(controller_port,JOY_BUTTON_DPAD_UP):
			#print("player ", controller_port, " pressed Dpad up")
		#if Input.is_joy_button_pressed(controller_port,JOY_BUTTON_DPAD_RIGHT):
			#print("player ", controller_port, " pressed Dpad right")
		#if Input.is_joy_button_pressed(controller_port,JOY_BUTTON_DPAD_DOWN):
			#print("player ", controller_port, " pressed Dpad down")
		#if Input.is_joy_button_pressed(controller_port,JOY_BUTTON_DPAD_LEFT):
			#print("player ", controller_port, " pressed Dpad left")

   
func set_mon():
	mon = get_child(0)



