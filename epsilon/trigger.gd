extends Area2D
class_name Trigger

signal triggered

enum TriggerType { LEVEL, CODEC }
@export var type: TriggerType

@export var path: String

func _ready() -> void:
	add_to_group("triggers")
	body_entered.connect(_body_entered)
	# NOTE: Janky fix to prevent triggers from firing on a newly loaded map
	await get_tree().create_timer(1.0).timeout
	set_deferred("monitoring", true)

func _body_entered(body: Node2D) -> void:
	emit_signal("triggered", path)
