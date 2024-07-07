extends Area2D

const SPEED = 300.0

const LIFESPAN: float = 3.0
var life: float = 0.0

var direction: Vector2

const DAMAGE: int = 2

func _ready() -> void:
	area_entered.connect(_area_entered)
	body_entered.connect(_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * SPEED * delta
	
	life += delta * 1.0
	if life > LIFESPAN:
		queue_free()

func _area_entered(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity.is_in_group("entities"):
		entity.hit(DAMAGE)
		queue_free()

func _body_entered(body: Node2D) -> void:
	queue_free()
