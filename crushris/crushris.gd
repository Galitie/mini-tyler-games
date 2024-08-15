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

var next_piece: Piece = null

const TILE_SIZE: int = 25
const MAX_COLUMNS: int = 10
const MAX_ROWS: int = 20

const PIECE_SPAWN_POINT: Vector2 = Vector2(615, 110)
const BOTTOM_LEFT_ROW_ORIGIN: Vector2 = Vector2(515, 585)

const PIECE_FALL_SPEED: float = 140
const PIECE_HORIZONTAL_SPEED: float = 200
var piece_destination: Vector2 = Vector2.ZERO

var active_piece: Piece = null

var snap_timer: float = 0
var snap_timer_length: float = 0.4

var block_killer_timer: float = 0
var block_killer_timer_length: float = 0.1

var move_timer: float = 0
var move_timer_length: float = 0.2

const WORLD_COLLISION_LAYER: int = 1

@onready var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

var death_row: Array = []
var fall_blocks: Array = []

var game_over: bool = false
var game_paused: bool = true
var players_killed: int = 0

@onready var camera: Camera2D = $camera
var zoom_weight: float = 5

func spawn_piece() -> void:
	var piece_instance = next_piece.duplicate()
	add_child(piece_instance)
	piece_instance.position = PIECE_SPAWN_POINT - piece_instance.origin_point
	active_piece = piece_instance
	piece_destination = active_piece.position
	
	next_piece = piece_scenes.pick_random().instantiate()
	if $piece_preview.get_child_count() > 0:
		$piece_preview.get_child(0).queue_free()
	$piece_preview.add_child(next_piece)

func _ready() -> void:
	for player in get_tree().get_nodes_in_group("players"):
		player.connect("player_killed", _on_player_killed)
	

func _physics_process(delta) -> void:
	if game_paused && Input.is_action_pressed("start"):
		start_game()
		
	if game_over:
		camera.zoom = camera.zoom.lerp(Vector2(2, 2), zoom_weight * delta)
	
	if death_row.size() != 0:
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
	
	if active_piece:
		active_piece.position.x = move_toward(active_piece.position.x, piece_destination.x, PIECE_HORIZONTAL_SPEED * delta)
		
		if !game_over and !game_paused:
			if Input.is_action_just_pressed("rotate_piece_left"):
				active_piece.turn(-PI / 2)
			if Input.is_action_just_pressed("rotate_piece_right"):
				active_piece.turn(PI / 2)
			
			if move_timer > 0:
				move_timer -= 1 * delta
			else:
				move_timer = 0
			if Input.is_action_pressed("move_piece_left") && move_timer == 0:
				if active_piece.global_position.x == piece_destination.x:
					if !active_piece.check_contact(Vector2(-TILE_SIZE, 0)):
						move_timer = move_timer_length
						piece_destination.x = active_piece.position.x - TILE_SIZE
			if Input.is_action_pressed("move_piece_right") && move_timer == 0:
				if active_piece.global_position.x == piece_destination.x:
					if !active_piece.check_contact(Vector2(TILE_SIZE, 0)):
						move_timer = move_timer_length
						piece_destination.x = active_piece.position.x + TILE_SIZE
		
		if !active_piece.check_contact(Vector2(0, PIECE_FALL_SPEED * delta)):
			active_piece.position.y += PIECE_FALL_SPEED * delta
			active_piece.set_linear_velocity(Vector2(0, PIECE_FALL_SPEED))
			snap_timer = 0
		else:
			active_piece.position.y = snap_piece_position(active_piece.position).y
			active_piece.set_linear_velocity(Vector2.ZERO)
			snap_timer += 1 * delta
				
		if snap_timer >= snap_timer_length:
			active_piece.position = snap_piece_position(active_piece.position)
			
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
				
				if !game_over and !game_paused:
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
			if results.size() != 0:
				detected_blocks.push_back(results[0].collider)
			
		row_data.push_back(detected_blocks)

	for i in range(0, row_data.size()):
		if row_data[i].size() == MAX_COLUMNS:
			for block in row_data[i]:
				death_row.push_back(block)
		else:
			for block in row_data[i]:
				fall_blocks.push_back(block)
	
	if death_row.size() != 0:
		block_killer_timer = block_killer_timer_length
	else:
		fall_blocks.clear()

func _on_player_killed() -> void:
	players_killed += 1
	if players_killed >= 3:
		game_over = true
		$blocks_win.visible = true

func start_game() -> void:
	game_paused = false
	next_piece = piece_scenes.pick_random().instantiate()
	spawn_piece()
