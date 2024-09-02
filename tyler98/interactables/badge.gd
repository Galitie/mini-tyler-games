extends Interactable

@export var item_name: String
@export var item_description: String
@export var sprite: Texture
@export var content_image : Texture
@export var content_string: String = ""
@export var window_scene: PackedScene
@export var scene_var_str: String
@export var scene_var_int: int
@export var task_id: int

var exhausted: bool = false
var window_open: bool = false
var size_set: bool = false

func _ready():
	$sprite.texture = sprite
	set_area_size()


func _process(delta):
	if !size_set:
		set_area_size()


func set_area_size():
	$area/shape.shape.size = Vector2($sprite.texture.get_width()/2, $sprite.texture.get_height()/2 )
	size_set = true

func click(_arg, pointer):
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