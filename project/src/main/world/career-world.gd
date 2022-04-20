tool
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles in the career mode's world.

## horizontal distance to maintain when placing the player and the sensei
const X_DIST_BETWEEN_PLAYER_AND_SENSEI := 180

## horizontal distance to maintain when placing customers
const X_DIST_BETWEEN_CUSTOMERS := 200

## vertical distance separating the customers from the player's path
const Y_DIST_BETWEEN_CUSTOMERS_AND_PATH := 80

## List of moods customers have when their level is chosen.
const MOODS_COMMON := [Creatures.Mood.SMILE0, Creatures.Mood.SMILE1, Creatures.Mood.WAVE0, Creatures.Mood.WAVE1]
const MOODS_UNCOMMON := [Creatures.Mood.LAUGH0, Creatures.Mood.LAUGH1, Creatures.Mood.LOVE1, Creatures.Mood.AWKWARD0]
const MOODS_RARE := [Creatures.Mood.AWKWARD1, Creatures.Mood.SIGH0, Creatures.Mood.SWEAT0, Creatures.Mood.THINK0]

## The path to the scene resource defining creatures and obstacles for career regions which do not specify an
## environment, or regions which specify an invalid environment
const DEFAULT_ENVIRONMENT_PATH := "res://src/main/world/environment/marsh/MarshEnvironment.tscn"

## key: (String) an environment name which appears in the json definitions
## value: (String) The path to the scene resource defining creatures and obstacles which appear in
## 	that environment
const ENVIRONMENT_PATH_BY_NAME := {
	"lemon": "res://src/main/world/environment/lemon/LemonEnvironment.tscn",
	"marsh": "res://src/main/world/environment/marsh/MarshEnvironment.tscn",
}

export (PackedScene) var MileMarkerScene: PackedScene

## Creature instances for 'level creatures', chefs and customers associated with each level.
var _level_creatures := []

## The path of the environment scene current
var _loaded_environment_path: String

## The index of the focused level creature. This is usually the same as the index of the focused level button, but not
## always. Sometimes two level buttons correspond to the same level creature.
var _focused_level_creature_index := -1

## path on which which the player and sensei are placed
onready var _player_path2d: Path2D

onready var _camera: Camera2D = $Camera

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_fill_environment_scene()


# Loads the cutscene's environment, replacing the current one in the scene tree.
func prepare_environment_resource() -> void:
	_loaded_environment_path = _career_environment_path()
	EnvironmentScene = load(_loaded_environment_path)


## Refreshes the environment and creatures based on the player's progress through career mode.
##
## Parameters:
## 	'pickable_career_levels': An list of CareerLevel instances the player is allowed to select. This affects how
## 		many level creatures show up.
func refresh_from_career_data(pickable_career_levels: Array) -> void:
	if _loaded_environment_path != _career_environment_path():
		prepare_environment_resource()
		refresh_environment_scene()
		_fill_environment_scene()
	
	for creature in _level_creatures:
		if creature.is_in_group("customers"):
			creature.remove_from_group("customers")
	
	if PlayerData.career.level_choice_count() == 1:
		_refresh_single_level_creatures(pickable_career_levels)
	else:
		_refresh_multi_level_creatures(pickable_career_levels)
	
	_move_camera()


func get_visible_customers(level_index: int) -> Array:
	var result: Array
	if PlayerData.career.level_choice_count() == 1:
		# only one level choice; return all visible customers
		result = get_tree().get_nodes_in_group("customers")
	else:
		# multiple level choices; return the appropriate level creature if they're a customer and not a chef
		if _level_creatures[level_index].is_in_group("customers"):
			result = [_level_creatures[level_index]]
	return result


