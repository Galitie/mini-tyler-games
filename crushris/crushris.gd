extends Node2D

@onready var block_scenes: Array = [
	load("res://crushris/o_block.tscn"),
	load("res://crushris/l_block.tscn")
]

const TILE_SIZE: int = 25
const MAX_COLUMNS: int = 10
const MAX_ROWS: int = 20

const BLOCK_SPAWN_POINT: Vector2 = Vector2(615, 110)
const BOTTOM_LEFT_ROW_ORIGIN: Vector2 = Vector2(515, 585)

const BLOCK_FALL_SPEED: float = 3.0

var active_block: Block = null

var snap_timer: int = 0
var snap_timer_length: int = 18

const WORLD_COLLISION_LAYER: int = 1

@onready var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

func spawn_block() -> void:
	var block_instance = block_scenes.pick_random().instantiate()
	add_child(block_instance)
	block_instance.position = BLOCK_SPAWN_POINT
	active_block = block_instance

func _ready() -> void:
	spawn_block()

func _physics_process(delta: float) -> void:
	if active_block:
		# TODO: Lerping horizontal movement and rotation
		if Input.is_action_just_pressed("move_block_left"):
			if !active_block.check_contact(Vector2(-TILE_SIZE, 0)):
				active_block.position.x -= TILE_SIZE
				
		if Input.is_action_just_pressed("move_block_right"):
			if !active_block.check_contact(Vector2(TILE_SIZE, 0)):
				active_block.position.x += TILE_SIZE
		
		if !active_block.check_contact(Vector2(0, BLOCK_FALL_SPEED)):
			active_block.position.y += BLOCK_FALL_SPEED
			snap_timer = 0
		else:
			active_block.position.y = snap_block_position(active_block.position).y
			snap_timer += 1
				
		if snap_timer >= snap_timer_length:
			active_block.position = snap_block_position(active_block.position)
			# TODO: This is bugged. Needs to actually determine the arena ceiling
			if active_block.check_contact(Vector2(0, -TILE_SIZE)):
				print("GAME OVER")
				active_block = null
			else:
				active_block.set_collision_layer(WORLD_COLLISION_LAYER)
				check_rows()
				spawn_block()
			snap_timer = 0
				
func snap_block_position(pos: Vector2) -> Vector2:
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

	# TODO: Block disappearing animation and real-time falling velocity
	for i in range(0, row_data.size()):
		if row_data[i].size() == MAX_COLUMNS:
			for block in row_data[i]:
				block.queue_free()
				block.get_node("shape").disabled = true
				
			for n in range(i + 1, row_data.size()):
				for block in row_data[n]:
					block.position.y += TILE_SIZE
