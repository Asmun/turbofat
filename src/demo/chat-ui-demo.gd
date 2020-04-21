extends Control
"""
A demo which lets you test the chat UI by flipping through pages of dialog.
"""

const FRUITS := [
	"Apple", "Apricot", "Banana", "Cantaloupe", "Cherry", "Grape", "Grapefruit", "Guava", "Lemon", "Lime", "Orange",
	"Mandarin", "Mango", "Melon", "Papaya", "Peach", "Pear", "Pineapple", "Plantain", "Plum", "Tangerine", "Watermelon"
]

func _ready() -> void:
	_play_text()


func _play_text() -> void:
	var chat_events = []
	for i in range(3):
		var chat_event: ChatEvent = ChatEvent.new()
		chat_event.name = "Lorum"
		chat_event.text = "%s ipsum dolor sit amet" % FRUITS[i % FRUITS.size()]
		chat_event.accent_def = {"accent_scale":0.66,"accent_swapped":true,"accent_texture":12,"color":"b23823"}
		chat_events.append(chat_event)
	$ChatUi.play_dialog_sequence(chat_events)