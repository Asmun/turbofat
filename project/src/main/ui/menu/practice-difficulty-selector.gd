extends VBoxContainer
## UI control for selecting difficulty in practice mode.

signal difficulty_changed

## difficulties which appear as tick mark labels
var _difficulty_names: Array setget set_difficulty_names

func _on_Slider_value_changed(_value: float) -> void:
	emit_signal("difficulty_changed")

## Returns the currently selected difficulty string such as 'Normal' or 'Expert'
func get_selected_difficulty() -> String:
	if not is_inside_tree():
		return "Normal"
	return _difficulty_names[$Slider.value]


## Sets the currently selected difficulty string such as 'Normal' or 'Expert'
func set_selected_difficulty(new_difficulty: String) -> void:
	$Slider.value = _difficulty_names.find(new_difficulty)


## Lowlights difficulty labels, turning them black.
##
## In rank mode, this lets the player see which ranks haven't yet completed.
func set_difficulty_lowlights(new_lowlights: Array) -> void:
	for i in range($Labels.get_child_count()):
		var label: Label = $Labels.get_child(i)
		var lowlighted: bool = new_lowlights.size() > i and new_lowlights[i]
		label.set("custom_colors/font_color", Color.black if lowlighted else Color.white)


## Sets the difficulty names which appear as tick mark labels.
func set_difficulty_names(new_names: Array) -> void:
	_difficulty_names = new_names
	
	# update the slider
	$Slider.max_value = _difficulty_names.size() - 1
	$Slider.tick_count = _difficulty_names.size()
	
	# clear out the old labels
	for child in $Labels.get_children():
		child.queue_free()
		# remove_child to ensure old labels don't affect lowlight calculations
		$Labels.remove_child(child)
	
	# add the new labels
	for name_obj in _difficulty_names:
		var name: String = name_obj
		var label := Label.new()
		label.text = name
		label.align = Label.ALIGN_CENTER
		label.size_flags_horizontal = Label.SIZE_EXPAND_FILL
		$Labels.add_child(label)
	
	# outermost labels take up less space; this helps the ticks align better
	$Labels.get_child(0).align = Label.ALIGN_LEFT
	$Labels.get_child($Labels.get_child_count() - 1).align = Label.ALIGN_RIGHT
	
	$Labels.get_child(0).size_flags_stretch_ratio = 0.5
	$Labels.get_child($Labels.get_child_count() - 1).size_flags_stretch_ratio = 0.5
