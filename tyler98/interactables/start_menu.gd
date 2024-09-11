extends Interactable

@export var window_scene: PackedScene

var window_open: bool = false


func _ready():
	get_tree().get_root().get_node("main").enable_desktop_areas.connect(_enable_desktop_areas)
	get_tree().get_root().get_node("main").disable_desktop_areas.connect(_disable_desktop_areas)
	$area/shape.disabled = true


func click(_arg, _pointer):
	if !window_open:
		window_open = true
		var start_menu = preload("res://tyler98/start_menu.tscn")
		var instance = start_menu.instantiate()
		add_child(instance)
		instance.global_position = Vector2(89, 579)
	else:
		window_open = false

func hover():
	pass


func drag(_arg1):
	pass


func _enable_desktop_areas():
	$area/shape.disabled = false


func _disable_desktop_areas():
	$area/shape.disabled = true
