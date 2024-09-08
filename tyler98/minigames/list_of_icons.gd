extends Interactable
@onready var item = get_parent().owner.get_parent()
var counter = 0

func _ready():
	pass


func _process(_delta):
	pass


func add_to_counter():
	counter += 1
	if counter == 4:
		item.exhausted = true
		$sfx.stream = load("res://tyler98/sfx/success.mp3")
		$sfx.play()
		%particles.emitting = true
		await %particles.finished
		await $sfx.finished
