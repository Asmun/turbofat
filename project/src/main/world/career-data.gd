class_name CareerData
## Stores current and historical data for career mode
##
## This includes the current day's data like "how much money has the player earned today" and "how far have they
## travelled today", as well as historical information like "how many days have they played" and "how much money did
## they earn three days ago"

## Emitted when the player's distance changes, particularly at the start of career mode when they're picking their
## starting distance
signal distance_travelled_changed

## The number of days worth of records which are stored.
const MAX_DAILY_HISTORY := 40

## The maximum number of days the player can progress.
const MAX_DAY := 999999

## The maximum distance the player can travel.
const MAX_DISTANCE_TRAVELLED := 999999

## The maximum number of consecutive levels the player can play in one career session.
const HOURS_PER_CAREER_DAY := 8

## The distance the player has travelled in the current career session.
var distance_travelled := 0 setget set_distance_travelled

## The distance earned from the previously completed puzzle.
var distance_earned := 0

## The number of levels played in the current career session.
var hours_passed := 0

## The amount of money earned in the current career session.
var daily_earnings := 0

## The level IDs played in the current career session. This is tracked to avoid repeating levels.
var daily_level_ids := []

## The number of days the player has completed.
var day := 0

## Array of ints for previous daily earnings. Index 0 holds the most recent data.
var prev_daily_earnings := []

## Array of ints for previous distance travelled. Index 0 holds the most recent data.
var prev_distance_travelled := []

## The furthest total distance the player has travelled in a single session.
var max_distance_travelled := 0

## Returns 'true' if the player has completed the current career mode session.
func is_day_over() -> bool:
	return hours_passed >= HOURS_PER_CAREER_DAY


func reset() -> void:
	distance_travelled = 0
	distance_earned = 0
	hours_passed = 0
	daily_earnings = 0
	daily_level_ids.clear()
	day = 0
	prev_daily_earnings.clear()
	prev_distance_travelled.clear()
	max_distance_travelled = 0
	emit_signal("distance_travelled_changed")


func from_json_dict(dict: Dictionary) -> void:
	distance_travelled = dict.get("distance_travelled", 0)
	distance_earned = dict.get("distance_earned", 0)
	hours_passed = dict.get("hours_passed", 0)
	daily_earnings = dict.get("daily_earnings", 0)
	daily_level_ids = dict.get("daily_level_ids", [])
	day = dict.get("day", 0)
	prev_daily_earnings = dict.get("prev_daily_earnings", [])
	prev_distance_travelled = dict.get("prev_distance_travelled", [])
	max_distance_travelled = dict.get("max_distance_travelled", 0)
	emit_signal("distance_travelled_changed")


func to_json_dict() -> Dictionary:
	var results := {}
	results["distance_travelled"] = distance_travelled
	results["distance_earned"] = distance_earned
	results["hours_passed"] = hours_passed
	results["daily_earnings"] = daily_earnings
	results["daily_level_ids"] = daily_level_ids
	results["day"] = day
	results["prev_daily_earnings"] = prev_daily_earnings
	results["prev_distance_travelled"] = prev_distance_travelled
	results["max_distance_travelled"] = max_distance_travelled
	return results


## Launches the next scene in career mode. Either a new level, or a cutscene/ending scene.
func push_career_trail() -> void:
	if is_day_over():
		# after the final level, we show a 'you win' screen
		SceneTransition.replace_trail("res://src/main/world/CareerWin.tscn")
	else:
		# after the 'overworld map' scene, we launch a level
		hours_passed += 1
		distance_earned = 0
		PlayerSave.save_player_data()
		CurrentLevel.push_level_trail()


## Returns 'true' if the player is current playing career mode
func is_career_mode() -> bool:
	return Global.SCENE_CAREER_MAP in Breadcrumb.trail


## Returns 'true' if the player has completed the boss level in the specified region
func is_region_cleared(region: CareerRegion) -> bool:
	return PlayerData.career.max_distance_travelled > region.distance + region.length - 1


## Returns 'true' if the current career mode distance corresponds to an uncleared boss level
func is_boss_level() -> bool:
	var result := true
	var region: CareerRegion = CareerLevelLibrary.region_for_distance(distance_travelled)
	if distance_travelled != region.distance + region.length - 1:
		# the player is not at the end of the region
		result = false
	if not region.boss_level:
		# the region has no boss level
		result = false
	if is_region_cleared(region):
		# the player has already cleared this boss level
		result = false
	return result


## Advances the player the specified distance.
##
## Even if distance_to_advance is a large number, the player's travel distance can be limited in two scenarios.
##
## 1. If they just played a non-boss level, they cannot advance past a boss level they haven't cleared.
##
## 2. If they just played a boss level, they cannot advance without meeting its success criteria.
##
## Parameters:
## 	'distance_to_advance': The maximum distance the player will advance, unless they are limited by a boss level.
##
## 	'success': 'True' if the player met the success criteria for the current level.
func advance_distance(distance_to_advance: int, success: bool) -> void:
	distance_earned = distance_to_advance
	
	if is_boss_level():
		var boss_region: CareerRegion = CareerLevelLibrary.region_for_distance(distance_travelled)
		if not success:
			# if they fail a boss level, they lose 1-2 days worth of progress
			distance_earned = -int(max(boss_region.length * rand_range(0.125, 0.25), 2))
		else:
			# if they pass a boss level, update max_distance_travelled to mark the region as cleared
			PlayerData.career.max_distance_travelled = boss_region.distance + boss_region.length
	
	var remaining_distance_earned := distance_earned
	while remaining_distance_earned != 0:
		var region: CareerRegion = CareerLevelLibrary.region_for_distance(distance_travelled)
		if distance_travelled + remaining_distance_earned > region.distance + region.length - 1:
			# player is trying to cross into the next region, constrain them to region boundaries
			
			if not is_region_cleared(region):
				# The player can't cross into the next region, they haven't cleared the boss level. Move them to the
				# end of the region, and stop any further movement.
				remaining_distance_earned = 0
				distance_travelled = region.distance + region.length - 1
			else:
				# The player can cross into the next region. Move them past the end of the region
				remaining_distance_earned -= (region.distance + region.length - distance_travelled)
				distance_travelled = region.distance + region.length
		else:
			# player isn't trying to cross regions, increment distance_travelled without constraints
			distance_travelled += remaining_distance_earned
			remaining_distance_earned = 0


## Advances the calendar day and resets all daily variables
func advance_calendar() -> void:
	prev_daily_earnings.push_front(daily_earnings)
	if prev_daily_earnings.size() > MAX_DAILY_HISTORY:
		prev_daily_earnings = prev_daily_earnings.slice(0, MAX_DAILY_HISTORY - 1)
	
	max_distance_travelled = max(max_distance_travelled, distance_travelled)
	prev_distance_travelled.push_front(distance_travelled)
	if prev_distance_travelled.size() > MAX_DAILY_HISTORY:
		prev_distance_travelled = prev_distance_travelled.slice(0, MAX_DAILY_HISTORY - 1)
	
	# Put the player at the start of their current region.
	distance_travelled = CareerLevelLibrary.region_for_distance(distance_travelled).distance
	
	distance_earned = 0
	hours_passed = 0
	daily_earnings = 0
	daily_level_ids.clear()
	day = min(day + 1, MAX_DAY)
	emit_signal("distance_travelled_changed")


func set_distance_travelled(new_distance_travelled: int) -> void:
	distance_travelled = new_distance_travelled
	emit_signal("distance_travelled_changed")
