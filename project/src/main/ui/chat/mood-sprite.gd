extends Control
## Shows a little 'happy face' icon next to each chat choice.

## the location of the mood icon; the right or left side of the chat window
export (bool) var mood_right: bool setget set_mood_right

var textures := {
	ChatEvent.Mood.DEFAULT: preload("res://assets/main/ui/chat/choice-mood-default.png"),
	ChatEvent.Mood.AWKWARD0: preload("res://assets/main/ui/chat/choice-mood-awkward0.png"),
	ChatEvent.Mood.AWKWARD1: preload("res://assets/main/ui/chat/choice-mood-awkward1.png"),
	ChatEvent.Mood.CRY0: preload("res://assets/main/ui/chat/choice-mood-cry0.png"),
	ChatEvent.Mood.CRY1: preload("res://assets/main/ui/chat/choice-mood-cry1.png"),
	ChatEvent.Mood.LAUGH0: preload("res://assets/main/ui/chat/choice-mood-laugh0.png"),
	ChatEvent.Mood.LAUGH1: preload("res://assets/main/ui/chat/choice-mood-laugh1.png"),
	ChatEvent.Mood.LOVE0: preload("res://assets/main/ui/chat/choice-mood-love0.png"),
	ChatEvent.Mood.LOVE1: preload("res://assets/main/ui/chat/choice-mood-love1.png"),
	ChatEvent.Mood.LOVE1_FOREVER: preload("res://assets/main/ui/chat/choice-mood-love1.png"),
	ChatEvent.Mood.NO0: preload("res://assets/main/ui/chat/choice-mood-no.png"),
	ChatEvent.Mood.NO1: preload("res://assets/main/ui/chat/choice-mood-no.png"),
	ChatEvent.Mood.RAGE0: preload("res://assets/main/ui/chat/choice-mood-rage0.png"),
	ChatEvent.Mood.RAGE1: preload("res://assets/main/ui/chat/choice-mood-rage1.png"),
	ChatEvent.Mood.RAGE2: preload("res://assets/main/ui/chat/choice-mood-rage2.png"),
	ChatEvent.Mood.SIGH0: preload("res://assets/main/ui/chat/choice-mood-sigh0.png"),
	ChatEvent.Mood.SIGH1: preload("res://assets/main/ui/chat/choice-mood-sigh1.png"),
	ChatEvent.Mood.SMILE0: preload("res://assets/main/ui/chat/choice-mood-smile0.png"),
	ChatEvent.Mood.SMILE1: preload("res://assets/main/ui/chat/choice-mood-smile1.png"),
	ChatEvent.Mood.SWEAT0: preload("res://assets/main/ui/chat/choice-mood-sweat0.png"),
	ChatEvent.Mood.SWEAT1: preload("res://assets/main/ui/chat/choice-mood-sweat1.png"),
	ChatEvent.Mood.THINK0: preload("res://assets/main/ui/chat/choice-mood-think0.png"),
	ChatEvent.Mood.THINK1: preload("res://assets/main/ui/chat/choice-mood-think1.png"),
	ChatEvent.Mood.WAVE0: preload("res://assets/main/ui/chat/choice-mood-smile0.png"),
	ChatEvent.Mood.WAVE1: preload("res://assets/main/ui/chat/choice-mood-smile0.png"),
	ChatEvent.Mood.YES0: preload("res://assets/main/ui/chat/choice-mood-yes.png"),
	ChatEvent.Mood.YES1: preload("res://assets/main/ui/chat/choice-mood-yes.png"),
}


## Sets which mood should be displayed.
##
## Parameters:
## 	'mood': An enum in ChatEvent.Mood corresponding to the mood to show. '-1' is a valid value, and will result in no
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
