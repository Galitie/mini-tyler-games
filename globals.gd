extends Node

@onready var anim_player = $AnimationPlayer

var intro_played: bool = false

var metalgear_unlocked: bool = false

var crushtris_played: bool = false
var tylermon_played: bool = false
var metalgear_played: bool = false

var last_thumbnail_idx: int = 0

func FadeIn(speed: float = 1.0) -> void:
	anim_player.play("fade_in", -1.0, speed)
	await anim_player.animation_finished
	
func FadeOut() -> void:
	anim_player.play("fade_out")
	await anim_player.animation_finished

func GoToMainMenu() -> void:
	get_tree().change_scene_to_file("res://menu/menu.tscn")
