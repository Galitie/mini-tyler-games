extends Area2D

func _ready() -> void:
	$timer.timeout.connect(_on_timeout)

func _on_timeout() -> void:
	$anim_player.play("ping")
	$sfx.play()
