extends Area2D

const DAMAGE: int = 3

func _ready():
	add_to_group("mines")
	body_entered.connect(_body_entered)
	$explosion.area_entered.connect(_area_entered_explosion)
	$sprite.animation_finished.connect(_animation_finished)
	
func _body_entered(body: Node2D) -> void:
	if body.is_in_group("entities"):
		$sprite.visible = true
		$sprite.play("explode")
		set_deferred("monitoring", false)
		$explosion.set_deferred("monitoring", true)

func _area_entered_explosion(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity.is_in_group("entities"):
		entity.hit(entity, DAMAGE)

func _animation_finished() -> void:
	queue_free()
