class_name Block
extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $anchor/sprite
@onready var shape: CollisionShape2D = $shape

var killed: bool = false
var grounded: bool = true

const FALL_SPEED: float = 3.0

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)

func fall(tile_size: int, grid_origin: Vector2) -> void:
	if !test_move(global_transform, Vector2(0, FALL_SPEED)):
		global_position.y += FALL_SPEED
		grounded = false
	else:
		global_position = grid_origin + Vector2(
			floor((global_position.x - grid_origin.x) / tile_size) * tile_size,
			-floor((grid_origin.y - global_position.y) / tile_size) * tile_size
		)
		grounded = true
		
func kill() -> void:
	shape.disabled = true
	sprite.play("disappear")
	killed = true
	
func _on_animation_finished() -> void:
	if killed:
		queue_free()
