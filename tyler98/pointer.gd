extends Node2D

@export var controller_port: int = 0
@export var player_color: Color = Color("6868d8")
@onready var sprite: AnimatedSprite2D = $sprite

const SPEED: float = 400
var is_hovering: bool = false
var clicked_interactable = null


func _ready():
	sprite.modulate = player_color
	$pointer_area.area_entered.connect(_on_hover)
	$pointer_area.area_exited.connect(_on_hover_exit)


func _physics_process(delta):
	global_position.x = clamp(global_position.x, 95, 1150)
	global_position.y = clamp(global_position.y, 5, 690)
	
	var move_input: Vector2 = Controller.GetLeftStick(controller_port)
	global_position += move_input * SPEED * delta
	var areas = $pointer_area.get_overlapping_areas()
	areas.reverse()
	
	#on hover
	if areas.size() && is_hovering:
		for area in areas:
			var root = area.owner
			if root is Interactable:
				root.hover()
	
	if Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A):
		$sfx.play()
		if areas.size():
			for area in areas:
				var root = area.owner
				if root is Interactable:
					if !root.is_clicked_on:
						if clicked_interactable != null:
							clicked_interactable.is_clicked_on = false
							clicked_interactable.release()
							clicked_interactable = null
						root.click(area, self)
						root.is_clicked_on = true
						if !root.is_queued_for_deletion():
							clicked_interactable = root
						else:
							clicked_interactable = null

	if clicked_interactable != null:
		if Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_A):
			clicked_interactable.drag(self)
	
	if Controller.IsControllerButtonJustReleased(controller_port, JOY_BUTTON_A):
		if clicked_interactable != null:
			clicked_interactable.is_clicked_on = false
			clicked_interactable.release()
			clicked_interactable = null
	
	#pointer animation
	if clicked_interactable:
		sprite.play("interact")
	else:
		if is_hovering:
			sprite.play("hover")
		else:
			sprite.play("default")
	


func _on_hover(_area):
	is_hovering = true


func _on_hover_exit(_area):
	is_hovering = false
