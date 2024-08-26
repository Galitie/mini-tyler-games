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
func _process(delta):
	var areas = $pointer_area.get_overlapping_areas()
	var move_input: Vector2 = Controller.GetLeftStick(controller_port)
	global_position += move_input * SPEED * delta
	if Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A) && is_hovering:
		if areas.size():
			for area in areas:
				var root = area.owner
				if root is Interactable_Popup:
					root.hide()
				if root is Interactable:
					root.get_node("popup").visible = true
		sprite.play("interact")
		return


func _on_hover(area):
	sprite.play("hover")
	is_hovering = true


func _on_hover_exit(area):
	sprite.play("default")
	is_hovering = false
