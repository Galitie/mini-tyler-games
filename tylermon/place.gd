extends HBoxContainer


func _ready():
	pass # Replace with function body.


func set_place():
	var sorted_array = []
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		sorted_array.append([str(player.get_child(0).mon_name), int(player.wins), player])
	sorted_array.sort_custom(sort_descending)
	%firstplace.get_child(0).set("theme_override_colors/font_color", sorted_array[0][2].get_child(0).mon_color)
	%secondplace.get_child(0).set("theme_override_colors/font_color", sorted_array[1][2].get_child(0).mon_color)
	%thirdplace.get_child(0).set("theme_override_colors/font_color", sorted_array[2][2].get_child(0).mon_color)
	%fourthplace.get_child(0).set("theme_override_colors/font_color", sorted_array[3][2].get_child(0).mon_color)
	%firstplace.get_child(0).text = sorted_array[0][0] + " - 👑" + str(sorted_array[0][1])
	%secondplace.get_child(0).text = sorted_array[1][0] + " - 👑" + str(sorted_array[1][1])
	%thirdplace.get_child(0).text = sorted_array[2][0] + " - 👑" + str(sorted_array[2][1])
	%fourthplace.get_child(0).text = sorted_array[3][0] + " - 👑" + str(sorted_array[3][1])
	

func sort_descending(a, b):
	if a[1] > b[1]:
		return true
	return false
	
func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique
