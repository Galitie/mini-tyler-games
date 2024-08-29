# IDEA: Getting combos (like a 4 row clear) gives you meter
# You can expend meter to make your blocks fall faster, almost like a dash
extends Node2D

@onready var piece_scenes: Array = [
	load("res://crushris/o_piece.tscn"),
	load("res://crushris/I_piece.tscn"),
	load("res://crushris/s_piece.tscn"),
	load("res://crushris/z_piece.tscn"),
	load("res://crushris/L_piece.tscn"),
	load("res://crushris/j_piece.tscn"),
	load("res://crushris/t_piece.tscn")
]

@onready var music: Array = [
	["Diary of Jane", "Breaking Benjamin", load("res://crushris/The Diary Of Jane.ogg")],
	["The Rumbling", "SiM", load("res://crushris/rumbling.ogg")],
	["Crawling in My Crawl", "Linkin Crawl", load("res://crushris/crawl.ogg")],
	["Blow Me (Away)", "Halo 2 OST", load("res://crushris/blowme.ogg")],
	["Toxicity", "System of a Down", load("res://crushris/toxcicity.ogg")],
	["The Kill (Bury Me)", "30 Seconds To Mars", load("res://crushris/bury_me.ogg") ]
	]

var current_song

var next_piece: Piece = null

const TILE_SIZE: int = 25
const MAX_COLUMNS: int = 10
const MAX_ROWS: int = 20

const PIECE_SPAWN_POINT: Vector2 = Vector2(615, 110)
const BOTTOM_LEFT_ROW_ORIGIN: Vector2 = Vector2(515, 585)

var PIECE_FALL_SPEED: float = 100
const PIECE_HORIZONTAL_SPEED: float = 300
var piece_destination: Vector2 = Vector2.ZERO

var active_piece: Piece = null

var snap_timer: float = 0
var snap_timer_length: float = 0.4

var block_killer_timer: float = 0
var block_killer_timer_length: float = 0.1

var move_timer: float = 0
var move_timer_length: float = 0.15

const WORLD_COLLISION_LAYER: int = 1

@onready var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

var death_row: Array = []
var fall_blocks: Array = []

var game_over: bool = false
var game_paused: bool = true
var player_max_lives: int = 3
var player_current_lives: int = player_max_lives
var players_killed: int = 0

@onready var camera: Camera2D = $camera
var zoom_weight: float = 5

var player_scene = preload("res://crushris/rockman.tscn")

var game_speed: float = 1.0
const GAME_SPEED_INCREMENT = 0.05
const MAX_GAME_SPEED: float = 2.0

var current_ember_alpha: float = 0.13

func spawn_piece() -> void:
	var piece_instance = next_piece.duplicate()
	add_child(piece_instance)
	piece_instance.position = PIECE_SPAWN_POINT - piece_instance.origin_point
	active_piece = piece_instance
	active_piece.is_active = true
	piece_destination = active_piece.position
	next_piece = piece_scenes.pick_random().instantiate()
	if $piece_preview.get_child_count() > 0:
		$piece_preview.get_child(0).queue_free()
	$piece_preview.add_child(next_piece)

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	for player in get_tree().get_nodes_in_group("players"):
		player.connect("player_killed", _on_player_killed)
	$lives_text.text = "x " + str(player_max_lives)
	$current_song.text = ""
	next_piece = piece_scenes.pick_random().instantiate()
	spawn_piece()

func _physics_process(delta) -> void:
	$countdown.text = str(int($countdown_timer.time_left))
	
	if game_paused && Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_START):
		$start.visible = false
		start_game()
		
	if game_over:
		camera.zoom = camera.zoom.lerp(Vector2(2, 2), zoom_weight * delta)
	
	if death_row.size() != 0:
		$camera.apply_shake()
		block_killer_timer += 1 * delta
		if block_killer_timer >= block_killer_timer_length:
			var block: Block = death_row.pop_back()
			if block != null:
				block.kill()
			block_killer_timer = 0
	elif fall_blocks.size():
		var still_falling: bool = false
		for block in fall_blocks:
			block.fall(TILE_SIZE, BOTTOM_LEFT_ROW_ORIGIN, delta)
			if !block.grounded:
				still_falling = true
		if !still_falling:
			fall_blocks.clear()
			check_rows()
	elif !game_over && active_piece == null && !game_paused:
		spawn_piece()
	
	if active_piece && !game_paused:
		active_piece.position.x = move_toward(active_piece.position.x, piece_destination.x, PIECE_HORIZONTAL_SPEED * delta)
		
		if !game_over and !game_paused:
			if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_LEFT_SHOULDER):
				active_piece.turn(-PI / 2)
			if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_RIGHT_SHOULDER):
				active_piece.turn(PI / 2)
			
			var left_stick = Controller.GetLeftStick(0)
			if move_timer > 0:
				move_timer -= 1 * delta
			else:
				move_timer = 0
			if left_stick.x < 0 && move_timer == 0:
				if active_piece.global_position.x == piece_destination.x:
					if !active_piece.check_contact(Vector2(-TILE_SIZE, 0)):
						move_timer = move_timer_length
						piece_destination.x = active_piece.position.x - TILE_SIZE
			if left_stick.x > 0 && move_timer == 0:
				if active_piece.global_position.x == piece_destination.x:
					if !active_piece.check_contact(Vector2(TILE_SIZE, 0)):
						move_timer = move_timer_length
						piece_destination.x = active_piece.position.x + TILE_SIZE
			if left_stick.y > 0:
				PIECE_FALL_SPEED = 200
			else:
				PIECE_FALL_SPEED = 100
				
		if !active_piece.check_contact(Vector2(0, PIECE_FALL_SPEED * delta)):
			active_piece.position.y += PIECE_FALL_SPEED * game_speed * delta
			active_piece.set_linear_velocity(Vector2(0, PIECE_FALL_SPEED))
			snap_timer = 0
		else:
			active_piece.position.y = snap_piece_position(active_piece.position).y
			active_piece.set_linear_velocity(Vector2.ZERO)
			snap_timer += 1 * delta
				
		if snap_timer >= snap_timer_length:
			active_piece.position = snap_piece_position(active_piece.position)
			active_piece.is_active = false
			
			active_piece.set_collision_layer(WORLD_COLLISION_LAYER)
			check_rows()
			snap_timer = 0
			if death_row.size() == 0:
				for block in active_piece.get_children():
					var col_result: KinematicCollision2D = KinematicCollision2D.new()
					if block.test_move(block.global_transform, Vector2(0, -TILE_SIZE), col_result, 0.0):
						if col_result && col_result.get_collider().name == "arena_ceiling":
							game_over = true
							active_piece = null
							$players_win.visible = true
							await get_tree().create_timer(5.0).timeout
							Globals.crushtris_played = true
							await Globals.FadeIn()
							Globals.GoToMainMenu()
							return
				
				if !game_over and !game_paused:
					game_speed += GAME_SPEED_INCREMENT
					current_ember_alpha = remap(game_speed, 1, MAX_GAME_SPEED, 0.13, 1.0)
					$embers.modulate.a = current_ember_alpha
					$music.volume_db = remap(game_speed, 1, MAX_GAME_SPEED, -15, 0)
					if game_speed > MAX_GAME_SPEED:
						game_speed = MAX_GAME_SPEED
					
					spawn_piece()
			else:
				active_piece = null
				
