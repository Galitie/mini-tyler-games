extends Interactable
@onready var item = get_parent().owner.get_parent()

func _ready():
	$sprite.texture = item.content_image
	$label.text = item.content_string
	
	if item.audio != null:
		get_tree().get_root().get_node("main").task_completed(item.task_id)
		$audio.stream = item.audio
		$audio.play()
		await $audio.finished
		$audio.stream = load("res://tyler98/sfx/success.mp3")
		$audio.play()
		item.exhausted = true
		get_parent().owner.get_node("particles").emitting = true
		await get_parent().owner.get_node("particles").finished
		item.exhausted = true

func _process(_delta):
	pass
