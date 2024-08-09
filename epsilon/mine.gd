extends Area2D

const DAMAGE: int = 3

func _ready():
	add_to_group("mines")
	
	await get_tree().create_timer(1.0).timeout
	
	body_entered.connect(_body_entered)
	area_entered.connect(_area_entered)
	$explosion.area_entered.connect(_area_entered_explosion)
	$sprite.animation_finished.connect(_animation_finished)
	$sfx.finished.connect(_sfx_finished)
	
func _body_entered(body: Node2D) -> void:
	if body.is_in_group("entities"):
		if body.is_in_group("snakes"):
			Input.start_joy_vibration(body.controller_port, 1.0, 1.0, 0.2)
			if body.state == Snake.SnakeState.BOX:
				return
		$sprite.visible = true
		$sprite.play("explode")
		set_deferred("monitoring", false)
		$explosion.set_deferred("monitoring", true)
		$sfx.play()
		
func _area_entered(area: Area2D) -> void:
	$anim_player.play("ping")

func _area_entered_explosion(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity.is_in_group("entities"):
		entity.hit(entity, DAMAGE)

func _animation_finished() -> void:
	$explosion.set_deferred("monitoring", false)
	$sprite.visible = false
	
func _sfx_finished() -> void:
	queue_free()
