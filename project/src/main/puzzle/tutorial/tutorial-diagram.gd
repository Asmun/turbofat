class_name TutorialDiagram
extends Control
## Displays a diagram during a tutorial.
##
## These diagrams obstruct the playfield. They're textures which appear in a window, and the player has ok/help buttons
## to ensure they understand the diagram.

## Emitted when the player clicks a button indicating they understand the diagram
signal ok_chosen

## Emitted when the player clicks a button indicating they don't understand the diagram
signal help_chosen

## The number of times the diagram has been shown. We cycle through different chat choices each time.
var _show_diagram_count := 0

onready var _hud: Node = get_parent()

func _ready() -> void:
	hide()


func show_diagram(texture: Texture, show_choices: bool = false) -> void:
	show()
	$VBoxContainer/TextureMarginContainer/TexturePanel/TextureRect.texture = texture
	
	# shift the diagram up to make room for chat choices
	if show_choices:
		$VBoxContainer/TextureMarginContainer.set("custom_constants/margin_top", 10)
		$VBoxContainer/TextureMarginContainer.set("custom_constants/margin_bottom", 10)
		$VBoxContainer/ChatChoices.visible = true
	else:
		$VBoxContainer/TextureMarginContainer.set("custom_constants/margin_top", 85)
		$VBoxContainer/TextureMarginContainer.set("custom_constants/margin_bottom", 85)
		$VBoxContainer/ChatChoices.visible = false
	
	if show_choices:
		if not _hud.messages.is_all_messages_visible():
			yield(_hud.messages, "all_messages_shown")
		var choices: Array
		match _show_diagram_count % 3:
			0: choices = [tr("Okay, I get it!"), tr("...Can you go into more detail?")]
			1: choices = [tr("Yes, I see!"), tr("What do you mean by that?")]
			2: choices = [tr("Oh! That's easy."), tr("Hmm, maybe one more time?")]
		_show_diagram_count += 1
		var moods := [Creatures.Mood.SMILE0, Creatures.Mood.THINK0]
		$VBoxContainer/ChatChoices.show_choices(choices, moods, 2)


func _on_ChatChoices_chat_choice_chosen(choice_index: int) -> void:
	match choice_index:
		0: emit_signal("ok_chosen")
		1: emit_signal("help_chosen")
