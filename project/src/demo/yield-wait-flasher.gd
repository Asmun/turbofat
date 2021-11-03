extends ColorRect
"""
Flashes ten times, relying on a yield call instead of a more sensible design

This class is intended to demonstrate potential issues with certain kinds of yield calls. There are more sensible ways
to write this code without a yield call, but it's not intended to be sensible.
"""

export (float) var duration_sec := 3.0

func _ready() -> void:
	call_deferred("_flash")


func _flash() -> void:
	for _i in range(10):
		yield(Global.yield_wait(duration_sec, self), "completed")
		color = Color.black if color == Color.white else Color.white
