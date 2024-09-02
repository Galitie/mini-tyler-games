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

func _ready():
	$sprite.texture = sprite
	$area/shape.shape.radius = area_radius
	$name.text = item_name


func click(_arg, _pointer):
	if !exhausted and !window_open:
		window_open = true
		var popup_scene = preload("res://tyler98/popup.tscn")
		var instance = popup_scene.instantiate()
		add_child(instance)
		instance.global_position = Vector2(640, 360)
		
			
func hover():
	pass


func drag(_arg1):
	pass
