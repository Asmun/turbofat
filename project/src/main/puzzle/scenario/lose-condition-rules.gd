class_name LoseConditionRules
"""
How the player loses. The player usually loses if they top out a certain number of times, but some scenarios might
have different rules.
"""

# by default, the player loses if they top out three times
var top_out := 3

# if 'true', the finish screen is shown when the player loses
var finish_on_lose := false

func from_json_string_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("top_out"): top_out = rules.int_value()
	if rules.has("finish_on_lose"): finish_on_lose = true
