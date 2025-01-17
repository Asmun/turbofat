extends Node
## Handles horizontal movement for the player's active piece.

# warning-ignore:unused_signal
signal initial_rotated_ccw
# warning-ignore:unused_signal
signal initial_rotated_cw
# warning-ignore:unused_signal
signal initial_rotated_180

# warning-ignore:unused_signal
signal rotated_ccw
# warning-ignore:unused_signal
signal rotated_cw
# warning-ignore:unused_signal
signal rotated_180

export (NodePath) var input_path: NodePath

onready var input: PieceInput = get_node(input_path)

func apply_initial_rotate_input(piece: ActivePiece) -> void:
	if not input.is_cw_pressed() and not input.is_ccw_pressed():
		return
	
	var rotation_signal: String
	
	if input.is_cw_pressed() and input.is_ccw_pressed():
		rotation_signal = "initial_rotated_180"
	elif input.is_cw_pressed():
		rotation_signal = "initial_rotated_cw"
	elif input.is_ccw_pressed():
		rotation_signal = "initial_rotated_ccw"
	
	match rotation_signal:
		"initial_rotated_ccw":
			input.set_ccw_input_as_handled()
			piece.target_orientation = piece.get_ccw_orientation()
		"initial_rotated_cw":
			input.set_cw_input_as_handled()
			piece.target_orientation = piece.get_cw_orientation()
		"initial_rotated_180":
			input.set_cw_input_as_handled()
			input.set_ccw_input_as_handled()
			piece.target_orientation = piece.get_flip_orientation()
	
	if rotation_signal:
		match CurrentLevel.settings.other.suppress_piece_initial_rotation:
			OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS:
				# 'suppress piece initial rotation and signals' is enabled; do nothing
				pass
			OtherRules.SuppressPieceRotation.ROTATION:
				# 'suppress piece initial rotation' is enabled; emit rotation signals but don't rotate
				emit_signal(rotation_signal)
			_:
				# rotate the piece and emit rotation signals
				piece.move_to_target()
				emit_signal(rotation_signal)
	
	match rotation_signal:
		"initial_rotated_ccw": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.INITIAL_ROTATED_CCW)
		"initial_rotated_cw": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.INITIAL_ROTATED_CW)
		"initial_rotated_180": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.INITIAL_ROTATED_180)


func apply_rotate_input(piece: ActivePiece) -> void:
	if not input.is_cw_pressed() and not input.is_ccw_pressed():
		return
	
	_calc_rotate_target(piece)
	
	if piece.target_orientation != piece.orientation:
		var rotation_signal: String
		if piece.target_orientation == piece.get_cw_orientation():
			rotation_signal = "rotated_cw"
		elif piece.target_orientation == piece.get_ccw_orientation():
			rotation_signal = "rotated_ccw"
		elif piece.target_orientation == piece.get_flip_orientation():
			rotation_signal = "rotated_180"
		
		var old_piece_y := piece.pos.y
		if not piece.can_move_to_target():
			piece.kick_piece()
		if not piece.can_move_to_target() and input.is_cw_pressed() and input.is_ccw_pressed():
			rotation_signal = "rotated_180"
			piece.target_orientation = piece.get_flip_orientation()
			if not piece.can_move_to_target():
				piece.kick_piece()
		
		if piece.target_pos.y < piece.pos.y and not piece.can_floor_kick():
			# tried to flip but we don't have any floor kicks for it
			rotation_signal = ""
		elif not piece.can_move_to_target():
			rotation_signal = ""
		
		if rotation_signal:
			match CurrentLevel.settings.other.suppress_piece_rotation:
				OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS:
					# 'suppress piece rotation and signals' is enabled; do nothing
					pass
				OtherRules.SuppressPieceRotation.ROTATION:
					# 'suppress piece rotation' is enabled; emit rotation signals but don't rotate
					emit_signal(rotation_signal)
				_:
					# rotate the piece and emit rotation signals
					piece.move_to_target()
					emit_signal(rotation_signal)
		
		if piece.pos.y < old_piece_y:
			piece.floor_kicks += 1
		
		match rotation_signal:
			"rotated_ccw": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.ROTATED_CCW)
			"rotated_cw": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.ROTATED_CW)
			"rotated_180": CurrentLevel.settings.triggers.run_triggers(LevelTrigger.ROTATED_180)


## Calculates the position and orientation the player is trying to rotate the piece to.
func _calc_rotate_target(piece: ActivePiece) -> void:
	if not input.is_cw_pressed() and not input.is_ccw_pressed():
		return
	
	piece.reset_target()
	if input.is_cw_just_pressed() and input.is_ccw_just_pressed():
		# flip the piece by rotating it twice
		piece.target_orientation = piece.get_flip_orientation()
	elif input.is_cw_just_pressed():
		if input.is_ccw_pressed():
			# flip the piece by rotating it again in the same direction
			piece.target_orientation = piece.get_ccw_orientation()
		else:
			piece.target_orientation = piece.get_cw_orientation()
	elif input.is_ccw_just_pressed():
		if input.is_cw_pressed():
			# flip the piece by rotating it again in the same direction
			piece.target_orientation = piece.get_cw_orientation()
		else:
			piece.target_orientation = piece.get_ccw_orientation()
