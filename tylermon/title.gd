extends Control

@onready var anim_player = $anim_player
@onready var game_scene = "res://tylermon/tylermon.tscn"
@onready var tutorial = false

func _ready():
	anim_player.play("pulse")


func _physics_process(_delta):
	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_START) and !tutorial:
		%title_screen.visible = false
		tutorial = true
	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_A) and tutorial:
		get_tree().change_scene_to_file(game_scene)
