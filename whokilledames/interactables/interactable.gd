extends Node2D
class_name Interactable

@export var item_name: String
@export var item_description: String
@export var sprite: Texture
@export var area_radius: int
@export_enum("top", "right", "left", "bottom") var popup_position: String


var exhausted: bool = false

func _ready():
	$sprite.texture = sprite
	$area/shape.shape.radius = area_radius
	match popup_position:
		"top":
			$popup.position = Vector2(-80, -320)
		"right":
			$popup.position = Vector2(60, -110)
		"left":
			$popup.position = Vector2(-230, -110)
		"bottom":
			$popup.position = Vector2(-80, 60)


func _process(_delta):
	var areas = $area.get_overlapping_areas()
	$sprite.material.set_shader_parameter("line_thickness", 0)
	if areas.size() and not exhausted:
		$sprite.material.set_shader_parameter("line_thickness", 2)
	if exhausted:
		$popup.visible = false
		$area/shape.disabled = true
		queue_free()