# LAYERS
# 1: SNAKE'S FEET
# 2: SNAKE'S BODY
# 3: WALLS
# 4: PROJECTILES
# 5: ENEMY FEET
# 6: ENEMY BODY
# 7: BOX
# 8: DEAD SNAKE
# 9: MINES
# 10: LOW OBJECT (METAL GEAR)
# 11: HIGH OBJECT (METAL GEAR)
# 12: RICHARD

extends Node2D

var paused: bool = false
var can_pause: bool = false
var in_call: bool = false

@onready var codec = $game/camera/ui/codec
@onready var ui_anim = $game/camera/ui/anim_player
@onready var ui_audio = $game/camera/ui/audio_player

var current_music = null
var current_music_path = ""
var encounter_theme = preload("res://epsilon/music/encounter.mp3")
var alert: bool = false

@onready var codec_ring = preload("res://epsilon/sound_effects/codec_ring.mp3")

var wait_to_continue: bool = false

var current_level: TileMap = null
var current_level_path: String = "res://epsilon/levels/level_0.tscn"
var current_level_bg_color = Color("102830")

var music_playback_pos: float = 0

func _ready():
	Controller.process_mode = Node.PROCESS_MODE_ALWAYS
	RenderingServer.set_default_clear_color(current_level_bg_color)
	
	var snakes = get_tree().get_nodes_in_group("snakes")
	for i in range(snakes.size()):
		snakes[i].badge = $game/camera/ui/camera_space.get_child(i)
		snakes[i].dead.connect(_on_snake_death)
		
	#await LoadLevel(current_level_path, "res://epsilon/music/duel.mp3", 0.0, current_level_bg_color)
	
	await get_tree().process_frame
	paused = true
	can_pause = false
	in_call = true
	await codec.play_file("res://epsilon/codec_calls/1.txt")
	await LoadLevel(current_level_path, "res://epsilon/music/intruder.mp3", 0.0, current_level_bg_color)
	paused = true
	can_pause = false
	in_call = false
	await get_tree().create_timer(3.0).timeout
	await _codec_triggered("res://epsilon/codec_calls/2.txt", "", current_level_bg_color)

func _physics_process(delta: float) -> void:
	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_BACK):
		for snake in get_tree().get_nodes_in_group("snakes"):
			if snake.controller_port != 0:
				snake.hit(self, 9999)
	
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
			await LoadLevel(current_level_path, current_music_path, 0.0, current_level_bg_color)

func _codec_triggered(call_path: String, music_path: String, bg_color: Color) -> void:
	can_pause = false
	in_call = true
	paused = true
	ui_anim.play("call")
	ui_audio.stream = codec_ring
	ui_audio.play()
	await ui_audio.finished
	ui_anim.play("fade_out")
	$music.volume_db = -20
	await ui_anim.animation_finished
	await codec.play_file(call_path)
	ui_anim.play("fade_in")
	$music.volume_db = -15
	await ui_anim.animation_finished
	paused = false
	in_call = false
	can_pause = true

func GameOver() -> void:
	can_pause = false
	await $game/camera/ui/game_over.GameOverDeath()
	paused = true
	ui_anim.play("fade_out", -1, 0.25)
	$game/camera/ui/codec/text_container/text.text = ""
	await $game/camera/ui/game_over.GameOver()
	wait_to_continue = true
	await ui_anim.animation_finished
	
func LoadLevel(level_path: String, music_path: String, music_playback_pos: float, color: Color) -> void:
	current_level_bg_color = color
	RenderingServer.set_default_clear_color(current_level_bg_color)
	
	if music_path != current_music_path:
		current_music_path = music_path
		music_playback_pos = 0
		current_music = load(current_music_path)
	$music.stream = current_music
	$music.play(music_playback_pos)
	
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
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.enemy_alerted.connect(_enemy_alerted)
		enemy.enemy_lost_alert.connect(_enemy_lost_alert)
	
	await get_tree().process_frame
	paused = true
	ui_anim.play("fade_in")
	await ui_anim.animation_finished
	paused = false
	can_pause = true
	
func _enemy_alerted() -> void:
	if !alert:
		for snake in get_tree().get_nodes_in_group("snakes"):
			snake.can_be_revived = false
		
		music_playback_pos = $music.get_playback_position()
		$music.stream = encounter_theme
		$music.play()
		alert = true
	
func _enemy_lost_alert() -> void:
	if alert:
		var no_enemies_alerted: bool = true
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.on_alert:
				no_enemies_alerted = false
				break
		if no_enemies_alerted:
			for snake in get_tree().get_nodes_in_group("snakes"):
				snake.can_be_revived = true
			alert = false
			$music.stream = current_music
			$music.play(music_playback_pos)

func _on_snake_death() -> void:
	var total_snake_deaths: int = 0
	for snake in get_tree().get_nodes_in_group("snakes"):
		if snake.state == Snake.SnakeState.DEAD:
			total_snake_deaths += 1
	if total_snake_deaths == get_tree().get_nodes_in_group("snakes").size() - 1:
		GameOver()
		$music.stop()
		alert = false

func _level_triggered(path: String, music_path: String, color: Color) -> void:
	can_pause = false
	paused = true
	ui_anim.play("fade_out")
	await ui_anim.animation_finished
	music_playback_pos = $music.get_playback_position()
	LoadLevel(path, music_path, music_playback_pos, color)

func End() -> void:
	ui_anim.play("fade_out")
	paused = true
	can_pause = false
	await ui_anim.animation_finished
	$music.stop()
	await codec.play_file("res://epsilon/codec_calls/6.txt")
	$music.volume_db = 0
	$music.stream = load("res://epsilon/music/snake_eater_easter_egg_ver.ogg")
	$music.play()
	# play ending video + song
	await $music.finished
	Globals.metalgear_played = true
	await Globals.FadeIn()
	Globals.GoToMainMenu()
