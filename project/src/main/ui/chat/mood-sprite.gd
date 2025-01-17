extends Control
## Shows a little 'happy face' icon next to each chat choice.

## the location of the mood icon; the right or left side of the chat window
export (bool) var mood_right: bool setget set_mood_right

var textures := {
	Creatures.Mood.DEFAULT: preload("res://assets/main/ui/chat/choice-mood-default.png"),
	Creatures.Mood.AWKWARD0: preload("res://assets/main/ui/chat/choice-mood-awkward0.png"),
	Creatures.Mood.AWKWARD1: preload("res://assets/main/ui/chat/choice-mood-awkward1.png"),
	Creatures.Mood.CRY0: preload("res://assets/main/ui/chat/choice-mood-cry0.png"),
	Creatures.Mood.CRY1: preload("res://assets/main/ui/chat/choice-mood-cry1.png"),
	Creatures.Mood.LAUGH0: preload("res://assets/main/ui/chat/choice-mood-laugh0.png"),
	Creatures.Mood.LAUGH1: preload("res://assets/main/ui/chat/choice-mood-laugh1.png"),
	Creatures.Mood.LOVE0: preload("res://assets/main/ui/chat/choice-mood-love0.png"),
	Creatures.Mood.LOVE1: preload("res://assets/main/ui/chat/choice-mood-love1.png"),
	Creatures.Mood.LOVE1_FOREVER: preload("res://assets/main/ui/chat/choice-mood-love1.png"),
	Creatures.Mood.NO0: preload("res://assets/main/ui/chat/choice-mood-no.png"),
	Creatures.Mood.NO1: preload("res://assets/main/ui/chat/choice-mood-no.png"),
	Creatures.Mood.RAGE0: preload("res://assets/main/ui/chat/choice-mood-rage0.png"),
	Creatures.Mood.RAGE1: preload("res://assets/main/ui/chat/choice-mood-rage1.png"),
	Creatures.Mood.RAGE2: preload("res://assets/main/ui/chat/choice-mood-rage2.png"),
	Creatures.Mood.SIGH0: preload("res://assets/main/ui/chat/choice-mood-sigh0.png"),
	Creatures.Mood.SIGH1: preload("res://assets/main/ui/chat/choice-mood-sigh1.png"),
	Creatures.Mood.SLY0: preload("res://assets/main/ui/chat/choice-mood-sly0.png"),
	Creatures.Mood.SLY1: preload("res://assets/main/ui/chat/choice-mood-sly1.png"),
	Creatures.Mood.SMILE0: preload("res://assets/main/ui/chat/choice-mood-smile0.png"),
	Creatures.Mood.SMILE1: preload("res://assets/main/ui/chat/choice-mood-smile1.png"),
	Creatures.Mood.SWEAT0: preload("res://assets/main/ui/chat/choice-mood-sweat0.png"),
	Creatures.Mood.SWEAT1: preload("res://assets/main/ui/chat/choice-mood-sweat1.png"),
	Creatures.Mood.THINK0: preload("res://assets/main/ui/chat/choice-mood-think0.png"),
	Creatures.Mood.THINK1: preload("res://assets/main/ui/chat/choice-mood-think1.png"),
	Creatures.Mood.WAVE0: preload("res://assets/main/ui/chat/choice-mood-smile0.png"),
	Creatures.Mood.WAVE1: preload("res://assets/main/ui/chat/choice-mood-smile0.png"),
	Creatures.Mood.YES0: preload("res://assets/main/ui/chat/choice-mood-yes.png"),
	Creatures.Mood.YES1: preload("res://assets/main/ui/chat/choice-mood-yes.png"),
}


## Sets which mood should be displayed.
##
## Parameters:
## 	'mood': An enum in Creatures.Mood corresponding to the mood to show. '-1' is a valid value, and will result in no
## 		mood being shown.
func set_mood(new_mood: int) -> void:
	if textures.has(new_mood):
		$Texture.texture = textures[new_mood]
	else:
		$Texture.texture = null


## Sets the location of the mood icon.
func set_mood_right(new_mood_right: bool) -> void:
	mood_right = new_mood_right
	if mood_right:
		$Texture.rect_rotation = 8
		anchor_left = 1
		anchor_right = 1
		margin_left = -18
		margin_top = 1 + randi() % 16
	else:
		$Texture.rect_rotation = -8
		anchor_left = 0
		anchor_right = 0
		margin_left = -11
		margin_top = 4 + randi() % 16
	margin_right = margin_left + 28
	margin_bottom = margin_top + 28
