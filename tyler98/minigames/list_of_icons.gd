extends Interactable
@onready var item = get_parent().owner.get_parent()
var counter = 0
var item1 = false
var item2 = false
var item3 = false
var item4 = false

func _ready():
	pass


func _process(_delta):
	pass


func add_to_counter(item_name):
	match item_name:
		"SxS":
			if item1 == false:
				item1 = true
				counter += 1
		"snake":
			if item2 == false:
				item2 = true
				counter += 1
		"Mmm":
			if item3 == false:
				item3 = true
				counter += 1
		"Xxx":
			if item4 == false:
				item4 = true
				counter += 1
	
	if counter == 4:
		item.exhausted = true
		$sfx.stream = load("res://tyler98/sfx/success.mp3")
		$sfx.play()
		%particles.emitting = true
		await %particles.finished
		await $sfx.finished
