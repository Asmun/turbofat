class_name MileMarker
extends OverworldObstacle
## A distance marker which appears in the overworld during career mode.

## key: (int) Mile Marker sprite frame
## value: (Vector2) Position to align the text with the specified sprite frame
const TEXT_POSITION_BY_FRAME := {
	0: Vector2(4.049, -24.495),
	1: Vector2(-5.83, -23.685),
	2: Vector2(-2.182, -25.088),
	3: Vector2(0.344, -24.527),
}

## key: (int) Mile Marker sprite frame
## value: (Vector2) Rotation degrees to align the text with the specified sprite frame
const TEXT_ROTATION_DEGREES_BY_FRAME := {
	0: 12,
	1: -14,
	2: -7,
	3: 0,
}

## Number which appears on the sign
export (int) var mile_number: int = 1 setget set_mile_number

onready var _label := $Text/Label
onready var _sprite := $Sprite
onready var _text := $Text

func _ready() -> void:
	_randomize_sprite()
	_refresh_label()


func set_mile_number(new_mile_number: int) -> void:
	mile_number = new_mile_number
	_refresh_label()


## Randomizes the sprite's appearance and repositions the text.
func _randomize_sprite() -> void:
	# randomize the sprite's appearance
	_sprite.frame = randi() % 4
	_sprite.flip_h = randf() > 0.5
	
	# align the text based on the sprite's appearance
	_text.position = TEXT_POSITION_BY_FRAME[_sprite.frame]
	_text.rotation_degrees = TEXT_ROTATION_DEGREES_BY_FRAME[_sprite.frame]
	if _sprite.flip_h:
		_text.rotation_degrees *= -1
		_text.position.x *= -1


## Updates the label's text based on the mile number.
func _refresh_label() -> void:
	if not is_inside_tree():
		return
	
	_label.text = str(mile_number) if mile_number >= 0 and mile_number <= 99 else "?"
