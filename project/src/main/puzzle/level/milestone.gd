class_name Milestone
"""
Defines a goal or milestone for a puzzle, such as reaching a certain score, clearing a certain
number of lines or surviving a certain number of seconds.

Additional details are stored in the 'meta' property.
"""

enum MilestoneType {
	NONE,
	CUSTOMERS,
	LINES,
	PIECES,
	SCORE,
	TIME_OVER,
	TIME_UNDER,
}

const NONE := MilestoneType.NONE
const CUSTOMERS := MilestoneType.CUSTOMERS
const LINES := MilestoneType.LINES
const PIECES := MilestoneType.PIECES
const SCORE := MilestoneType.SCORE
const TIME_OVER := MilestoneType.TIME_OVER
const TIME_UNDER := MilestoneType.TIME_UNDER

# converts json strings into milestone types
const JSON_MILESTONE_TYPES := {
	"none": MilestoneType.NONE,
	"customers": MilestoneType.CUSTOMERS,
	"lines": MilestoneType.LINES,
	"pieces": MilestoneType.PIECES,
	"score": MilestoneType.SCORE,
	"time_over": MilestoneType.TIME_OVER,
	"time_under": MilestoneType.TIME_UNDER,
}

# an enum from Milestone.MilestoneType describing the milestone criteria (lines, score, time)
var type: int = MilestoneType.NONE

# an value describing the milestone criteria (number of lines, points, seconds)
var value := 0

"""
Initializes the milestone with a MilestoneType and value to reach, such as scoring 50 points or clearing 10 lines.

Parameters:
	'new_type': an enum from Milestone.MilestoneType describing the milestone criteria (lines, score, time)
	
	'new_value': an value describing the milestone criteria (number of lines, points, seconds)
"""
func set_milestone(new_type: int, new_value: int) -> void:
	type = new_type
	value = new_value


func from_json_dict(json: Dictionary) -> void:
	type = JSON_MILESTONE_TYPES.get(json.get("type"), MilestoneType.NONE)
	value = int(json.get("value", "0"))
	for key in json.keys():
		if not key in ["type", "value"]:
			set_meta(key, json.get(key))
