extends Control

@onready var anim_player = $anim_player
@onready var game_scene = "res://tylermon/tylermon.tscn"

func _ready():
	anim_player.play("pulse")


func _process(delta):
	if Input.is_action_pressed("start"):
		get_tree().change_scene_to_file(game_scene)
