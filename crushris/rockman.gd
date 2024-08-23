extends CharacterBody2D

const SPEED: float = 250.0
const JUMP_VELOCITY: float = -450.0
const DASH_VELOCITY: float = 500.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var invincible: bool = true
@onready var kill_zone: Area2D = $kill_zone

@onready var sprite: AnimatedSprite2D = $sprite
@onready var outline: Sprite2D = $outline

@export var controller_port: int
@export var color: Color

var jumping: bool = false

signal player_killed

func _ready() -> void:
	add_to_group("players")
	$timer.start()
	sprite.modulate = color
	$bonk_zone.area_entered.connect(_bonk_area_entered)

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta
	else:
		if jumping:
			jumping = false
		if Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A):
			velocity.y = JUMP_VELOCITY
			jumping = true
	
	var direction: float = Controller.GetLeftStick(controller_port).x
	if direction:
		velocity.x = direction * SPEED
		
		if velocity.x > 0:
			sprite.flip_h = false
			outline.flip_h = false
		else:
			sprite.flip_h = true
			outline.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
	var squish_areas: Array = $kill_zone.get_overlapping_areas()
	var active_block = null
	for squish in squish_areas:
		if squish.get_parent() is Block:
			if squish.get_parent().get_parent().is_active || !squish.get_parent().grounded:
				active_block = squish
				break
	for squish in squish_areas:
		if active_block != null && squish != active_block:
			if !invincible:
				emit_signal("player_killed", self)
				queue_free()
				return
				
func _bonk_area_entered(area: Area2D) -> void:
	if jumping:
		var block_piece = area.get_parent().get_parent()
		if block_piece is Piece && !block_piece.is_active:
			var block = area.get_parent()
			block.hp -= 1
			block.get_node("break").frame += 1
			if block.hp <= 0:
				block.queue_free()

func _on_timer_timeout():
	invincible = false
