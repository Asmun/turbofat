class_name NextPieceDisplay
extends Node2D
## Contains logic for a single 'next piece display'. A single display might only display the piece which is coming up 3
## pieces from now. Several displays are shown at once.

var _piece_queue: PieceQueue

## how far into the future this display should look; 0 = show the next piece, 10 = show the 11th piece
var _piece_index := 0

var _displayed_type: PieceType
var _displayed_orientation: int

onready var _tile_map: PuzzleTileMap = $TileMap

func initialize(piece_queue: PieceQueue, piece_index: int) -> void:
	_piece_queue = piece_queue
	_piece_index = piece_index


func _ready() -> void:
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	_prepare_tileset()


func _process(_delta: float) -> void:
	var next_piece: NextPiece = _piece_queue.get_next_piece(_piece_index)
	if next_piece.type != _displayed_type or next_piece.orientation != _displayed_orientation:
		_tile_map.clear()
		if next_piece.type != PieceTypes.piece_null:
			var bounding_box := Rect2( \
					next_piece.type.get_cell_position(next_piece.orientation, 0), Vector2(1.0, 1.0))
			# update the tilemap with the new piece type
			for i in range(next_piece.type.pos_arr[0].size()):
				var block_pos := next_piece.type.get_cell_position(next_piece.orientation, i)
				var block_color := next_piece.type.get_cell_color(next_piece.orientation, i)
				_tile_map.set_block(block_pos, 0, block_color)
				bounding_box = bounding_box.expand( \
						next_piece.type.get_cell_position(next_piece.orientation, i))
				bounding_box = bounding_box.expand( \
						next_piece.type.get_cell_position(next_piece.orientation, i) + Vector2(1, 1))
			_tile_map.position = _tile_map.cell_size \
					* (Vector2(1.5, 1.5) - (bounding_box.position + bounding_box.size / 2.0)) / 2.0
		_tile_map.corner_map.dirty = true
		_displayed_type = next_piece.type
		_displayed_orientation = next_piece.orientation


func _prepare_tileset() -> void:
	_tile_map.puzzle_tile_set_type = CurrentLevel.settings.other.tile_set


func _on_Level_settings_changed() -> void:
	_prepare_tileset()
