extends Interactable

@export var item_name: String
@export var item_description: String
@export var sprite: Texture
@export var content_image : Texture
@export var content_string: String = ""
@export var area_radius: int
@export var window_scene: PackedScene
@export var scene_var_str: String
@export var scene_var_int: int
@export var task_id: int
@export var string_list: Array[String]

var exhausted: bool = false
var window_open: bool = false
var drag_offset

func _ready():
	$sprite.texture = sprite
	$area/shape.shape.radius = area_radius
	$area/shape.disabled = true
	$name.text = item_name
	get_tree().get_root().get_node("main").enable_desktop_areas.connect(_enable_desktop_areas)
	get_tree().get_root().get_node("main").disable_desktop_areas.connect(_disable_desktop_areas)


func click(_arg, pointer):
	if !exhausted and !window_open and window_scene != null:
		window_open = true
		var popup_scene = preload("res://tyler98/popup.tscn")
		var instance = popup_scene.instantiate()
		add_child(instance)
		instance.global_position = Vector2(640, 360)
	
	if exhausted:
		drag_offset = global_position - pointer.global_position


func hover():
	pass


func drag(pointer):
	if exhausted:
		global_position = pointer.global_position + drag_offset


func _enable_desktop_areas():
	$area/shape.disabled = false


func _disable_desktop_areas():
	$area/shape.disabled = true


func release():
	var areas = $area.get_overlapping_areas()
	if name == "prawn":
		for area in areas:
			if area.owner.name == "recycle_bin":
				get_parent().get_parent().task_completed(task_id)
				queue_free()