## Adds and rearranges environment objects like the player, sensei, level creatures, mile markers, and camera.
func _fill_environment_scene() -> void:
	_level_creatures.clear()
	
	if not _find_player():
		var player := overworld_environment.add_creature()
		player.creature_id = CreatureLibrary.PLAYER_ID
	
	if not _find_sensei():
		var sensei := overworld_environment.add_creature()
		sensei.creature_id = CreatureLibrary.SENSEI_ID
	
	_player_path2d = overworld_environment.get_node("PlayerPath")
	
	var percent := _distance_percent()
	_move_player_to_path(percent)
	_move_sensei_to_path(percent)
	
	for _i in range(3):
		_add_level_creature(percent)
	
	_add_mile_markers_to_path()
	_move_camera()


func _career_environment_path() -> String:
	var environment_name := PlayerData.career.current_region().overworld_environment_name
	return ENVIRONMENT_PATH_BY_NAME.get(environment_name, DEFAULT_ENVIRONMENT_PATH)


## Updates the creature/chef IDs for a boss/intro level, where the player only has one choice.
##
## For a boss/intro level, we show the chef and up to two customers. If a boss/intro level has a designed chef, the
## chef is in the middle.
func _refresh_single_level_creatures(pickable_career_levels: Array) -> void:
	var career_level: CareerLevel = pickable_career_levels[0]
	var remaining_customers := career_level.customer_ids.duplicate()
	var remaining_creature_indexes := [1, 0, 2]
	if career_level.chef_id:
		# if there's a chef_id, add the chef to the middle
		var creature: Creature = _level_creatures[remaining_creature_indexes.pop_front()]
		creature.creature_id = career_level.chef_id
	while remaining_creature_indexes:
		# assign/randomize the remaining customer appearances
		var creature: Creature = _level_creatures[remaining_creature_indexes.pop_front()]
		creature.add_to_group("customers")
		if remaining_customers:
			# assign the next customer
			creature.creature_id = remaining_customers.pop_front()
		else:
			# randomize the customer
			creature.creature_def = CreatureLoader.random_def()
	
	_hide_duplicate_creatures()


## Updates the creature/chef IDs for a non-boss level, where the player has three choices.
##
## For a non-boss/non-intro level, we show one creature for each of the different levels. We show the chef if the
## level has a designated chef, otherwise we show the level's customer.
func _refresh_multi_level_creatures(pickable_career_levels: Array) -> void:
	for i in range(pickable_career_levels.size()):
		var career_level: CareerLevel = pickable_career_levels[i]
		var creature: Creature = _level_creatures[i]
		if career_level.chef_id:
			# if there's a chef_id, show the level's chef
			creature.creature_id = career_level.chef_id
		elif career_level.customer_ids:
			# if there's a customer_id, show the level's customer
			creature.add_to_group("customers")
			creature.creature_id = career_level.customer_ids[0]
		else:
			# randomize the customer
			creature.add_to_group("customers")
			creature.creature_def = CreatureLoader.random_def()
	
	_hide_duplicate_creatures()


## Hides any duplicate creatures, if the same creature is visible for multiple levels.
##
## If two levels have the same chef or the same customer, we only show the rightmost duplicated creature.
func _hide_duplicate_creatures() -> void:
	var creatures_by_id := {}
	for creature_obj in _level_creatures:
		var creature: Creature = creature_obj
		creature.visible = true
		if creatures_by_id.has(creature.creature_id):
			creatures_by_id[creature.creature_id].visible = false
		creatures_by_id[creature.creature_id] = creature


## Calculates how far to the right the player should be positioned.
##
## Returns:
## 	A number in the range [0.0, 1.0] describing how far to the right the customer should be positioned.
func _distance_percent() -> float:
	var percent: float
	var region := PlayerData.career.current_region()
	if region.length == CareerData.MAX_DISTANCE_TRAVELLED:
		# for 'endless regions' just put them somewhere arbitrary
		percent = randf()
	else:
		# for typicalregions, move them to the right gradually as they progress
		percent = CareerLevelLibrary.region_weight_for_distance(region, PlayerData.career.distance_travelled)
	return percent


