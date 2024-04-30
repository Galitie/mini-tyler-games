extends MarginContainer

@onready var title_label = $center_container/vbox/title_text


func _ready():
	get_tree().get_root().get_node("tylermon").connect("winners", update_winners)
	get_tree().get_root().get_node("tylermon").connect("clear_winners", clear_winners)
	get_tree().get_root().get_node("tylermon").connect("final_winners", show_final_winners)
	title_label.text = ""


func _process(_delta):
	pass


func update_winners(winners):
	if winners.size() == 0:
		"NO WINNERS THIS ROUND"
	if winners.size() == 1:
		title_label.text = "ROUND WINNER:"
	else:
		title_label.text = "ROUND WINNERS:"
	build_winners_nodes(winners)


func clear_winners():
	title_label.text = ""
	var container = get_node("center_container/vbox/winners")
	var children = container.get_children()
	if children.size() > 0:
		for child in children:
			child.queue_free()


func show_final_winners(winners):
	if winners.size() == 1:
		title_label.text = "GAME WINNER:"
	else:
		title_label.text = "GAME WINNERS:"
	build_winners_nodes(winners)


func build_winners_nodes(winners):
	var container = get_node("center_container/vbox/winners")
	for winner in winners:
		var label = Label.new()
		var remaining_health = Label.new()
		remaining_health.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if winner.name == "player0":
			label.text = "Player 1"
			remaining_health.text = "HP remaining: " + str(winner.get_child(0).health)
		if winner.name == "player1":
			label.text = "Player 2"
			remaining_health.text = "HP remaining: " + str(winner.get_child(0).health)
		if winner.name == "player2":
			label.text = "Player 3"
			remaining_health.text = "HP remaining: " + str(winner.get_child(0).health)
		if winner.name == "player3":
			label.text = "Player 4"
			remaining_health.text = "HP remaining: " + str(winner.get_child(0).health)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var image = TextureRect.new()
		image.texture = winner.get_child(0).get_node("sprite").texture
		var vbox = VBoxContainer.new()
		vbox.add_child(label)
		vbox.add_child(image)
		vbox.add_child(remaining_health)
		container.add_child(vbox)
