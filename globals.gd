extends Node

@onready var anim_player = $AnimationPlayer

var fullscreen: bool = true

var intro_played: bool = false

var metalgear_unlocked: bool = false

var crushtris_played: bool = false
var tylermon_played: bool = false
var spotlight_played: bool = false
var metalgear_played: bool = false

var last_thumbnail_idx: int = 0

func _ready() -> void:
	ToggleFullscreen()

func _process(_delta: float) -> void:
	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_BACK):
		fullscreen = !fullscreen
		ToggleFullscreen()

func FadeIn(speed: float = 1.0) -> void:
	anim_player.play("fade_in", -1.0, speed)
	await anim_player.animation_finished
	
func FadeOut() -> void:
	anim_player.play("fade_out")
	await anim_player.animation_finished

func GoToMainMenu() -> void:
	get_tree().change_scene_to_file("res://menu/menu.tscn")

func ToggleFullscreen() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
