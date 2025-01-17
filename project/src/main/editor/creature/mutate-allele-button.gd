class_name LockAlleleButton
extends Button
## A button which can lock/unlock an allele.
##
## Unlocked alleles always mutate. Locked alleles never mutate. Alleles which are neither locked nor unlocked mutate
## sometimes.

## icon which appears next to the button text when the allele is locked
export (Texture) var locked_texture: Texture

## icon which appears next to the button text when the allele is unlocked
export (Texture) var unlocked_texture: Texture

## An allele property used internally when updating the creature. Not shown to the player
export (String) var allele: String

## By default the button toggles between three states: locked/unlocked/flexible. The 'two_states' property can be
## enabled to make the button toggle between locked/unlocked instead.
export (bool) var two_states: bool = false

func is_locked() -> bool:
	return icon == locked_texture


func is_unlocked() -> bool:
	return icon == unlocked_texture


## When the button is pressed, it cycles between three states (Or two states if the 'two_states' property is set)
func _on_pressed() -> void:
	if not icon or (icon != locked_texture and two_states):
		icon = locked_texture
	elif icon == locked_texture:
		icon = unlocked_texture
	else:
		icon = null
