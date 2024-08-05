extends Area2D

var speed: float = 100.0
var fall_speed: float = -3.6
var y_offset: float = -13
var throw_arc: float = 30
var arc_progress = 0

const LIFESPAN: float = 1.0
var life: float = 0.0

var direction: Vector2

const DAMAGE: int = 10

var emitter

var exploded: bool = false
var stopped: bool = false

func _ready():
	add_to_group("projectiles")
	body_entered.connect(_body_entered)
	$explosion.area_entered.connect(_area_entered)
	$sprite.animation_finished.connect(_animation_finished)
	$sfx.finished.connect(_sfx_finished)

func _physics_process(delta: float) -> void:
	if !exploded:
		if life > LIFESPAN:
			explode()
		else:
			life += 1.0 * delta
			arc_progress += fall_speed * delta
			$sprite.offset.y = y_offset + sin(arc_progress) * throw_arc
			if !stopped:
				global_position += speed * direction * delta
			
func _body_entered(body: Node2D) -> void:
	stopped = true
	
func explode() -> void:
	exploded = true
	speed = 0
	set_deferred("monitoring", false)
	$explosion.set_deferred("monitoring", true)
	$sprite.play("explode")
	$sfx.play()
	$shadow.visible = false

func _area_entered(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity.is_in_group("entities"):
		entity.hit(emitter, DAMAGE)

func _animation_finished() -> void:
	$explosion.set_deferred("monitoring", false)
	$sprite.visible = false
	
func _sfx_finished() -> void:
	queue_free()
