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

var exhausted: bool = false


func _ready():
	$sprite.texture = sprite
	$area/shape.shape.radius = area_radius


func _process(_delta):
	$sprite.material.set_shader_parameter("line_thickness", 0)
	
	if exhausted && item_name == "Login":
		get_parent().queue_free()
	

func click(_arg):
	if !exhausted:
		var popup_scene = preload("res://tyler98/popup.tscn")
		var instance = popup_scene.instantiate()
		add_child(instance)

func hover():
	$sprite.material.set_shader_parameter("line_thickness", 2)


func drag(_arg1, _arg2):
	pass
