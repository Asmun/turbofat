class_name Sensei
extends Creature
## Script for manipulating the sensei in the overworld.
##
## The sensei follows the player around.

## the sensei tries to keep a respectable distance from the player
const TOO_CLOSE_THRESHOLD := 140.0
const TOO_FAR_THRESHOLD := 280.0

## Cannot statically type as 'OverworldUi' because of circular reference
onready var _overworld_ui: Node = Global.get_overworld_ui()

func _ready() -> void:
	set_creature_id(CreatureLibrary.SENSEI_ID)
	$MoveTimer.connect("timeout", self, "_on_MoveTimer_timeout")


func _on_MoveTimer_timeout() -> void:
	if _overworld_ui and _overworld_ui.cutscene:
		# disable movement during cutscenes
		return
	
	if not ChattableManager.player:
		# disable movement outside free roam mode
		return
	
	var player_relative_pos: Vector2 = Global.from_iso(ChattableManager.player.position - position)
	# the sensei runs at isometric 45 degree angles to mimic the player's inputs
	var player_angle := stepify(player_relative_pos.normalized().angle(), PI / 4)
	
	var move_dir := Vector2.ZERO
	if player_relative_pos.length() > TOO_FAR_THRESHOLD:
		# if the sensei is too far from the player, they run closer
		move_dir = Vector2.RIGHT.rotated(player_angle)
	elif player_relative_pos.length() < TOO_CLOSE_THRESHOLD:
		# if the sensei is too close to the player, they run away
		move_dir = -Vector2.RIGHT.rotated(player_angle)
	
	set_non_iso_walk_direction(move_dir)
