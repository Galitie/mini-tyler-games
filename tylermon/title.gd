extends Control

@onready var anim_player = $anim_player
@onready var game_scene = "res://tylermon/tylermon.tscn"

func _ready():
	anim_player.play("pulse")


func _physics_process(delta):
	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_START):
		get_tree().change_scene_to_file(game_scene)
