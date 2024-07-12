extends Area2D

var speed: float = 0.0
var accel: float = 100.0
var max_speed: float = 400.0

var direction_str: String
var direction: Vector2

const DAMAGE: int = 5

var emitter

var exploding: bool = false
var can_hurt_emitter: bool = false

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(_screen_exited)
	body_entered.connect(_wall_hit)
	$explosion.area_entered.connect(_area_entered)
	$body.area_entered.connect(_body_area_entered)
	$sprite.animation_finished.connect(_animation_finished)

func _process(delta: float) -> void:
	if !exploding:
		if emitter.hp <= 0:
			explode()
			return
		$sprite.play(direction_str)
		var move_input: Vector2 = Controller.GetLeftStick(emitter.controller_port)
		direction_str = GetDirection(move_input)
		if direction_str.ends_with("l"):
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
		direction = GetVectorFromDirection(direction_str)
		speed += accel * delta
		if speed > max_speed:
			can_hurt_emitter = true
			speed = max_speed
		global_position += speed * direction * delta
		
func GetVectorFromDirection(_direction: String) -> Vector2:
	match _direction:
		"u":
			return Vector2.UP
		"d":
			return Vector2.DOWN
		"l":
			return Vector2.LEFT
		"r":
			return Vector2.RIGHT
		"ur":
			return Vector2(1, -1).normalized()
		"dr":
			return Vector2(1, 1).normalized()
		"dl":
			return Vector2(-1, 1).normalized()
		"ul":
			return Vector2(-1, -1).normalized()
		_:
			return Vector2.ZERO
		
func GetDirection(move_input: Vector2) -> String:
	if move_input.length() == 0:
		return direction_str
	
	var angle: float = atan2(move_input.y, move_input.x)
	var octant: int = int(round(8 * angle / (2*PI) + 8)) % 8
	match octant:
		0:
			return "r"
		1:
			return "dr"
		2:
			return "d"
		3:
			return "dl"
		4:
			return "l"
		5:
			return "ul"
		6:
			return "u"
		7:
			return "ur"
			
	return "N/A"
			
func _body_area_entered(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity.is_in_group("entities"):
		if entity == emitter && !can_hurt_emitter:
			return
		if emitter.hp > 0:
			emitter.state = Snake.SnakeState.IDLE
		explode()
		
func explode() -> void:
	set_deferred("monitoring", false)
	$explosion.set_deferred("monitoring", true)
	$sprite.play("explode")
	$shadow.visible = false
	exploding = true
		
func _wall_hit(body: Node2D) -> void:
	emitter.state = Snake.SnakeState.IDLE
	explode()

func _area_entered(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity.is_in_group("entities"):
		entity.hit(emitter, DAMAGE)

func _animation_finished() -> void:
	queue_free()

func _screen_exited() -> void:
	queue_free()
	if emitter.hp > 0:
		emitter.state = Snake.SnakeState.IDLE
