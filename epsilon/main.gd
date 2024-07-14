extends Node2D

var paused: bool = false
var can_pause: bool = false
var in_call: bool = false

@onready var codec = $game/camera/ui/codec
@onready var ui_anim = $game/camera/ui/anim_player
@onready var ui_audio = $game/camera/ui/audio_player

@onready var codec_ring = load("res://epsilon/sound_effects/codec_ring.mp3")

func _ready():
	await get_tree().process_frame
	paused = true
	in_call = true
	await codec.play_file("res://epsilon/codec_calls/1.txt")
	ui_anim.play("fade_in")
	await ui_anim.animation_finished
	await get_tree().create_timer(3.0).timeout
	await _trigger_codec_call("res://epsilon/codec_calls/2.txt")

func _physics_process(delta: float) -> void:
	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_START):
		if in_call:
			codec.interrupted = true
		elif can_pause:
			paused = !paused
			if paused:
				$game/camera/ui/camera_space/fade.color.a = 0.5
			else:
				$game/camera/ui/camera_space/fade.color.a = 0.0
		
	if paused:
		$game.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		$game.process_mode = Node.PROCESS_MODE_INHERIT

func _trigger_codec_call(call_path: String) -> void:
	can_pause = false
	in_call = true
	paused = true
	ui_anim.play("call")
	ui_audio.stream = codec_ring
	ui_audio.play()
	await ui_audio.finished
	ui_anim.play("fade_out")
	await ui_anim.animation_finished
	await codec.play_file(call_path)
	ui_anim.play("fade_in")
	await ui_anim.animation_finished
	paused = false
	in_call = false
	can_pause = true
