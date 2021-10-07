extends Sprite

export (NodePath) var creature_visuals_path: NodePath
export var source_body_path: NodePath

# This dictates the size of the viewport used for the "snapshot".
export var source_image_size : Vector2

onready var _body_scene: PackedScene = preload("res://src/main/world/creature/Body.tscn")
onready var _creature_visuals: CreatureVisuals = get_node(creature_visuals_path)
onready var _source_body: Body = get_node(source_body_path)

func _on_SnapshotTimer_timeout() -> void:
	var viewport_container = ViewportContainer.new()
	viewport_container.set_size(source_image_size)
	add_child(viewport_container)

	# Additional optimizations can be made on the viewport's properties,
	# depending on the use case.
	var viewport = Viewport.new()
	viewport.transparent_bg = true
	viewport.set_size(source_image_size)
	viewport_container.add_child(viewport)

	var temp_body = _body_scene.instance()
	temp_body.copy_from(_source_body)
	viewport.add_child(temp_body)
	temp_body.creature_visuals_path = temp_body.get_path_to(_creature_visuals)

	# Need to yield here when "snapshotting" the first frame of a scene.
	# As described in issue https://github.com/godotengine/godot/issues/19239
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	var image = viewport.get_texture().get_data()
	image.flip_y()
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	set_texture(texture)

	# Don't need any of this any longer!
	viewport_container.queue_free()
	
	_source_body.visible = false
