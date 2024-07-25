extends Control

@onready var player_label = $margin/vbox/vbox2/Label
@export var player_name : String
var mon
var player
var upgrade_options: Array = ["color", "elm_type"]
var upgrade_position: int = 0
var moved_stick: bool = false
@onready var cursor = $cursor
# List of all constant Godot colors with uppercase names
const GODOT_COLORS = [
	Color.ALICE_BLUE,
	Color.AQUA,
	Color.AQUAMARINE,
	Color.AZURE,
	Color.BEIGE,
	Color.BISQUE,
	Color.BLANCHED_ALMOND,
	Color.BLUE,
	Color.BLUE_VIOLET,
	Color.BROWN,
	Color.CADET_BLUE,
	Color.CHARTREUSE,
	Color.CHOCOLATE,
	Color.CORAL,
	Color.CORNFLOWER_BLUE,
	Color.CORNSILK,
	Color.CRIMSON,
	Color.CYAN,
	Color.DARK_BLUE,
	Color.DARK_CYAN,
	Color.DARK_GRAY,
	Color.DARK_GREEN,
	Color.DARK_KHAKI,
	Color.DARK_MAGENTA,
	Color.DARK_OLIVE_GREEN,
	Color.DARK_ORANGE,
	Color.DARK_ORCHID,
	Color.DARK_RED,
	Color.DARK_SALMON,
	Color.DARK_SEA_GREEN,
	Color.DARK_SLATE_BLUE,
	Color.DARK_SLATE_GRAY,
	Color.DARK_TURQUOISE,
	Color.DARK_VIOLET,
	Color.DEEP_PINK,
	Color.DEEP_SKY_BLUE,
	Color.DIM_GRAY,
	Color.DODGER_BLUE,
	Color.FIREBRICK,
	Color.FOREST_GREEN,
	Color.FUCHSIA,
	Color.GAINSBORO,
	Color.GOLD,
	Color.GRAY,
	Color.GREEN,
	Color.GREEN_YELLOW,
	Color.HOT_PINK,
	Color.INDIAN_RED,
	Color.INDIGO,
	Color.IVORY,
	Color.KHAKI,
	Color.LAVENDER,
	Color.LAVENDER_BLUSH,
	Color.LAWN_GREEN,
	Color.LEMON_CHIFFON,
	Color.LIGHT_BLUE,
	Color.LIGHT_CORAL,
	Color.LIGHT_CYAN,
	Color.LIGHT_GRAY,
	Color.LIGHT_GREEN,
	Color.LIGHT_PINK,
	Color.LIGHT_SALMON,
	Color.LIGHT_SEA_GREEN,
	Color.LIGHT_SKY_BLUE,
	Color.LIGHT_SLATE_GRAY,
	Color.LIGHT_STEEL_BLUE,
	Color.LIGHT_YELLOW,
	Color.LIME,
	Color.LIME_GREEN,
	Color.LINEN,
	Color.MAGENTA,
	Color.MAROON,
	Color.MEDIUM_AQUAMARINE,
	Color.MEDIUM_BLUE,
	Color.MEDIUM_ORCHID,
	Color.MEDIUM_PURPLE,
	Color.MEDIUM_SEA_GREEN,
	Color.MEDIUM_SLATE_BLUE,
	Color.MEDIUM_SPRING_GREEN,
	Color.MEDIUM_TURQUOISE,
	Color.MEDIUM_VIOLET_RED,
	Color.MIDNIGHT_BLUE,
	Color.MINT_CREAM,
	Color.MISTY_ROSE,
	Color.MOCCASIN,
	Color.OLD_LACE,
	Color.OLIVE,
	Color.OLIVE_DRAB,
	Color.ORANGE,
	Color.ORANGE_RED,
	Color.ORCHID,
	Color.PALE_GREEN,
	Color.PALE_TURQUOISE,
	Color.PALE_VIOLET_RED,
	Color.PAPAYA_WHIP,
	Color.PEACH_PUFF,
	Color.PERU,
	Color.PINK,
	Color.PLUM,
	Color.POWDER_BLUE,
	Color.PURPLE,
	Color.REBECCA_PURPLE,
	Color.RED,
	Color.ROSY_BROWN,
	Color.ROYAL_BLUE,
	Color.SADDLE_BROWN,
	Color.SALMON,
	Color.SANDY_BROWN,
	Color.SEA_GREEN,
	Color.SIENNA,
	Color.SILVER,
	Color.SKY_BLUE,
	Color.SLATE_BLUE,
	Color.SLATE_GRAY,
	Color.SNOW,
	Color.SPRING_GREEN,
	Color.STEEL_BLUE,
	Color.TAN,
	Color.TEAL,
	Color.THISTLE,
	Color.TOMATO,
	Color.TURQUOISE,
	Color.VIOLET,
	Color.WHEAT,
	Color.WHITE,
	Color.YELLOW,
	Color.YELLOW_GREEN
]
signal set_element

func _ready():
	player_label.text = player_name
	get_mon()
	get_player()
	


func _process(delta):
	var vertical_input: float = round(Controller.GetLeftStick(player.controller_port).y)
	if !vertical_input:
		moved_stick = false
	if !moved_stick:
		if vertical_input > 0:
			upgrade_position += 1
			cursor.position.y += 35
			moved_stick = true
		elif vertical_input < 0:
			upgrade_position -= 1
			cursor.position.y -= 35
			moved_stick = true
	if upgrade_position >= upgrade_options.size():
		upgrade_position = 0
		cursor.position.y = 20
	elif upgrade_position < 0:
		upgrade_position = upgrade_options.size() - 1
		cursor.position.y = 58
	if Controller.IsControllerButtonJustPressed(player.controller_port, JOY_BUTTON_A):
		_on_button_pressed(upgrade_options[upgrade_position])

func get_mon():
	mon = get_parent()

func get_player():
	player = mon.get_parent()

func _on_button_pressed(button_name):
	match button_name:
		"color":
			var random_color = GODOT_COLORS.pick_random()
			mon.custom_color = random_color
		"elm_type":
			match mon.elm_type:				
				"FIRE":
					mon.elm_type = "WATER"
					mon.show_element_effect("WATER")
				"WATER":
					mon.elm_type = "GRASS"
					mon.show_element_effect("GRASS")
				"GRASS":
					mon.elm_type = "FIRE"
					mon.show_element_effect("FIRE")
