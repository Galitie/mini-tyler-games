class_name Piece
extends Node2D

@export var origin_point: Vector2 = Vector2.ZERO
@export var color_frame: int = 0

func _ready():
	for block in get_children():
		block.get_node("anchor/sprite").frame = color_frame

func check_contact(destination: Vector2) -> bool:
	for block in get_children():
		if block.test_move(block.global_transform, destination, null, 0.0):
			return true
	return false
	
func set_linear_velocity(linear_velocity: Vector2) -> void:
	for block in get_children():
		block.constant_linear_velocity = linear_velocity

func set_collision_layer(layer: int) -> void:
	for block in get_children():
		block.collision_layer = layer

func turn(angle: float) -> void:
	rotate(angle)
	for block in get_children():
		block.set_collision_mask(0b00000000_00000000_00000000_00000101)
	if check_contact(Vector2.ZERO):
		rotate(-angle)
		for block in get_children():
			block.set_collision_mask(0b00000000_00000000_00000000_00000001)
		return
	for block in get_children():
		var sprite_anchor = block.get_node("anchor")
		sprite_anchor.rotate(-angle)
		block.set_collision_mask(0b00000000_00000000_00000000_00000001)
