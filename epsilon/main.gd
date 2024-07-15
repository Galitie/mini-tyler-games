extends Node2D

var paused: bool = false
var can_pause: bool = false
var in_call: bool = false

@onready var codec = $game/camera/ui/codec
@onready var ui_anim = $game/camera/ui/anim_player
@onready var ui_audio = $game/camera/ui/audio_player

@onready var codec_ring = preload("res://epsilon/sound_effects/codec_ring.mp3")

var wait_to_continue: bool = false

func _ready():
	var snakes = get_tree().get_nodes_in_group("snakes")
	for i in range(4):
		snakes[i].badge = $game/camera/ui/camera_space.get_child(i)
	for snake in get_tree().get_nodes_in_group("snakes"):
		snake.dead.connect(_on_snake_death)
	
	await get_tree().process_frame
	paused = true
	#in_call = true
	#await codec.play_file("res://epsilon/codec_calls/1.txt")
	ui_anim.play("fade_in")
	await ui_anim.animation_finished
	#await get_tree().create_timer(3.0).timeout
	#await _trigger_codec_call("res://epsilon/codec_calls/2.txt")
	paused = false
	can_pause = true

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
				
	if wait_to_continue:
		if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_A):
			wait_to_continue = false
			await $game/camera/ui/game_over.Continue()
			ReloadLevel()
			ui_anim.play("fade_in")
			await ui_anim.animation_finished
			paused = false
			can_pause = true
		
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

func GameOver() -> void:
	can_pause = false
	ui_anim.play("fade_out", -1, 0.1)
	await $game/camera/ui/game_over.GameOver()
	wait_to_continue = true
	
func ReloadLevel() -> void:
	$game/level.free()
	var level_instance = load("res://epsilon/levels/level_0.tscn").instantiate()
	level_instance.name = "level"
	$game.add_child(level_instance)
	var snakes = get_tree().get_nodes_in_group("snakes")
	for i in range(4):
		snakes[i].badge = $game/camera/ui/camera_space.get_child(i)
		snakes[i].dead.connect(_on_snake_death)
	$game/camera.global_position = $game/camera.GetDestination()
	# NOTE: Have to call it twice to work, Spaghodot
	$game/camera.reset_smoothing()
	$game/camera.reset_smoothing()
	await get_tree().process_frame
	paused = true

func _on_snake_death() -> void:
	var total_snake_deaths: int = 0
	for snake in get_tree().get_nodes_in_group("snakes"):
		if snake.state == Snake.SnakeState.DEAD:
			total_snake_deaths += 1
	if total_snake_deaths == get_tree().get_nodes_in_group("snakes").size() - 1:
		GameOver()
