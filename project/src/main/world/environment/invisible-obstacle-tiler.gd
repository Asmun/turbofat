tool
extends Node
## Refreshes the position of invisible obstacles which keep the player from stepping off the edge.
##
## These invisible obstacles are placed wherever there's an 'unwalkable cell' like a cliff next to a 'walkable cell'
## like a patch of ground.

export (NodePath) var ground_map_path: NodePath

## the tile index in this tilemap which should be used to make tiles impassable
export (int) var impassable_tile_index := -1

## tilemap containing data on which cells are walkable
onready var _ground_map: TileMap = get_node(ground_map_path)

## tilemap containing obstacles
onready var _tile_map: TileMap = get_parent()

## An editor toggle which manually applies autotiling.
##
## Godot has no way of automatically reacting to GridMap/TileMap changes. See Godot #11855
## https://github.com/godotengine/godot/issues/11855
export (bool) var _autotile: bool setget autotile

## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


## Refreshes the position of invisible obstacles which keep the player from stepping off the edge.
##
## These invisible obstacles are placed wherever there's an 'unwalkable cell' like a cliff next to a 'walkable cell'
## like a patch of ground.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'Autotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	# remove all invisible obstacles
	for cell_obj in _tile_map.get_used_cells_by_id(impassable_tile_index):
		var cell: Vector2 = cell_obj
		_tile_map.set_cellv(cell, TileMap.INVALID_CELL)
	
	# calculate empty unwalkable cells which are adjacent to walkable cells
	var unwalkable_cells := {}
	for cell_obj in _ground_map.get_used_cells():
		var cell: Vector2 = cell_obj
		for neighbor_x in range(cell.x - 1, cell.x + 2):
			for neighbor_y in range(cell.y - 1, cell.y + 2):
				if unwalkable_cells.has(Vector2(neighbor_x, neighbor_y)):
					# already added an entry to the map
					continue
				
				if _ground_map.get_cell(neighbor_x, neighbor_y) != TileMap.INVALID_CELL:
					# walkable; the ground map has terrain at that cell
					continue
				
				if _tile_map.get_cell(neighbor_x, neighbor_y) != TileMap.INVALID_CELL:
					# the obstacle map already has an obstacle at that cell; don't overwrite it
					continue
				
				unwalkable_cells[Vector2(neighbor_x, neighbor_y)] = true
	
	# place an invisible obstacle on each unwalkable cell
	for unwalkable_cell_obj in unwalkable_cells:
		var unwalkable_cell: Vector2 = unwalkable_cell_obj
		_tile_map.set_cellv(unwalkable_cell, impassable_tile_index)


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()
