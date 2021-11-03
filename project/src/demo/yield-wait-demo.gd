extends Control

export (PackedScene) var FlasherScene: PackedScene

onready var _flashers := $Flashers

func _on_Create_pressed() -> void:
	var flasher: Control = FlasherScene.instance()
	flasher.rect_min_size = Vector2(100, 100)
	_flashers.add_child(flasher)


func _on_Delete_pressed() -> void:
	if _flashers.get_child_count() == 0:
		return
	
	var flasher := _flashers.get_child(_flashers.get_child_count() - 1)
	flasher.queue_free()
