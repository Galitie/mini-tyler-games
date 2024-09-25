extends Control

@onready var player_label = $margin/vbox/vbox2/Label
@onready var cursor = $cursor
@export var player_name : String

var mon
var player
var upgrade_options: Array = ["name", "color"]
var upgrade_position: int = 0
var moved_stick: bool = false
var name_position = 0
var color_position = 0

signal upgraded


const GODOT_COLORS = [
	#Blues and Cyans
	Color.AZURE,
	Color.SKY_BLUE,
	Color.DODGER_BLUE,
	Color.LIGHT_SKY_BLUE,
	Color.STEEL_BLUE,
	Color.CADET_BLUE,
	Color.CYAN,
	Color.DARK_TURQUOISE,
	#Greens
	Color.LAWN_GREEN,
	Color.LIGHT_GREEN,
	Color.LIME,
	Color.LIME_GREEN,
	Color.GREEN_YELLOW,
	Color.MEDIUM_SEA_GREEN,
	Color.DARK_GREEN,
	Color.FOREST_GREEN,
	Color.DARK_OLIVE_GREEN,
	Color.OLIVE,
	Color.OLIVE_DRAB,
	Color.SEA_GREEN,
	Color.DARK_SEA_GREEN,
	Color.MEDIUM_SPRING_GREEN,
	Color.CHARTREUSE,
	#Yellows and Beiges
	Color.LIGHT_YELLOW,
	Color.GOLD,
	Color.LAVENDER_BLUSH,
	#Oranges
	Color.ORANGE,
	Color.ORANGE_RED,
	Color.DARK_ORANGE,
	Color.TOMATO,
	Color.CHOCOLATE,
	#Reds and Pinks
	Color.RED,
	Color.CRIMSON,
	Color.FIREBRICK,
	Color.DARK_RED,
	Color.DEEP_PINK,
	Color.HOT_PINK,
	Color.MEDIUM_VIOLET_RED,
	Color.INDIAN_RED,
	Color.LIGHT_PINK,
	Color.ROSY_BROWN,
	Color.PALE_VIOLET_RED,
	#Purples
	Color.FUCHSIA,
	Color.MAROON,
	Color.PURPLE,
	Color.VIOLET,
	Color.INDIGO,
	Color.BLUE_VIOLET,
	Color.DARK_VIOLET,
	Color.MEDIUM_PURPLE,
	Color.MEDIUM_ORCHID,
	Color.DARK_ORCHID,
	Color.REBECCA_PURPLE,
	#Grays and Neutrals
	Color.DIM_GRAY,
	Color.LIGHT_GRAY,
	Color.LIGHT_SLATE_GRAY,
	Color.SLATE_GRAY,
	Color.DARK_GRAY,
	Color.SILVER,
	#Browns
	Color.BROWN,
	Color.SIENNA,
	Color.SADDLE_BROWN,
	Color.DARK_SALMON,
	Color.MEDIUM_AQUAMARINE,
];

const NAME_OPTIONS = [
	"Al", "Art", "Barry", "Bert", "Bill", "Bob", "Bruce", "Carl", "Chuck",
	"Cliff", "Clint", "Clay", "Curt", "Dale", "Dan", "Daryl", "Dean", "Dennis",  "Denny", "Doug",
	"Dwight", "Earl", "Ed", "Edgar", "Ernie", "Floyd", "Frank",  "Gary", "Gene", "Glenn", "Glen",
	"Gordon", "Greg", "Hal", "Harold", "Harvey",  "Hank", "Howard", "Jim", "Joe", "Jerry", "Jeff",
	"Ken", "Keith", "Kenny",  "Larry", "Lenny", "Les", "Lewis", "Marty", "Mark", "Mel", "Mitch",
	"Mike",  "Norm", "Neil", "Otis", "Paul", "Pat", "Randy", "Ray", "Ron", "Ronnie",  "Roy", "Russ",
	"Rex", "Scott", "Stan", "Steve", "Stu", "Ted", "Terry", "Tim", "Vince", "Wayne", "Walt", "Warren", "Wes"
]

signal change_name

func _ready():
	player_label.text = player_name
	get_mon()
	get_player()	


func _physics_process(_delta):
	var vertical_input: float = round(Controller.GetLeftStick(player.controller_port).y)
	var horizontal_input: float = round(Controller.GetLeftStick(player.controller_port).x)
	if !vertical_input and !horizontal_input:
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
		elif horizontal_input > 0:
			moved_stick = true
			_on_button_pressed(upgrade_options[upgrade_position], horizontal_input)
		elif horizontal_input < 0:
			moved_stick = true
			_on_button_pressed(upgrade_options[upgrade_position], horizontal_input)
	if upgrade_position >= upgrade_options.size():
		upgrade_position = 0
		cursor.position.y = 23
	elif upgrade_position < 0:
		upgrade_position = upgrade_options.size() - 1
		cursor.position.y = 54


func get_mon():
	mon = get_parent()


func get_player():
	player = mon.get_parent()


func _on_button_pressed(button_name, direction):
	
	match button_name:
		"color":
			if direction > 0:
				color_position += 1
			if direction < 0:
				color_position -= 1
			if color_position > GODOT_COLORS.size() - 1:
				color_position = 0
			if color_position < 0:
				color_position = GODOT_COLORS.size() - 1
			mon.get_node("%sprite").material.set_shader_parameter("modulate", GODOT_COLORS[color_position])
			mon.mon_color = GODOT_COLORS[color_position]
			mon.mon_trail.color = GODOT_COLORS[color_position]

		"name":
			if direction > 0:
				name_position += 1
			if direction < 0:
				name_position -= 1
			if name_position > NAME_OPTIONS.size() - 1:
				name_position = 0
			if color_position < 0:
				name_position = NAME_OPTIONS.size() - 1
			mon.change_name(NAME_OPTIONS[name_position])

