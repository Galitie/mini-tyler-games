extends Control

@onready var anim_player = $anim_player

func _ready():
	anim_player.play("pulse")
	
func _process(delta):
	if Input.is_action_pressed("start"):
		get_tree().change_scene_to_file("res://epsilon/main.tscn")
