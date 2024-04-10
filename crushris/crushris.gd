extends Node2D

# TODO: Change block prefab into mutiple instances of 1 block with respective shapes
@onready var o_block: PackedScene = load("res://crushris/o_block.tscn")

const TILE_SIZE: int = 50

const BLOCK_SPAWN_POINT: Vector2 = Vector2(615, 110)

var active_block = null

var fall_timer: int = 0
var fall_timer_limit: int = 30

func spawn_block() -> void:
	var block_instance = o_block.instantiate()
	add_child(block_instance)
	block_instance.position = BLOCK_SPAWN_POINT
	active_block = block_instance

func _ready() -> void:
	spawn_block()

func _physics_process(delta: float) -> void:
	if active_block:
		if Input.is_action_just_pressed("move_block_left"):
			if !active_block.test_move(active_block.transform, Vector2(-TILE_SIZE, 0)):
				active_block.position.x -= TILE_SIZE
		if Input.is_action_just_pressed("move_block_right"):
			if !active_block.test_move(active_block.transform, Vector2(TILE_SIZE, 0)):
				active_block.position.x += TILE_SIZE
		
		fall_timer += 1
		
		if fall_timer >= fall_timer_limit:
			if !active_block.test_move(active_block.transform, Vector2(0, TILE_SIZE)):
				active_block.position.y += TILE_SIZE
			else:
				if active_block.test_move(active_block.transform, Vector2(0, -TILE_SIZE)):
					print("GAME OVER")
					active_block = null
				else:
					spawn_block()
			fall_timer = 0
