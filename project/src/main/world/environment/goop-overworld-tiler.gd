tool
extends Node
## Autotiles a tilemap for goopy/goopless overworld cakes.
##
## The overworld cake autotiling rules involve multiple cell types and cannot be handled by Godot's built-in
## autotiling. Instead of configuring the autotiling behavior with the TileSet's autotile bitmask, it is configured
## with several dictionary constants defined in this script.
##
## This class also assigns appropriate 'corner covers', tiles which cover the corners of an overworld tilemap.

enum TileTypes {
	NONE,
	NO_GOOP,
	SOME_GOOP,
	ALL_GOOP,
}

## Constants for adjacent cake tiles.
const CAKE_TOP := 1
const CAKE_BOTTOM := 2
const CAKE_LEFT := 4
const CAKE_RIGHT := 8
const CAKE_ALL := CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP

## Constants for adjacent goopy tiles.
const GOOP_TOP := 16
const GOOP_BOTTOM := 32
const GOOP_LEFT := 64
const GOOP_RIGHT := 128
const GOOP_CENTER := 256

## Constants for corner covers.
const GOOP_TOPLEFT := 512
const CAKE_CENTER := 1024

## Defines which tiles are used for different combination of goopy/goopless surrounding tiles.
##
## The key is a bitmask with the following components:
##   * CAKE_ALL
##   * CAKE_BOTTOM
##   * CAKE_LEFT
##   * CAKE_RIGHT
##   * CAKE_TOP
##   * GOOP_BOTTOM
##   * GOOP_CENTER
##   * GOOP_LEFT
##   * GOOP_RIGHT
##   * GOOP_TOP
##
## key: (int) bitmask of surrounding tiles
## value: (Vector2) array of two elements which define a 'binding value':
##  value[0]: an enum from TileTypes defining the new tile type, such as 'ALL_GOOP' or 'SOME_GOOP'
##  value[1]: autotile coordinate of the new tile
const NO_GOOP_AUTOTILE_COORDS_BY_BINDING := {
	# goopless tiles
	0: [TileTypes.NO_GOOP,
			[Vector2(0, 0), Vector2(1, 0)]],
	CAKE_TOP: [TileTypes.NO_GOOP,
			[Vector2(2, 0), Vector2(3, 0)]],
	CAKE_BOTTOM: [TileTypes.NO_GOOP,
			[Vector2(4, 0), Vector2(5, 0)]],
	CAKE_BOTTOM | CAKE_TOP: [TileTypes.NO_GOOP,
			[Vector2(0, 1), Vector2(1, 1)]],
	CAKE_LEFT: [TileTypes.NO_GOOP,
			[Vector2(2, 1), Vector2(3, 1)]],
	CAKE_LEFT | CAKE_TOP: [TileTypes.NO_GOOP,
			[Vector2(4, 1), Vector2(5, 1)]],
	CAKE_LEFT | CAKE_BOTTOM: [TileTypes.NO_GOOP,
			[Vector2(0, 2), Vector2(1, 2)]],
	CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP: [TileTypes.NO_GOOP,
			[Vector2(2, 2), Vector2(3, 2)]],
	CAKE_RIGHT: [TileTypes.NO_GOOP,
			[Vector2(4, 2), Vector2(5, 2)]],
	CAKE_RIGHT | CAKE_TOP: [TileTypes.NO_GOOP,
			[Vector2(0, 3), Vector2(1, 3)]],
	CAKE_RIGHT | CAKE_BOTTOM: [TileTypes.NO_GOOP,
			[Vector2(2, 3), Vector2(3, 3)]],
	CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP: [TileTypes.NO_GOOP,
			[Vector2(4, 3), Vector2(5, 3)]],
	CAKE_RIGHT | CAKE_LEFT: [TileTypes.NO_GOOP,
			[Vector2(0, 4), Vector2(1, 4)]],
	CAKE_RIGHT | CAKE_LEFT | CAKE_TOP: [TileTypes.NO_GOOP,
			[Vector2(2, 4), Vector2(3, 4)]],
	CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM: [TileTypes.NO_GOOP,
			[Vector2(4, 4), Vector2(5, 4)]],
	CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP: [TileTypes.NO_GOOP,
			# This first 4-way goopless tile is blank. We repeat it to increase its likelihood of being selected.
			[Vector2(0, 5), Vector2(0, 5), Vector2(0, 5), Vector2(0, 5), Vector2(0, 5),
			Vector2(1, 5), Vector2(2, 5), Vector2(3, 5), Vector2(4, 5), Vector2(5, 5)]],
	
	# fully goopy tiles, where all adjacent blocks are also goopy
	GOOP_CENTER:
			[TileTypes.ALL_GOOP, [Vector2(0, 0)]],
	GOOP_CENTER | CAKE_TOP | GOOP_TOP:
			[TileTypes.ALL_GOOP, [Vector2(1, 0)]],
	GOOP_CENTER | CAKE_BOTTOM | GOOP_BOTTOM:
			[TileTypes.ALL_GOOP, [Vector2(2, 0)]],
	GOOP_CENTER | CAKE_BOTTOM | CAKE_TOP | GOOP_BOTTOM | GOOP_TOP:
			[TileTypes.ALL_GOOP, [Vector2(3, 0)]],
	GOOP_CENTER | CAKE_LEFT | GOOP_LEFT:
			[TileTypes.ALL_GOOP, [Vector2(4, 0)]],
	GOOP_CENTER | CAKE_LEFT | CAKE_TOP | GOOP_LEFT | GOOP_TOP:
			[TileTypes.ALL_GOOP, [Vector2(5, 0)]],
	GOOP_CENTER | CAKE_LEFT | CAKE_BOTTOM | GOOP_LEFT | GOOP_BOTTOM:
			[TileTypes.ALL_GOOP, [Vector2(0, 1)]],
	GOOP_CENTER | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP | GOOP_LEFT | GOOP_BOTTOM | GOOP_TOP:
			[TileTypes.ALL_GOOP, [Vector2(1, 1)], Vector2(2, 1), Vector2(3, 1), Vector2(4, 1)],
	GOOP_CENTER | CAKE_RIGHT | GOOP_RIGHT:
			[TileTypes.ALL_GOOP, [Vector2(5, 1)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_TOP | GOOP_RIGHT | GOOP_TOP:
			[TileTypes.ALL_GOOP, [Vector2(0, 2)]],
	GOOP_CENTER | CAKE_BOTTOM | CAKE_RIGHT | GOOP_BOTTOM | GOOP_RIGHT:
			[TileTypes.ALL_GOOP, [Vector2(1, 2)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP | GOOP_RIGHT | GOOP_BOTTOM | GOOP_TOP:
			[TileTypes.ALL_GOOP, [Vector2(2, 2)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_LEFT | GOOP_RIGHT | GOOP_LEFT:
			[TileTypes.ALL_GOOP, [Vector2(3, 2)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_TOP | GOOP_RIGHT | GOOP_LEFT | GOOP_TOP:
			[TileTypes.ALL_GOOP, [Vector2(4, 2), Vector2(5, 2), Vector2(0, 3), Vector2(1, 3)]],
	GOOP_CENTER | CAKE_BOTTOM | CAKE_RIGHT | CAKE_LEFT | GOOP_RIGHT | GOOP_LEFT | GOOP_BOTTOM:
			[TileTypes.ALL_GOOP, [Vector2(2, 3)]],
	GOOP_CENTER | CAKE_ALL | GOOP_RIGHT | GOOP_LEFT | GOOP_BOTTOM | GOOP_TOP:
			[TileTypes.ALL_GOOP, [Vector2(3, 3)]],
	
	# partially goopy tiles, where some adjacent blocks are goopless
	GOOP_CENTER | CAKE_ALL:
			[TileTypes.SOME_GOOP, [Vector2(0, 0)]],
	GOOP_CENTER | CAKE_ALL | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(1, 0)]],
	GOOP_CENTER | CAKE_ALL | GOOP_BOTTOM: [TileTypes.SOME_GOOP,
			[Vector2(2, 0)]],
	GOOP_CENTER | CAKE_ALL | GOOP_BOTTOM | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(3, 0), Vector2(4, 0)]],
	GOOP_CENTER | CAKE_ALL | GOOP_LEFT: [TileTypes.SOME_GOOP,
			[Vector2(5, 0)]],
	GOOP_CENTER | CAKE_ALL | GOOP_LEFT | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(6, 0), Vector2(7, 0)]],
	GOOP_CENTER | CAKE_ALL | GOOP_LEFT | GOOP_BOTTOM: [TileTypes.SOME_GOOP,
			[Vector2(0, 1), Vector2(1, 1)]],
	GOOP_CENTER | CAKE_ALL | GOOP_LEFT | GOOP_BOTTOM | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(2, 1), Vector2(3, 1)]],
	GOOP_CENTER | CAKE_ALL | GOOP_RIGHT: [TileTypes.SOME_GOOP,
			[Vector2(4, 1)]],
	GOOP_CENTER | CAKE_ALL | GOOP_RIGHT | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(5, 1), Vector2(6, 1)]],
	GOOP_CENTER | CAKE_ALL | GOOP_RIGHT | GOOP_BOTTOM: [TileTypes.SOME_GOOP,
			[Vector2(7, 1), Vector2(0, 2)]],
	GOOP_CENTER | CAKE_ALL | GOOP_RIGHT | GOOP_BOTTOM | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(1, 2), Vector2(2, 2)]],
	GOOP_CENTER | CAKE_ALL | GOOP_RIGHT | GOOP_LEFT: [TileTypes.SOME_GOOP,
			[Vector2(3, 2), Vector2(4, 2)]],
	GOOP_CENTER | CAKE_ALL | GOOP_RIGHT | GOOP_LEFT | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(5, 2), Vector2(6, 2)]],
	GOOP_CENTER | CAKE_ALL | GOOP_RIGHT | GOOP_LEFT | GOOP_BOTTOM: [TileTypes.SOME_GOOP,
			[Vector2(7, 2), Vector2(0, 3)]],
	
	# partially goopy tiles on an edge
	GOOP_CENTER | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(1, 3)]],
	GOOP_CENTER | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP | GOOP_BOTTOM: [TileTypes.SOME_GOOP,
			[Vector2(2, 3)]],
	GOOP_CENTER | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP | GOOP_LEFT | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(3, 3)]],
	GOOP_CENTER | CAKE_LEFT | CAKE_BOTTOM | CAKE_TOP | GOOP_LEFT | GOOP_BOTTOM: [TileTypes.SOME_GOOP,
			[Vector2(4, 3)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(5, 3)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP | GOOP_BOTTOM: [TileTypes.SOME_GOOP,
			[Vector2(6, 3)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP | GOOP_RIGHT | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(7, 3)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_BOTTOM | CAKE_TOP | GOOP_RIGHT | GOOP_BOTTOM: [TileTypes.SOME_GOOP,
			[Vector2(0, 4)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_TOP | GOOP_LEFT: [TileTypes.SOME_GOOP,
			[Vector2(1, 4)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_TOP | GOOP_LEFT | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(2, 4)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_TOP | GOOP_RIGHT: [TileTypes.SOME_GOOP,
			[Vector2(3, 4)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_TOP | GOOP_RIGHT | GOOP_TOP: [TileTypes.SOME_GOOP,
			[Vector2(4, 4)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | GOOP_LEFT: [TileTypes.SOME_GOOP,
			[Vector2(5, 4)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | GOOP_LEFT | GOOP_BOTTOM: [TileTypes.SOME_GOOP,
			[Vector2(6, 4)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | GOOP_RIGHT: [TileTypes.SOME_GOOP,
			[Vector2(7, 4)]],
	GOOP_CENTER | CAKE_RIGHT | CAKE_LEFT | CAKE_BOTTOM | GOOP_RIGHT | GOOP_BOTTOM: [TileTypes.SOME_GOOP,
			[Vector2(0, 5)]],
}

## Defines which corner covers are used for different sets of surrounding tiles.
##
## The key is a bitmask with the following components:
##   * GOOP_CENTER
##   * GOOP_LEFT
##   * GOOP_TOP
##   * GOOP_TOP_LEFT
##
## key: (int) A bitmask of surrounding tiles
## value: (Vector2) autotile coordinate of the corner cover
const CORNER_COVERS_BY_BINDING := {
	0: Vector2(0, 0),
	GOOP_TOP: Vector2(0, 0),
	GOOP_LEFT: Vector2(0, 0),
	GOOP_LEFT | GOOP_TOP: Vector2(0, 0),
	GOOP_CENTER: Vector2(0, 0),
	GOOP_CENTER | GOOP_TOP: Vector2(1, 0),
	GOOP_CENTER | GOOP_LEFT: Vector2(2, 0),
	GOOP_CENTER | GOOP_LEFT | GOOP_TOP: Vector2(0, 1),
	GOOP_TOPLEFT: Vector2(0, 0),
	GOOP_TOPLEFT | GOOP_TOP: Vector2(1, 1),
	GOOP_TOPLEFT | GOOP_LEFT: Vector2(2, 1),
	GOOP_TOPLEFT | GOOP_LEFT | GOOP_TOP: Vector2(0, 2),
	GOOP_TOPLEFT | GOOP_CENTER: Vector2(0, 0),
	GOOP_TOPLEFT | GOOP_CENTER | GOOP_TOP: Vector2(1, 2),
	GOOP_TOPLEFT | GOOP_CENTER | GOOP_LEFT: Vector2(2, 2),
	GOOP_TOPLEFT | GOOP_CENTER | GOOP_LEFT | GOOP_TOP: Vector2(0, 3),
}

## The parent tilemap's tile ID for goopless blocks
export (int) var no_goop_tile_index: int setget set_block_tile_index

## The parent tilemap's tile ID for partially goopy blocks
export (int) var some_goop_tile_index: int setget set_some_goop_tile_index

## The parent tilemap's tile ID for goopy blocks
export (int) var all_goop_tile_index: int setget set_goop_tile_index

## the corner tilemap's tile ID for goopless/partially goopy/goopy corner covers
export (int) var corner_tile_index: int

## An editor toggle which manually applies autotiling.
##
## Godot has no way of automatically reacting to GridMap/TileMap changes. See Godot #11855
## https://github.com/godotengine/godot/issues/11855
export (bool) var _autotile: bool setget autotile

## key: an enum from TileTypes
## value: a tile index from the parent tilemap for the specified enum, as defined by no_goop_tile_index,
## 	some_goop_tile_index and all_goop_tile_index
var _tile_indexes_by_type := {}

## key: a tile index from the parent tilemap
## value: an enum from TileTypes corresponding to the specified tile index, as defined by no_goop_tile_index,
## 	some_goop_tile_index and all_goop_tile_index
var _tile_types_by_index := {}

## indexes of cake tiles in the parent tilemap, both goopy and goopless
var _cake_indexes := []

## indexes of goopy cake tiles in the parent tilemap, both partially and fully goopy
var _goop_indexes := []

## a tilemap with goopy/goopless overworld cakes which we should autotile
onready var _tile_map := get_parent()

## A tilemap of corner covers which cover the corners of an overworld tilemap.
##
## Without this tilemap, a simple 16-tile autotiling would result in tiny holes at the corners of a filled in area.
## This tilemap fills in the holes.
onready var _corner_map := $"../CornerMap"

func _ready() -> void:
	_autotile_corner_tiles()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


## Autotiles tiles with goop.
##
## The goop autotiling involves multiple cell types and cannot be handled by Godot's built-in autotiling.
## Instead of configuring the autotiling behavior with the TileSet's autotile bitmask, it is configured with several
## dictionary constants defined in this script.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'Autotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map or not _corner_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_autotile_ground_tiles()
	_autotile_corner_tiles()


func set_block_tile_index(new_block_tile_index: int) -> void:
	no_goop_tile_index = new_block_tile_index
	_refresh_tile_indexes()


func set_some_goop_tile_index(new_some_goop_tile_index: int) -> void:
	some_goop_tile_index = new_some_goop_tile_index
	_refresh_tile_indexes()


func set_goop_tile_index(new_goop_tile_index: int) -> void:
	all_goop_tile_index = new_goop_tile_index
	_refresh_tile_indexes()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()
	_corner_map = $"../CornerMap"


## Refreshes our various internal helper fields.
##
## The goopy overworld tiler uses internal helper fields which depend on the 'tile_index' export fields. This
## function initializes the internal helper fields when the tiler is initialized or when the export fields change.
func _refresh_tile_indexes() -> void:
	_tile_indexes_by_type = {
		TileTypes.NO_GOOP: no_goop_tile_index,
		TileTypes.SOME_GOOP: some_goop_tile_index,
		TileTypes.ALL_GOOP: all_goop_tile_index,
	}
	_tile_types_by_index = {
		no_goop_tile_index: TileTypes.NO_GOOP,
		some_goop_tile_index: TileTypes.SOME_GOOP,
		all_goop_tile_index: TileTypes.ALL_GOOP,
	}
	_cake_indexes = [no_goop_tile_index, some_goop_tile_index, all_goop_tile_index]
	_goop_indexes = [some_goop_tile_index, all_goop_tile_index]


## Autotiles all cake tiles in the ground map.
func _autotile_ground_tiles() -> void:
	for cell in _tile_map.get_used_cells():
		match _tile_types_by_index.get(_tile_map.get_cellv(cell)):
			TileTypes.NO_GOOP, TileTypes.SOME_GOOP, TileTypes.ALL_GOOP: _autotile_ground_tile(cell)


## Autotiles the cake tile at the specified coordinates.
func _autotile_ground_tile(cell: Vector2) -> void:
	var adjacencies := _adjacencies(cell)
	if adjacencies & GOOP_CENTER == GOOP_CENTER:
		# autotile a goopy cake tile
		if NO_GOOP_AUTOTILE_COORDS_BY_BINDING.has(adjacencies):
			_set_cell_autotile_coord(cell, NO_GOOP_AUTOTILE_COORDS_BY_BINDING[adjacencies])
	else:
		# autotile an goopless cake tile
		if NO_GOOP_AUTOTILE_COORDS_BY_BINDING.has(adjacencies & CAKE_ALL):
			_set_cell_autotile_coord(cell, NO_GOOP_AUTOTILE_COORDS_BY_BINDING[adjacencies & CAKE_ALL])


## Autotiles all corner covers in the corner map.
func _autotile_corner_tiles() -> void:
	_corner_map.clear()
	for cell in _tile_map.get_used_cells():
		match _tile_types_by_index.get(_tile_map.get_cellv(cell)):
			TileTypes.NO_GOOP, TileTypes.SOME_GOOP, TileTypes.ALL_GOOP: _autotile_corner_tile(cell)


## Autotiles the corner cover at the specified coordinates.
func _autotile_corner_tile(cell: Vector2) -> void:
	var corner_cover_adjacencies := _corner_cover_adjacencies(cell)
	if CORNER_COVERS_BY_BINDING.has(corner_cover_adjacencies):
		# add a corner cover for this cake tile
		_set_corner_cover_autotile_coord(cell, CORNER_COVERS_BY_BINDING[corner_cover_adjacencies])


## Updates the autotile coordinate for a TileMap cell.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be updated.
##
## 	'binding_value': An array of two items defining the tile and autotile coordinates to assign:
## 		[0]: (int) tile id to assign
## 		[1]: (Array, Vector2) list of possible autotile coordinates to assign
func _set_cell_autotile_coord(cell: Vector2, binding_value: Array) -> void:
	var tile: int = _tile_indexes_by_type[binding_value[0]]
	var autotile_coord: Vector2 = Utils.rand_value(binding_value[1])
	var flip_x: bool = _tile_map.is_cell_x_flipped(cell.x, cell.y)
	var flip_y: bool = _tile_map.is_cell_y_flipped(cell.x, cell.y)
	var transpose: bool = _tile_map.is_cell_transposed(cell.x, cell.y)
	_tile_map.set_cellv(cell, tile, flip_x, flip_y, transpose, autotile_coord)


## Updates the corner cover for a TileMap cell.
##
## Parameters:
## 	'cell': The TileMap coordinates of the corner cover to be updated.
##
## 	'autotile_coord': autotile coordinates of the corner cover to assign
func _set_corner_cover_autotile_coord(cell: Vector2, autotile_coord: Vector2) -> void:
	var tile: int = corner_tile_index
	var flip_x: bool = _tile_map.is_cell_x_flipped(cell.x, cell.y)
	var flip_y: bool = _tile_map.is_cell_y_flipped(cell.x, cell.y)
	var transpose: bool = _tile_map.is_cell_transposed(cell.x, cell.y)
	_corner_map.set_cellv(cell, tile, flip_x, flip_y, transpose, autotile_coord)


## Calculates which of the five adjacent cells have blocks or goop.
##
## This includes the current block and its four neighbors.
##
## Parameters:
## 	'cell': The TileMap coordinates of the cell to be analyzed.
##
## Returns:
## 	An int bitmask of cell directions containing blocks (CAKE_TOP, CAKE_BOTTOM, CAKE_LEFT, CAKE_RIGHT) or goop
## 	(GOOP_CENTER, GOOP_TOP, GOOP_BOTTOM, GOOP_LEFT, GOOP_RIGHT)
func _adjacencies(cell: Vector2) -> int:
	var binding := 0
	binding |= CAKE_TOP if _tile_map.get_cellv(cell + Vector2.UP) in _cake_indexes else 0
	binding |= CAKE_BOTTOM if _tile_map.get_cellv(cell + Vector2.DOWN) in _cake_indexes else 0
	binding |= CAKE_LEFT if _tile_map.get_cellv(cell + Vector2.LEFT) in _cake_indexes else 0
	binding |= CAKE_RIGHT if _tile_map.get_cellv(cell + Vector2.RIGHT) in _cake_indexes else 0
	binding |= GOOP_CENTER if _tile_map.get_cellv(cell) in _goop_indexes else 0
	binding |= GOOP_TOP if _tile_map.get_cellv(cell + Vector2.UP) in _goop_indexes else 0
	binding |= GOOP_BOTTOM if _tile_map.get_cellv(cell + Vector2.DOWN) in _goop_indexes else 0
	binding |= GOOP_LEFT if _tile_map.get_cellv(cell + Vector2.LEFT) in _goop_indexes else 0
	binding |= GOOP_RIGHT if _tile_map.get_cellv(cell + Vector2.RIGHT) in _goop_indexes else 0
	return binding


## Calculates which of the four cells in the up/left direction have goop.
##
## This includes the current block, its top neighbor, its left neighbor, and its topleft diagonal neighbor.
##
## Returns:
## 	An int bitmask of cell directions containing goop (GOOP_CENTER, GOOP_TOP, GOOP_LEFT, GOOP_TOPLEFT)
func _corner_cover_adjacencies(cell: Vector2) -> int:
	var binding := -1
	if _tile_map.get_cellv(cell) != TileMap.INVALID_CELL \
			and _tile_map.get_cellv(cell + Vector2.UP) != TileMap.INVALID_CELL \
			and _tile_map.get_cellv(cell + Vector2.LEFT) != TileMap.INVALID_CELL \
			and _tile_map.get_cellv(cell + Vector2.UP + Vector2.LEFT) != TileMap.INVALID_CELL:
		binding = 0
		binding |= GOOP_CENTER if _tile_map.get_cellv(cell) in _goop_indexes else 0
		binding |= GOOP_TOP if _tile_map.get_cellv(cell + Vector2.UP) in _goop_indexes else 0
		binding |= GOOP_LEFT if _tile_map.get_cellv(cell + Vector2.LEFT) in _goop_indexes else 0
		binding |= GOOP_TOPLEFT if _tile_map.get_cellv(cell + Vector2.UP + Vector2.LEFT) in _goop_indexes else 0
	return binding
