class_name ChatEvent
## Contains details for a line of spoken text shown to the player.

enum NametagSide {
	NO_PREFERENCE,
	LEFT,
	RIGHT,
}

## The name of the person speaking, or blank if nobody is speaking
var who := ""

## whether the chatter's nametag should be drawn on the right/left side of the frame
var nametag_side: int = NametagSide.NO_PREFERENCE

## The chat line
var text: String

## The behavior the chatter should perform while saying the text (laughing, sweating, etc)
var mood: int = Creatures.Mood.NONE

## Metadata about the chat event, such as whether it should launch a level
var meta: Array

## List of string keys corresponding to branches off of this chat event.
var links: Array

## List of string chat texts corresponding to branches off of this chat event.
var link_texts: Array

## List of int chat moods corresponding to branches off of this chat event.
var link_moods: Array

## List of Array metadatas about the links, such as which conditions should enable it
var link_metas: Array

## The chat window changes its appearance based on who's talking. For example, one character's speech might be blue
## with a black background, and giant blue soccer balls in the background. The 'chat_theme_def' property defines the
## chat window's appearance, such as 'blue', 'soccer balls' and 'giant'.
##
## 'chat_theme_def/accent_scale': The scale of the accent's background texture
## 'chat_theme_def/accent_swapped': If 'true', the accent's foreground/background colors will be swapped
## 'chat_theme_def/accent_texture': A number in the range [0, 15] referring to a background texture
## 'chat_theme_def/color': The color of the chat window
## 'chat_theme_def/dark': True/false for whether the chat line window's background should be black/white
var chat_theme_def: Dictionary

func add_link(link: String, link_text: String, link_mood: int) -> void:
	links.append(link)
	link_texts.append(link_text)
	link_moods.append(link_mood)
	link_metas.append([])


func enabled_link_indexes() -> Array:
	var enabled_link_indexes := []
	for i in range(links.size()):
		var link_condition: String
		for meta_item in link_metas[i]:
			if meta_item.begins_with("link_if "):
				link_condition = meta_item.trim_prefix("link_if ")
				break
		
		if not link_condition or BoolExpressionEvaluator.evaluate(link_condition):
			enabled_link_indexes.append(i)
	return enabled_link_indexes


## Returns 'true' if this chat event represents something the player is thinking.
func is_thought() -> bool:
	return text.begins_with("(") and text.ends_with(")") and not who


func _to_string() -> String:
	return ("%s:%s" % [who, text]) if who else text
