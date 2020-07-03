extends Node
"""
Handles gravity, hard drops, and soft drops for the player's active piece.
"""

signal hard_dropped
signal soft_dropped

export (NodePath) var input_path: NodePath
export (NodePath) var piece_mover_path: NodePath

# 'true' if the player hard dropped the piece this frame
var did_hard_drop: bool

var _gravity_pause_frames := 0

onready var input: PieceInput = get_node(input_path)
onready var piece_mover: PieceMover = get_node(piece_mover_path)

func _physics_process(_delta: float) -> void:
	did_hard_drop = false


func apply_hard_drop_input(piece: ActivePiece) -> void:
	if not input.is_hard_drop_just_pressed() and not input.is_hard_drop_das_active():
		return
	
	piece.reset_target()
	while piece.can_move_to_target():
		piece.move_to_target()
		piece.target_pos.y += 1
	# lock piece
	piece.lock = PieceSpeeds.current_speed.lock_delay
	emit_signal("hard_dropped")
	did_hard_drop = true


"""
Increments the piece's gravity. A piece will fall once its accumulated gravity exceeds a certain threshold.
"""
func apply_gravity(piece: ActivePiece) -> void:
	if _gravity_pause_frames > 0:
		_gravity_pause_frames -= 1
	else:
		if input.is_soft_drop_pressed():
			# soft drop
			piece.gravity += int(max(PieceSpeeds.DROP_G, PieceSpeeds.current_speed.gravity))
			emit_signal("soft_dropped")
		else:
			piece.gravity += PieceSpeeds.current_speed.gravity
		
		while piece.gravity >= PieceSpeeds.G:
			piece.gravity -= PieceSpeeds.G
			piece.reset_target()
			piece.target_pos.y = piece.pos.y + 1
			if piece.can_move_to_target():
				piece.move_to_target()
			else:
				break
			
			piece_mover.attempt_mid_drop_movement(piece)


"""
Squish moving pauses gravity for a moment.

This allows players to squish and slide a piece before it drops, even at 20G.
"""
func _on_Squisher_squish_moved(_piece: ActivePiece, _old_pos: Vector2) -> void:
	_gravity_pause_frames = PieceSpeeds.SQUISH_FRAMES