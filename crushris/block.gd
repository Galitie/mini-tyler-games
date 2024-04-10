class_name Block
extends Node2D

func check_contact(destination: Vector2) -> bool:
	for block in get_children():
		if block.test_move(block.global_transform, destination):
			return true
	return false

func set_collision_layer(layer: int) -> void:
	for block in get_children():
		block.collision_layer = layer
