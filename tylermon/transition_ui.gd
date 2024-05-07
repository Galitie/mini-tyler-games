extends MarginContainer

@onready var title_label = $center_container/vbox/vbox/title_text
@onready var confetti = $overlay/confetti


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
		title_label.text = "🎉 ROUND WINNER 🎉"
	else:
		title_label.text = "🎉 ROUND WINNERS 🎉"
	build_winners_nodes(winners)


func clear_winners():
	title_label.text = ""
	var container = get_node("center_container/vbox/winners")
	var children = container.get_children()
	if children.size() > 0:
		for child in children:
			child.queue_free()


func show_final_winners(winners):
	confetti.emitting = true
	if winners.size() == 1:
		title_label.text = "✨🏆 GAME WINNER 🏆✨"
	else:
		title_label.text = "✨🏆 GAME WINNERS 🏆✨"
	build_winners_nodes(winners)


func build_winners_nodes(winners):
	var container = get_node("center_container/vbox/winners")
	for winner in winners:
		var image = TextureRect.new()
		var sprite_frame = winner.get_child(0).get_node("scalable_nodes").get_child(0).get_sprite_frames()
		image.texture = sprite_frame.get_frame_texture("idle",0)
		image.modulate = winner.get_child(0).custom_color
		var vbox = VBoxContainer.new()
		vbox.add_child(image)
		vbox.set("theme_override_constants/separation", -40)
		container.add_child(vbox)