## Adds a 'level creature', a chef or customer associated with a level.
##
## Parameters:
##     'percent': A number in the range [0.0, 1.0] describing how far to the right the creature should be positioned.
func _add_level_creature(percent: float) -> void:
	var creature := overworld_environment.add_creature()
	_level_creatures.append(creature)
	
	var mood: int
	if randf() < 0.8:
		mood = Utils.rand_value(MOODS_COMMON)
	elif randf() < 0.8:
		mood = Utils.rand_value(MOODS_UNCOMMON)
	else:
		mood = Utils.rand_value(MOODS_RARE)
	creature.set_meta("mood_when_hovered", mood)
	
	# Determine the level creature's position. The creature is positioned slightly above _player_path2d.
	var creature_x_range := _camera_x_range()
	creature.position.x = lerp(creature_x_range.min_value, creature_x_range.max_value, percent) \
			+ X_DIST_BETWEEN_CUSTOMERS * (_level_creatures.size() - 2)
	creature.position.y = _player_path2d_y(creature.position.x)
	
	match _level_creatures.size():
		1:
			# leftmost level creature faces right
			creature.orientation = Creatures.SOUTHEAST
			creature.position.y -= Y_DIST_BETWEEN_CUSTOMERS_AND_PATH * 0.4
		2:
			# middle level creature faces right
			creature.orientation = Creatures.SOUTHEAST
			creature.position.y -= Y_DIST_BETWEEN_CUSTOMERS_AND_PATH
		_:
			# rightmost level creature faces left
			creature.orientation = Creatures.SOUTHWEST
			creature.position.y -= Y_DIST_BETWEEN_CUSTOMERS_AND_PATH * 0.4


## Moves the player creature to a point along _player_path2d.
##
## Parameters:
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the player should be positioned.
func _move_player_to_path(percent: float) -> void:
	var player := _find_player()
	var player_range := _camera_x_range()
	player.position.x = lerp(player_range.min_value, player_range.max_value, percent) \
			+ X_DIST_BETWEEN_PLAYER_AND_SENSEI / 2.0
	player.position.y = _player_path2d_y(player.position.x)


## Moves the sensei creature to a point along _player_path2d.
##
## Parameters:
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the sensei should be positioned.
func _move_sensei_to_path(percent: float) -> void:
	var sensei := _find_sensei()
	var sensei_range := _camera_x_range()
	sensei.position.x = lerp(sensei_range.min_value, sensei_range.max_value, percent) \
			- X_DIST_BETWEEN_PLAYER_AND_SENSEI / 2.0
	sensei.position.y = _player_path2d_y(sensei.position.x)


## Moves the camera so all creatures are visible.
func _move_camera() -> void:
	var creatures := []
	creatures.append(_find_sensei())
	creatures.append(_find_player())
	creatures.append_array(_level_creatures)
	_camera.zoom_in_on_creatures(creatures)


## Places mile markers along the path to indicate the distance of each customer.
##
## Mile markers are positioned relative to the _customers, not to the _player_path2d. Customers must be placed first.
func _add_mile_markers_to_path() -> void:
	# Calculate the values of the left and right mile marker
	var left_num: int
	var right_num: int
	var curr_region: CareerRegion = PlayerData.career.current_region()
	if curr_region.length == CareerData.MAX_DISTANCE_TRAVELLED:
		# In the final (endless) region, numbers count up from 0-99, and then reset back to 0
		right_num = PlayerData.career.distance_travelled - curr_region.distance
		left_num = right_num - PlayerData.career.distance_penalties()[0]
		left_num %= 100
		right_num %= 100
	else:
		# In most regions, numbers count down to 0. 0 is a 'boss level'
		right_num = curr_region.length + curr_region.distance - 1 - PlayerData.career.distance_travelled
		left_num = right_num + PlayerData.career.distance_penalties()[0]
	
	_add_mile_marker(_level_creatures[0].position + Vector2(-100, 20), left_num)
	if right_num != left_num:
		# Only place the right mile marker if it has a different value. We don't want two redundant mile markers for
		# boss levels or when starting a new career session.
		_add_mile_marker(_level_creatures[2].position + Vector2(100, 20), right_num)


