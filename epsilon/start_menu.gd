extends Control

@onready var anim_player = $anim_player

var started: bool = false

func _ready():
	anim_player.play("pulse")
	
func _physics_process(delta):
	if !started && Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_START):
		started = true
		anim_player.play("fade_out", -1, 0.5)
		$sfx.play()
		await $sfx.finished
		await Globals.FadeIn(0.5)
		get_tree().change_scene_to_file("res://epsilon/main.tscn")
		Globals.get_node("fade").color = Color(1, 1, 1, 0)
