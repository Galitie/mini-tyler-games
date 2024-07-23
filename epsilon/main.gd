extends Node2D

var paused: bool = false
var can_pause: bool = false
var in_call: bool = false

@onready var codec = $game/camera/ui/codec
@onready var ui_anim = $game/camera/ui/anim_player
@onready var ui_audio = $game/camera/ui/audio_player

@onready var codec_ring = preload("res://epsilon/sound_effects/codec_ring.mp3")

var wait_to_continue: bool = false

var current_level: TileMap = null
var current_level_path: String = "res://epsilon/levels/level_0.tscn"

func _ready():
	Controller.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var snakes = get_tree().get_nodes_in_group("snakes")
	for i in range(snakes.size()):
		snakes[i].badge = $game/camera/ui/camera_space.get_child(i)
		snakes[i].dead.connect(_on_snake_death)
		
	#await LoadLevel(current_level_path)
	
	await get_tree().process_frame
	paused = true
	can_pause = false
	in_call = true
	await codec.play_file("res://epsilon/codec_calls/1.txt")
	await LoadLevel(current_level_path)
	paused = true
	can_pause = false
	in_call = false
	await get_tree().create_timer(3.0).timeout
	await _codec_triggered("res://epsilon/codec_calls/2.txt")

func _physics_process(delta: float) -> void:
	get_tree().paused = paused
	
	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_START):
		if in_call:
			codec.interrupted = true
		elif can_pause:
			paused = !paused
			if paused:
				$game/camera/ui/camera_space/paused.visible = true
				$game/camera/ui/camera_space/fade.color.a = 0.5
			else:
				$game/camera/ui/camera_space/paused.visible = false
				$game/camera/ui/camera_space/fade.color.a = 0.0
				
	if wait_to_continue:
		if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_A):
			wait_to_continue = false
			await $game/camera/ui/game_over.Continue()
			await LoadLevel(current_level_path)

func _codec_triggered(call_path: String) -> void:
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
	await $game/camera/ui/game_over.GameOverDeath()
	ui_anim.play("fade_out", -1, 0.25)
	await $game/camera/ui/game_over.GameOver()
	wait_to_continue = true
	
func LoadLevel(level_path: String) -> void:
	var snakes = get_tree().get_nodes_in_group("snakes")
	for snake in snakes:
		snake.get_parent().remove_child(snake)
		if snake.state == Snake.SnakeState.DEAD:
			snake.Reset(true)
		else:
			snake.Reset(false)
	if has_node("game/level"):
		# NOTE: Might have to disconnect trigger signals here
		$game/level.queue_free()
		await get_tree().process_frame
	current_level_path = level_path
	current_level = load(level_path).instantiate()
	current_level.name = "level"
	$game.add_child(current_level)
	for trigger in get_tree().get_nodes_in_group("triggers"):
		if trigger.type == Trigger.TriggerType.LEVEL:
			trigger.triggered.connect(_level_triggered)
		elif trigger.type == Trigger.TriggerType.CODEC:
			trigger.triggered.connect(_codec_triggered)
	for i in range(snakes.size()):
		snakes[i].global_position = current_level.get_node("spawns").get_child(i).global_position
		current_level.get_node("entities").add_child(snakes[i])
		snakes[i].map = current_level
	$game/camera.global_position = $game/camera.GetDestination()
	# NOTE: Have to call it twice to work, Spaghodot
	$game/camera.reset_smoothing()
	$game/camera.reset_smoothing()
	await get_tree().process_frame
	paused = true
	ui_anim.play("fade_in")
	await ui_anim.animation_finished
	paused = false
	can_pause = true

func _on_snake_death() -> void:
	var total_snake_deaths: int = 0
	for snake in get_tree().get_nodes_in_group("snakes"):
		if snake.state == Snake.SnakeState.DEAD:
			total_snake_deaths += 1
	if total_snake_deaths == get_tree().get_nodes_in_group("snakes").size() - 1:
		GameOver()

func _level_triggered(path: String) -> void:
	can_pause = false
	paused = true
	ui_anim.play("fade_out")
	await ui_anim.animation_finished
	LoadLevel(path)
