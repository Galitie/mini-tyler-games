extends Area2D

const DAMAGE: int = 3

var speed = 100
var steer_force = 30.0

var exploded: bool = false
var seeking: bool = false
var start_left: bool = false
var velocity: Vector2 = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

func _ready() -> void:
	area_entered.connect(_area_entered)
	body_entered.connect(_wall_hit)
	$explosion.area_entered.connect(_entered_explosion)
	$sprite.animation_finished.connect(_animation_finished)

func start(_position, _target):
	global_position = _position
	velocity = Vector2(10, 0)
	if start_left:
		rotate(PI)
		velocity = -velocity
	target = _target

func seek():
	var steer: Vector2 = Vector2.ZERO
	if target:
		var desired: Vector2 = (target.global_position - global_position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _physics_process(delta):
	if !exploded:
		if seeking:
			acceleration += seek()
		else:
			acceleration += velocity * 100 * delta
			if velocity.length() >= speed:
				seeking = true
		velocity += acceleration * delta
		velocity = velocity.limit_length(speed)
		rotation = velocity.angle()
		global_position += velocity * delta
		
func explode() -> void:
	rotation = 0
	set_deferred("monitoring", false)
	$explosion.set_deferred("monitoring", true)
	$sprite.play("explode")
	exploded = true
	$particles.emitting = false
	$sfx.play()
		
func _wall_hit(body: Node2D) -> void:
	explode()

func _area_entered(area: Area2D) -> void:
	explode()
		
func _entered_explosion(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity.is_in_group("entities"):
		entity.hit(self, DAMAGE)

func _animation_finished() -> void:
	$explosion.set_deferred("monitoring", false)
	$sprite.visible = false
	
func _sfx_finished() -> void:
	queue_free()

#func explode() -> void:
	#$Particles2D.emitting = false
	#set_physics_process(false)
	#$AnimationPlayer.play("explode")
	#yield($AnimationPlayer, "animation_finished")
	#queue_free()
