extends Node2D
class_name Interactable

@export var item_name: String
@export var item_description: String
@export var sprite: Sprite2D

func _ready():
	pass


func _process(delta):
	var areas = $area.get_overlapping_areas()
	if areas.size():
		$sprite.material.set_shader_parameter("line_thickness", 1)
	else:
		$sprite.material.set_shader_parameter("line_thickness", 0)


