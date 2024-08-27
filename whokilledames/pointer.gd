extends Node2D
@export var controller_port: int = 0
@export var player_color: Color = Color("6868d8")
@onready var sprite: AnimatedSprite2D = $sprite
const SPEED: float = 400
var is_hovering: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.modulate = player_color
	$pointer_area.area_entered.connect(_on_hover)
	$pointer_area.area_exited.connect(_on_hover_exit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position.x = clamp(global_position.x, 0, 1240)
	global_position.y = clamp(global_position.y, 0, 680)
	var areas = $pointer_area.get_overlapping_areas()
	var move_input: Vector2 = Controller.GetLeftStick(controller_port)
	global_position += move_input * SPEED * delta
	
	#single press interactions
	if Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A) && is_hovering:
		if areas.size():
			for area in areas:
				var root = area.owner
				if root is Interactable_Popup:
					root.hide()
				if root is Interactable:
					if root.get_node("popup").visible == true:
						root.get_node("popup").visible = false
					if root.exhausted == true:
						root.get_node("popup").visible = false
					else:
						root.get_node("popup").visible = true
		sprite.play("interact")
		return
	
	#holding down interactions
	if Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_A) && is_hovering:
		if areas.size():
			for area in areas:
				var root = area.owner
				if root is RotateMiniGame:
					var vec = $sprite.global_position - root.get_node("sprite").global_position
					var angle = vec.angle()
					var rotate = root.get_node("sprite").global_rotation
					var angle_delta = PI * delta
					angle = lerp_angle(rotate, angle, 1.0)
					angle = clamp(angle, rotate - angle_delta, rotate + angle_delta)
					root.get_node("sprite").global_rotation = angle
		sprite.play("interact")
		return


func _on_hover(_area):
	sprite.play("hover")
	is_hovering = true


func _on_hover_exit(_area):
	sprite.play("default")
	is_hovering = false
