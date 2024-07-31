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
var bounced: bool = false

func _ready():
	add_to_group("projectiles")
	$explosion.area_entered.connect(_area_entered)
	$sprite.animation_finished.connect(_animation_finished)
	$sfx.finished.connect(_sfx_finished)

func _physics_process(delta: float) -> void:
	if !exploded:
		if life > LIFESPAN:
			exploded = true
			speed = 0
			set_deferred("monitoring", false)
			$explosion.set_deferred("monitoring", true)
			$sprite.play("explode")
			$sfx.play()
			$shadow.visible = false
		else:
			life += 1.0 * delta
			arc_progress += fall_speed * delta
			$sprite.offset.y = y_offset + sin(arc_progress) * throw_arc
			global_position += speed * direction * delta
			
			# BUG: Throwing a grenade at a door crashes it. Whoopeeeeeee!
			if !bounced && has_overlapping_bodies():
				var bodies = get_overlapping_bodies()
				var body = bodies[0]
				var tile_local = body.local_to_map(global_position)
				var tile_data = body.get_cell_tile_data(0, tile_local)
				var tile_normal = tile_data.get_constant_linear_velocity(0).normalized()
				direction = direction.bounce(tile_normal).normalized()
				bounced = true

func _area_entered(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity.is_in_group("entities"):
		entity.hit(emitter, DAMAGE)

func _animation_finished() -> void:
	$explosion.set_deferred("monitoring", false)
	$sprite.visible = false
	
func _sfx_finished() -> void:
	queue_free()