## Places a mile marker at the specified position.
func _add_mile_marker(position: Vector2, mile_number: int) -> void:
		var marker: MileMarker = MileMarkerScene.instance()
		overworld_environment.add_obstacle(marker)
		
		marker.position = position
		marker.mile_number = mile_number


## Calculates and returns the leftmost/rightmost camera x position within the _player_path2d.
##
## The _player_path2d includes a range of x values where creatures can be placed, but the range of camera x values is
## slightly narrower than this.
##
## Returns:
## 	A dictionary defining 'min_value' and 'max_value' float values for the leftmost/rightmost camera x position
## 		within the _player_path2d
func _camera_x_range() -> Dictionary:
	var result := {}
	result.min_value = _player_path2d_point(0).x
	result.max_value = result.min_value
	for i in range(1, _player_path2d.curve.get_point_count()):
		var point_x := _player_path2d_point(i).x
		result.min_value = min(result.min_value, point_x)
		result.max_value = max(result.max_value, point_x)
	
	result.min_value += X_DIST_BETWEEN_CUSTOMERS
	result.max_value -= X_DIST_BETWEEN_CUSTOMERS
	
	return result


func _find_player() -> Creature:
	return overworld_environment.find_creature(CreatureLibrary.PLAYER_ID)


func _find_sensei() -> Creature:
	return overworld_environment.find_creature(CreatureLibrary.SENSEI_ID)


## Returns the absolute position of the vertex idx in _player_path2d.
func _player_path2d_point(idx: int) -> Vector2:
	return _player_path2d.curve.get_point_position(idx) + _player_path2d.position


## Returns the y coordinate corresponding to the specified x coordinate in _player_path2d.
##
## This assumes _player_path2d's vertices are arranged from left to right.
func _player_path2d_y(path2d_x: float) -> float:
	var path2d_y := _player_path2d_point(_player_path2d.curve.get_point_count() - 1).y
	
	for i in range(1, _player_path2d.curve.get_point_count()):
		var left_point := _player_path2d_point(i - 1)
		var right_point := _player_path2d_point(i)
		if right_point.x >= path2d_x:
			var f := inverse_lerp(left_point.x, right_point.x, path2d_x)
			path2d_y = lerp(left_point.y, right_point.y, f)
			break
	
	return path2d_y


## When a new level button is selected, the player/sensei orient towards it.
func _on_LevelSelect_level_button_focused(button_index: int) -> void:
	var button_count := PlayerData.career.level_choice_count()
	
	var old_focused_level_creature_index := _focused_level_creature_index
	_focused_level_creature_index = -1
	if _level_creatures[button_index].visible:
		_focused_level_creature_index = button_index
	else:
		for i in range(2):
			if _level_creatures[i].creature_id == _level_creatures[button_index].creature_id \
					and _level_creatures[i].visible:
				_focused_level_creature_index = i
				break
	
	if _focused_level_creature_index == -1:
		# can't find a visible level creature
		pass
	elif _focused_level_creature_index == old_focused_level_creature_index:
		# Selecting a new button focused the same creature as before. This can happen if two buttons have the same
		# level creature.
		pass
	else:
		var level_creature_x := inverse_lerp(0, button_count - 1, _focused_level_creature_index)
		
		# turn the player and sensei towards the level creature
		var player := _find_player()
		player.orientation = Creatures.SOUTHEAST if level_creature_x >= 0.7 else Creatures.SOUTHWEST
		var sensei := _find_sensei()
		sensei.orientation = Creatures.SOUTHWEST if level_creature_x <= 0.3 else Creatures.SOUTHEAST
		
		# make the level creature emote
		if PlayerData.career.level_choice_count() > 1:
			for i in range(_level_creatures.size()):
				var creature: Creature = _level_creatures[i]
				if i == _focused_level_creature_index and creature.has_meta("mood_when_hovered"):
					creature.play_mood(creature.get_meta("mood_when_hovered"))
				else:
					creature.play_mood(Creatures.Mood.DEFAULT)
