class_name Block
extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $anchor/sprite
@onready var shape: CollisionShape2D = $shape

const MAX_HP: int = 5
var hp: int = MAX_HP
var killed: bool = false
var grounded: bool = false

const FALL_SPEED: float = 140

var assigned_to_die: bool = false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)

func fall(tile_size: int, grid_origin: Vector2, delta: float) -> void:
	if !test_move(global_transform, Vector2(0, FALL_SPEED) * delta, null, 0.001):
		constant_linear_velocity = Vector2(0, FALL_SPEED)
		global_position.y += FALL_SPEED * delta
		grounded = false
	else:
		constant_linear_velocity = Vector2.ZERO
		global_position = grid_origin + Vector2(
			round((global_position.x - grid_origin.x) / tile_size) * tile_size,
			-round((grid_origin.y - global_position.y) / tile_size) * tile_size
		)
		grounded = true
		
func kill() -> void:
	shape.disabled = true
	sprite.play("disappear")
	$sfx.stream = load("res://crushris/explosion2.ogg")
	$sfx.play()
	killed = true
	
func _on_animation_finished() -> void:
	if killed:
		await get_tree().physics_frame
		queue_free()
