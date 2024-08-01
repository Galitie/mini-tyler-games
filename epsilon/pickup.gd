# NOTE: Disable area monitoring when out of bounds

extends Area2D
class_name Pickup

enum PickupType { NONE, PISTOL, GRENADE, STINGER, KEYCARD }
@export var pickup_type: PickupType = PickupType.NONE
@export var access_level: int
@export var color: Color
var amount: int = 0

func _ready() -> void:	
	$sfx.finished.connect(_sfx_finished)
	body_entered.connect(_body_entered)
	SetPickupType(pickup_type)
	$sprite/description.text = "[center]" + str(PickupType.keys()[pickup_type]) + "[/center]"
	$anim_player.play("float")

func SetPickupType(type: PickupType) -> void:
	match type:
		PickupType.PISTOL:
			amount = 10
			$sprite.play("pistol")
		PickupType.GRENADE:
			amount = 2
			$sprite.play("grenade")
		PickupType.STINGER:
			amount = 4
			$sprite.play("stinger")
		PickupType.KEYCARD:
			amount = 1
			$sprite.play("keycard")
			$sprite.material.set_shader_parameter("new", color)
			
	
func _body_entered(body: Node2D) -> void:
	match pickup_type:
		PickupType.PISTOL:
			body.pistol_ammo += amount
		PickupType.GRENADE:
			body.grenade_ammo += amount
		PickupType.STINGER:
			body.stinger_ammo += amount
		PickupType.KEYCARD:
			var doors = get_tree().get_nodes_in_group("keycard door")
			for door in doors:
				if access_level == door.door_level:
					door.locked = false
					
	set_deferred("monitoring", false)
	visible = false
	$sfx.play()
	
func _sfx_finished() -> void:
	queue_free()
