class_name NextPieceDisplays
extends Control
"""
Displays upcoming pieces to the player and manages the next piece displays.
"""

const DISPLAY_COUNT := 9

export (PackedScene) var NextPieceDisplayScene

# The "next piece displays" which are shown to the user
var _next_piece_displays := []

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")
	for i in range(DISPLAY_COUNT):
		_add_display(i, 5, 5 + i * (486.0 / (DISPLAY_COUNT - 1)), 0.5)


"""
Adds a new next piece display.
"""
func _add_display(piece_index: int, x: float, y: float, scale: float) -> void:
	var new_display: NextPieceDisplay = NextPieceDisplayScene.instance()
	new_display.initialize(piece_index)
	new_display.scale = Vector2(scale, scale)
	new_display.position = Vector2(x, y)
	new_display.hide()
	add_child(new_display)
	_next_piece_displays.append(new_display)


"""
Gets ready for a new game, randomizing the pieces and filling the piece queues.
"""
func _on_PuzzleScore_game_prepared() -> void:
	for next_piece_display in _next_piece_displays:
		next_piece_display.show()


func _on_Pauser_paused_changed(value: bool) -> void:
	for display in _next_piece_displays:
		display.visible = !value
