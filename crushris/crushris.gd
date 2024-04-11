# IDEA: Getting combos (like a 4 row clear) gives you meter
# You can expend meter to make your blocks fall faster, almost like a dash
extends Node2D

@onready var piece_scenes: Array = [
	load("res://crushris/o_piece.tscn"),
	load("res://crushris/l_piece.tscn")
]

const TILE_SIZE: int = 25
const MAX_COLUMNS: int = 10
const MAX_ROWS: int = 20

const PIECE_SPAWN_POINT: Vector2 = Vector2(615, 110)
const BOTTOM_LEFT_ROW_ORIGIN: Vector2 = Vector2(515, 585)

const PIECE_FALL_SPEED: float = 3.0

var active_piece: Piece = null

var snap_timer: int = 0
var snap_timer_length: int = 18

var block_killer_timer: int = 0
var block_killer_timer_length: int = 5

const WORLD_COLLISION_LAYER: int = 1

const PIECE_HORIZONTAL_SPEED: float = 10
var piece_destination: Vector2 = Vector2.ZERO

@onready var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

var death_row: Array = []
var fall_blocks: Array = []

func spawn_piece() -> void:
	var piece_instance = piece_scenes.pick_random().instantiate()
	add_child(piece_instance)
	piece_instance.position = PIECE_SPAWN_POINT - piece_instance.origin_point
	active_piece = piece_instance
	piece_destination = active_piece.position

func _ready() -> void:
	spawn_piece()

func _physics_process(delta: float) -> void:
	# TODO: There's an occasional bug that spares some blocks from death,
	# leaving them floating in mid-air. I'm not sure what causes it yet.
	if death_row.size() != 0:
		block_killer_timer += 1
		if block_killer_timer >= block_killer_timer_length:
			var block: Block = death_row.pop_back()
			if block != null:
				block.kill()
			block_killer_timer = 0
	elif fall_blocks.size():
		var still_falling: bool = false
		for block in fall_blocks:
			block.fall(TILE_SIZE, BOTTOM_LEFT_ROW_ORIGIN)
			if !block.grounded:
				still_falling = true
		if !still_falling:
			fall_blocks.clear()
			check_rows()
	elif active_piece == null:
		spawn_piece()
	
	if active_piece:
		active_piece.position.x = move_toward(active_piece.position.x, piece_destination.x, PIECE_HORIZONTAL_SPEED)
		
		if Input.is_action_just_pressed("rotate_piece_left"):
			active_piece.turn(-PI / 2)
		if Input.is_action_just_pressed("rotate_piece_right"):
			active_piece.turn(PI / 2)
		
		if Input.is_action_just_pressed("move_piece_left"):
			if !active_piece.check_contact(Vector2(-TILE_SIZE, 0)):
				piece_destination.x = active_piece.position.x - TILE_SIZE
		if Input.is_action_just_pressed("move_piece_right"):
			if !active_piece.check_contact(Vector2(TILE_SIZE, 0)):
				piece_destination.x = active_piece.position.x + TILE_SIZE
		
		if !active_piece.check_contact(Vector2(0, PIECE_FALL_SPEED)):
			active_piece.position.y += PIECE_FALL_SPEED
			snap_timer = 0
		else:
			active_piece.position.y = snap_piece_position(active_piece.position).y
			snap_timer += 1
				
		if snap_timer >= snap_timer_length:
			active_piece.position = snap_piece_position(active_piece.position)
			# TODO: This is bugged. Needs to actually determine the arena ceiling
			if active_piece.check_contact(Vector2(0, -TILE_SIZE)):
				print("GAME OVER")
				active_piece = null
			else:
				active_piece.set_collision_layer(WORLD_COLLISION_LAYER)
				active_piece = null
				check_rows()
				if death_row.size() == 0:
					spawn_piece()
			snap_timer = 0
				
func snap_piece_position(pos: Vector2) -> Vector2:
	var result: Vector2 = BOTTOM_LEFT_ROW_ORIGIN + Vector2(
			floor((pos.x - BOTTOM_LEFT_ROW_ORIGIN.x) / TILE_SIZE) * TILE_SIZE,
			-floor((BOTTOM_LEFT_ROW_ORIGIN.y - pos.y) / TILE_SIZE) * TILE_SIZE
	)
	return result
		
func check_rows() -> void:
	var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	# TODO: Will need to be tweaked in the future to avoid players
	params.collision_mask = 4294967295
	
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
