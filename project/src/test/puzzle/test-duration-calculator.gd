extends "res://addons/gut/test.gd"
"""
Unit test demonstrating duration calculation logic.
"""

var _duration_calculator := DurationCalculator.new()
var _settings: LevelSettings

func before_each() -> void:
	_settings = LevelSettings.new()


func test_endless_level() -> void:
	assert_almost_eq(_duration_calculator.duration(_settings), 600.0, 10.0)


func test_score() -> void:
	_settings.finish_condition.set_milestone(Milestone.SCORE, 200)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 177.0, 10.0)


func test_score_high_value() -> void:
	_settings.finish_condition.set_milestone(Milestone.SCORE, 1000)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 889.0, 10.0)


func test_score_high_difficulty() -> void:
	_settings.speed.set_start_speed("AA")
	_settings.finish_condition.set_milestone(Milestone.SCORE, 200)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 23.0, 10.0)


func test_lines() -> void:
	_settings.finish_condition.set_milestone(Milestone.LINES, 20)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 150.0, 10.0)


func test_lines_high_value() -> void:
	_settings.finish_condition.set_milestone(Milestone.LINES, 100)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 750.0, 10.0)


func test_lines_high_difficulty() -> void:
	_settings.speed.set_start_speed("AA")
	_settings.finish_condition.set_milestone(Milestone.LINES, 20)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 55.0, 10.0)


func test_time_over() -> void:
	_settings.finish_condition.set_milestone(Milestone.TIME_OVER, 90.0)
	
	assert_eq(_duration_calculator.duration(_settings), 90.0)


func test_time_over_high_value() -> void:
	_settings.finish_condition.set_milestone(Milestone.TIME_OVER, 300.0)
	
	assert_eq(_duration_calculator.duration(_settings), 300.0)


func test_time_over_high_difficulty() -> void:
	_settings.speed.set_start_speed("AA")
	_settings.finish_condition.set_milestone(Milestone.TIME_OVER, 90.0)
	
	assert_eq(_duration_calculator.duration(_settings), 90.0)


func test_customers() -> void:
	_settings.finish_condition.set_milestone(Milestone.CUSTOMERS, 5)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 116.0, 10.0)


func test_customers_high_value() -> void:
	_settings.finish_condition.set_milestone(Milestone.CUSTOMERS, 25)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 562.5, 10.0)


func test_customers_high_difficulty() -> void:
	_settings.speed.set_start_speed("AA")
	_settings.finish_condition.set_milestone(Milestone.CUSTOMERS, 5)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 185.0, 10.0)


func test_master_pickup_score() -> void:
	_settings.finish_condition.set_milestone(Milestone.SCORE, 1000)
	assert_almost_eq(_duration_calculator.duration(_settings), 889.0, 10.0)
	
	_settings.rank.master_pickup_score = 800
	assert_almost_eq(_duration_calculator.duration(_settings), 177.0, 10.0)


func test_master_pickup_score_per_line() -> void:
	_settings.finish_condition.set_milestone(Milestone.SCORE, 1000)
	assert_almost_eq(_duration_calculator.duration(_settings), 889.0, 10.0)
	
	_settings.rank.master_pickup_score_per_line = 20
	assert_almost_eq(_duration_calculator.duration(_settings), 574.0, 10.0)
