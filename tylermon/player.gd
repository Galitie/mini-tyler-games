class_name Player
extends Node
var mon : CharacterBody2D
var wins : int = 0
var losses : int = 0


func _ready():
	set_mon()


func update(delta):
	pass
	#if input.selected:
		#requested_state = state_u_picked


func set_mon():
	mon = get_child(0)
