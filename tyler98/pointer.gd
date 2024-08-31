extends Node2D
@export var controller_port: int = 0
@export var player_color: Color = Color("6868d8")
@onready var sprite: AnimatedSprite2D = $sprite
const SPEED: float = 400
var is_hovering: bool = false


func _ready():
	sprite.modulate = player_color
	$pointer_area.area_entered.connect(_on_hover)
	$pointer_area.area_exited.connect(_on_hover_exit)

func _physics_process(delta):
	global_position.x = clamp(global_position.x, 95, 1150)
	global_position.y = clamp(global_position.y, 5, 690)
	var areas = $pointer_area.get_overlapping_areas()
	var move_input: Vector2 = Controller.GetLeftStick(controller_port)
	global_position += move_input * SPEED * delta
	
	#on hover
	if areas.size() && is_hovering:
		for area in areas:
			var root = area.owner
			if root is Interactable:
				root.hover()
	
	#single press interactions
	if Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A):
		if areas.size():
			for area in areas:
				var root = area.owner
				if root is Interactable:
					root.click(area)
		sprite.play("interact")
		return
	
	#holding down interactions
	if Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_A):
		if areas.size():
			for area in areas:
				var root = area.owner
				if root is Interactable:
					root.drag(self, delta)
		sprite.play("interact")
		return
	
	#temp way to exit game
	if Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_START):
		await Globals.FadeIn()
		Globals.GoToMainMenu()
		return


func _on_hover(_area):
	sprite.play("hover")
	is_hovering = true


func _on_hover_exit(_area):
	sprite.play("default")
	is_hovering = false
