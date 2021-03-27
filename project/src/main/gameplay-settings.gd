class_name GameplaySettings
"""
Manages settings which control the gameplay.
"""

signal ghost_piece_changed(value)

# 'true' if a ghost piece should be shown during the puzzle sections.
var ghost_piece := true setget set_ghost_piece

func set_ghost_piece(new_ghost_piece: bool) -> void:
	if ghost_piece == new_ghost_piece:
		return
	ghost_piece = new_ghost_piece
	emit_signal("ghost_piece_changed", new_ghost_piece)


"""
Resets the gameplay settings to their default values.
"""
func reset() -> void:
	from_json_dict({})


func to_json_dict() -> Dictionary:
	return {
		"ghost_piece": ghost_piece,
	}


func from_json_dict(json: Dictionary) -> void:
	ghost_piece = json.get("ghost_piece", true)
