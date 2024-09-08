extends Interactable
@onready var item = get_parent().owner.get_parent()

func _ready():
	$sprite.texture = item.content_image
	$label.text = item.content_string
	item.exhausted = true

func _process(_delta):
	pass
