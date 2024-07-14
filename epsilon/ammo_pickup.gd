# NOTE: Disable area monitoring when out of bounds

extends Area2D
class_name AmmoPickup

enum WeaponType { NONE, PISTOL, GRENADE, STINGER }
@export var weapon_type: WeaponType = WeaponType.NONE
var amount: int = 0

func _ready() -> void:
	body_entered.connect(_body_entered)
	SetWeaponType(weapon_type)
	show_ammo_details(weapon_type)
	$anim_player.play("float")

func SetWeaponType(type: WeaponType) -> void:
	match type:
		WeaponType.PISTOL:
			amount = 10
			$sprite.play("pistol")
		WeaponType.GRENADE:
			amount = 2
			$sprite.play("grenade")
		WeaponType.STINGER:
			amount = 4
			$sprite.play("stinger")
	
func _body_entered(body: Node2D) -> void:
	match weapon_type:
		WeaponType.PISTOL:
			body.pistol_ammo += amount
		WeaponType.GRENADE:
			body.grenade_ammo += amount
		WeaponType.STINGER:
			body.stinger_ammo += amount
	queue_free()

func show_ammo_details(type: WeaponType) -> void:
	$sprite/ammo_amount.text = "+" + str(amount) + " " + str(WeaponType.keys()[weapon_type])
