extends Panel
## A panel on the level select screen which summarizes level details.
##
## This includes details such as the level's duration, difficulty, and the player's high score.

## All calculated durations are rounded to one of these aesthetically pleasing values.
const DURATIONS := [
	10, 15, 20, 30, 45, 60,
	90, 120, 150, 180, 270, 360, 480, 600
]

var text: String setget set_text

var _duration_calculator := DurationCalculator.new()

onready var _label := $MarginContainer/Label

func _ready() -> void:
	_refresh_text()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh_text()


func _refresh_text() -> void:
	if _label:
		_label.text = text


func _update_tutorial_level_text(settings: LevelSettings) -> void:
	var new_text := ""
	if PlayerData.level_history.is_level_finished(settings.id):
		var result := PlayerData.level_history.best_result(settings.id)
		new_text += "Completed: %04d-%02d-%02d" % [
				result.timestamp["year"],
				result.timestamp["month"],
				result.timestamp["day"],
			]
	else:
		new_text += ""
	set_text(new_text)


func update_unlocked_level_text(settings: LevelSettings) -> void:
	var new_text := ""
	var difficulty_string := tr("Unknown")
	match settings.get_difficulty():
		"T", "0", "1", "2": difficulty_string = tr("Very Easy")
		"3", "4", "5", "6": difficulty_string = tr("Easy")
		"7", "8", "9", "A0", "A1": difficulty_string = tr("Normal")
		"A2", "A3", "A4": difficulty_string = tr("Hard")
		"A5", "A6", "A7", "A8", "A9", "AA", "AB", "AC", "AD": difficulty_string = tr("Very Hard")
		"AE", "AF", "F0", "F1": difficulty_string = tr("Expert")
		"FA", "FB", "FC": difficulty_string = tr("Very Expert")
		"FD", "FE", "FF", "FFF": difficulty_string = tr("Master")
	new_text += tr("Difficulty: %s") % [difficulty_string]
	new_text += "\n"
	
	var duration_string: String
	var duration: int
	if settings.finish_condition.type == Milestone.TIME_OVER:
		duration = settings.finish_condition.value
	else:
		duration = _duration_calculator.duration(settings)
		duration = DURATIONS[Utils.find_closest(DURATIONS, duration)]
	
	duration_string = StringUtils.format_duration(duration)
	
	new_text += tr("Duration: %s") % [duration_string]
	new_text += "\n"
	
	var prev_result := PlayerData.level_history.prev_result(settings.id)
	if prev_result:
		new_text += tr("New: %s") % [PoolStringArray(HighScoreTable.rank_result_row(prev_result)).join("   ")]
	new_text += "\n"
	var best_result := PlayerData.level_history.best_result(settings.id)
	if best_result:
		new_text += tr("Top: %s") % [PoolStringArray(HighScoreTable.rank_result_row(best_result)).join("   ")]
	set_text(new_text)


func _update_tutorial_world_text(ranks: Array) -> void:
	var new_text := ""
	
	# calculate the percent of tutorials which the player hasn't cleared
	var worst_rank_count := 0
	for rank in ranks:
		if RankCalculator.grade(rank) == RankCalculator.NO_GRADE:
			worst_rank_count += 1
	var progress_pct := float(ranks.size() - worst_rank_count) / ranks.size()
	
	new_text = "Tutorial progress: %.1f%%" % [100 * progress_pct]
	set_text(new_text)


func _update_world_text(ranks: Array) -> void:
	var new_text := ""
	
	# calculate the worst rank
	var worst_rank := 0.0
	for rank in ranks:
		worst_rank = max(worst_rank, rank)
	
	# count the total number of 'stars' for all of the levels
	var star_count := 0
	for rank in ranks:
		match RankCalculator.grade(rank):
			"S-": star_count += 1
			"S": star_count += 2
			"S+": star_count += 3
			"SS": star_count += 4
			"SS+": star_count += 5
			"SSS": star_count += 6
			"M": star_count += 7
	
	# calculate the percent of levels where the player's rank is already high enough to rank up
	var worst_rank_count := 0
	for rank in ranks:
		if RankCalculator.grade(worst_rank) == RankCalculator.grade(rank):
			worst_rank_count += 1
	var next_rank_pct := float(ranks.size() - worst_rank_count) / ranks.size()
	
	new_text += "Overall grade: %s" % [RankCalculator.grade(worst_rank)]
	if RankCalculator.grade(worst_rank) != RankCalculator.HIGHEST_GRADE:
		new_text += "\nProgress towards next grade: %.1f%%" % [100 * next_rank_pct]
	if star_count > 0:
		new_text += "\nTotal stars: %s" % [star_count]
	set_text(new_text)


## When an unlocked level is selected, we display some statistics for that level.
func _on_LevelButtons_unlocked_level_selected(_level_lock: LevelLock, settings: LevelSettings) -> void:
	if settings.other.tutorial:
		_update_tutorial_level_text(settings)
	else:
		update_unlocked_level_text(settings)


## When a locked level is selected, we clear out the info panel.
func _on_LevelButtons_locked_level_selected(_level_lock: LevelLock, _settings: LevelSettings) -> void:
	set_text("")


## When the 'overall' button is selected, we display statistics for all of the levels.
func _on_LevelButtons_overall_selected(world_id: String, ranks: Array) -> void:
	if world_id == LevelLibrary.TUTORIAL_WORLD_ID:
		_update_tutorial_world_text(ranks)
	else:
		_update_world_text(ranks)
