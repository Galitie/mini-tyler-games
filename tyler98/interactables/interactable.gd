extends Node2D
class_name Interactable

@export var item_name: String
@export var item_description: String
@export var sprite: Texture
@export var area_radius: int


@export var window_scene: PackedScene
@export var scene_var_str: String
@export var scene_var_int: int

var exhausted: bool = false


func _ready():
	$sprite.texture = sprite
	$area/shape.shape.radius = area_radius



func _process(_delta):
	var areas = $area.get_overlapping_areas()
	$sprite.material.set_shader_parameter("line_thickness", 0)
	if areas.size() and not exhausted:
		$sprite.material.set_shader_parameter("line_thickness", 2)
	if exhausted:
		$popup.visible = false
		$area/shape.disabled = true
		add_clue_inventory()
		queue_free()

func add_clue_inventory():
	var clue = TextureRect.new()
	clue.texture = sprite
	var inventory = get_parent().get_node("%clue_inventory").get_node("%clues")
	inventory.add_child(clue)
