extends Control

@onready var player_label = $margin/vbox/Label
@export var player_name : String
var mon

# Called when the node enters the scene tree for the first time.
func _ready():
	player_label.text = player_name
	get_mon()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_mon():
	mon = get_parent()


func _on_button_pressed():
	var random_num1 = randf_range(0,1)
	var random_num2 = randf_range(0,1)
	var random_num3 = randf_range(0,1)
	var random_color = Color(random_num1, random_num2, random_num3)
	mon.custom_color = random_color
