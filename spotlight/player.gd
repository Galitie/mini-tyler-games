extends CharacterBody2D

signal got_key
signal escaped

@export var controller_port: int = 0

var move_speed: float = 200
var jump_impulse: float = -400
var fall_speed: float = 1200
const MAX_FALL_SPEED: float = 1000

var in_blue: bool = false
var in_green: bool = false
var in_red: bool = false

var prev_color: Color = Color.WHITE
var next_color: Color = Color.WHITE
const COLOR_CHANGE_SPEED: float = 12.0

var has_key: bool = false
var has_escaped: bool = false

func _ready() -> void:
	add_to_group("players")
	$body.area_entered.connect(_body_entered)
	
	match controller_port:
		0:
			$sprite.modulate = Color.WHITE
		1:
			$sprite.modulate = Color.BLUE
		2:
			$sprite.modulate = Color.GREEN
		3:
			$sprite.modulate = Color.RED
			
	if controller_port != 0:
		$sonar.color = $sprite.modulate
		$sonar_area.collision_layer = controller_port + 1
	else:
		$body.collision_layer = 1
		$sonar.visible = false

func _physics_process(delta: float) -> void:
	if !has_escaped:
		if not is_on_floor():
			velocity.y += fall_speed * delta
			if velocity.y > MAX_FALL_SPEED:
				velocity.y = MAX_FALL_SPEED

		if Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A) and is_on_floor():
			velocity.y = jump_impulse
		
		if controller_port == 0:
			var spotlights = $body.get_overlapping_areas()
			if spotlights.size() > 1:
				in_blue = false
				in_green = false
				in_red = false
				# Layers 2, 3, 4 (spotlights)
				$body.collision_mask = 0b00000000_00000000_00000000_10001110
				for spotlight in spotlights:
					match spotlight.collision_layer:
						2:
							in_blue = true
						3:
							in_green = true
						4:
							in_red = true
		
				prev_color = $sprite.modulate
				if in_red && in_green && in_blue:
					next_color = Color.WHITE
					$body.collision_mask |= 0b00000000_00000000_00000001_00000000
				elif in_blue && in_green:
					next_color = Color.CYAN
					$body.collision_mask |= 0b00000000_00000000_00000000_00010000
				elif in_red && in_green:
					next_color = Color.YELLOW
					$body.collision_mask |= 0b00000000_00000000_00000000_00100000
				elif in_red && in_blue:
					next_color = Color.MAGENTA
					$body.collision_mask |= 0b00000000_00000000_00000000_01000000
				
				
			$sprite.modulate = lerp(prev_color, next_color, COLOR_CHANGE_SPEED * delta)
			
		var direction: Vector2 = Controller.GetLeftStick(controller_port)
		if direction:
			velocity.x = direction.x * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)

		move_and_slide()

func _body_entered(area: Area2D) -> void:
	if area.owner is Key:
		has_key = true
		emit_signal("got_key")
		area.owner.queue_free()
	elif area.owner is Door:
		emit_signal("escaped")
		has_escaped = true
		$shape.set_deferred("disabled", true)
		$sonar_area/shape.set_deferred("disabled", true)
		$body/shape.set_deferred("disabled", true)
		$sprite.play("escape")
		var light_tween = get_tree().create_tween()
		light_tween.tween_property($sonar, "texture_scale", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC)
