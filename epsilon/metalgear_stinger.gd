extends Area2D

const DAMAGE: int = 3

var pickup_scene = preload("res://epsilon/pickup.tscn")
var drop_sfx = preload("res://epsilon/sound_effects/item_drop.wav")

var speed = 100
var steer_force = 30.0

var exploded: bool = false
var seeking: bool = false
var start_left: bool = false
var velocity: Vector2 = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

@onready var map = get_parent()

func _ready() -> void:
	area_entered.connect(_area_entered)
	body_entered.connect(_wall_hit)
	$explosion.area_entered.connect(_entered_explosion)
	$sprite.animation_finished.connect(_animation_finished)
	$particles.emitting = false

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
			if target.hp > 0:
				acceleration += seek()
		else:
			acceleration += velocity * 100 * delta
			if velocity.length() >= speed:
				seeking = true
				$particles.emitting = true
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
	$explosion_sfx.play()
		
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
	
	var pickup = pickup_scene.instantiate()
	pickup.global_position = global_position
	var rng = RandomNumberGenerator.new()
	var rng_result = rng.randi_range(1, 50)
	if rng_result >= 35 && rng_result < 40:
		pickup.pickup_type = Pickup.PickupType.PISTOL
	elif rng_result >= 40 && rng_result < 45:
		pickup.pickup_type = Pickup.PickupType.GRENADE
	elif rng_result >= 45 && rng_result <= 50:
		pickup.pickup_type = Pickup.PickupType.STINGER
	if pickup.pickup_type != Pickup.PickupType.NONE:
		$drop_sfx.play()
		map.add_child(pickup)
		await $explosion_sfx.finished
		queue_free()
	else:
		pickup.queue_free()
		await $explosion_sfx.finished
		queue_free()

#func explode() -> void:
	#$Particles2D.emitting = false
	#set_physics_process(false)
	#$AnimationPlayer.play("explode")
	#yield($AnimationPlayer, "animation_finished")
	#queue_free()