func snap_piece_position(pos: Vector2) -> Vector2:
	var result: Vector2 = BOTTOM_LEFT_ROW_ORIGIN + Vector2(
			round((pos.x - BOTTOM_LEFT_ROW_ORIGIN.x) / TILE_SIZE) * TILE_SIZE,
			-round((BOTTOM_LEFT_ROW_ORIGIN.y - pos.y) / TILE_SIZE) * TILE_SIZE
	)
	return result
		
func check_rows() -> void:
	var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	params.collision_mask = 0b00000000_00000000_00000000_00000001
	
	var row_data: Array = []
	
	for y in range(MAX_ROWS):
		params.position = BOTTOM_LEFT_ROW_ORIGIN - Vector2(0, TILE_SIZE * y) + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
		var detected_blocks: Array = []

		for x in range(MAX_COLUMNS):
			var results: Array = space_state.intersect_point(params, 1)
			params.position += Vector2(TILE_SIZE, 0)
			if results.size():
				detected_blocks.push_back(results[0].collider)
			
		row_data.push_back(detected_blocks)

	var death_row_heights: Array = []
	for i in range(0, row_data.size()):
		if row_data[i].size() == MAX_COLUMNS:
			death_row_heights.push_back(i)
			for block in row_data[i]:
				block.assigned_to_die = true
				death_row.push_back(block)
	death_row_heights.sort()
				
	for i in range(0, row_data.size()):
		for block in row_data[i]:
			if death_row_heights.size():
				if i > death_row_heights.front() && !block.assigned_to_die:
					fall_blocks.push_back(block)
	
	if death_row.size():
		block_killer_timer = block_killer_timer_length
	else:
		fall_blocks.clear()

func _on_player_killed(rockman) -> void:
	$sfx.stream = load("res://crushris/yeow.ogg")
	$sfx.play()
	$camera.apply_shake()
	$embers.modulate.a += 0.50
	var ember_tween = get_tree().create_tween()
	ember_tween.tween_property($embers, "modulate", Color(1, 1, 1, current_ember_alpha), 1)
	players_killed += 1
	player_current_lives -= 1
	
	if player_current_lives >= 0:
		respawn_player(rockman.controller_port, rockman.color)
	$players.remove_child(rockman)
	
	if player_current_lives <= 0 && $players.get_children().size() == 0:
		game_over = true
		$blocks_win.visible = true
		await get_tree().create_timer(5.0).timeout
		Globals.crushtris_played = true
		await Globals.FadeIn()
		Globals.GoToMainMenu()

func start_game() -> void:
	$countdown_timer.start()
	await get_tree().physics_frame
	$countdown.visible = true
	play_song()

func _on_countdown_timer_timeout():
	$countdown.visible = false
	active_piece.set_linear_velocity(Vector2(0, PIECE_FALL_SPEED))
	game_paused = false

func play_song():
	current_song = music.pick_random()
	$music.stream = current_song[2]
	$current_song.text = '\"' + current_song[0] + '\"'+ "\n" + current_song[1]
	$music.play()

func _on_music_finished():
	play_song()

func respawn_player(port, color):
	$lives_text.text = "x " + str(player_current_lives)
	var player = player_scene.instantiate()
	var respawn_pos = 530
	if randf() < 0.5:
		respawn_pos = 750
	player.global_position = Vector2(respawn_pos, 122)
	player.controller_port = port
	player.color = color
	player.connect("player_killed", _on_player_killed)
	$players.add_child(player)
	if !$revive_sfx.playing:
		$revive_sfx.play()
