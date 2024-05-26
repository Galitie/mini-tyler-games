extends RigidBody2D
var thrust = Vector2(0, -250)
var torque = 1000000

func _integrate_forces(state):
	state.apply_force(Vector2())
	var rotation_direction = 0
	if Input.is_action_pressed("ui_right"):
		rotation_direction += 1
	if Input.is_action_pressed("ui_left"):
		rotation_direction -= 1
	state.apply_torque(rotation_direction * torque)
