extends OverworldUi
## UI elements for overworld cutscenes.

## The delay between the speaker and the listener when they start walking. The speaking creature starts walking first,
## then the other creature starts walking after a short pause.
const WALK_REACTION_DELAY := 0.4

## Extends the parent class's _apply_chat_event_meta() method to add support for the 'start_walking' and 'stop_walking'
## metadata items.
func _apply_chat_event_meta(chat_event: ChatEvent, meta_item: String) -> void:
	._apply_chat_event_meta(chat_event, meta_item)
	match(meta_item):
		"stop_walking":
			for creature in get_tree().get_nodes_in_group("creatures"):
				if not creature is WalkingBuddy:
					continue
				var walking_buddy: WalkingBuddy = creature
				var delay := WALK_REACTION_DELAY
				if creature.creature_id == chat_event.who:
					delay = 0.0
				walking_buddy.stop_walking(delay)
		"start_walking":
			for creature in get_tree().get_nodes_in_group("creatures"):
				if not creature is WalkingBuddy:
					continue
				var walking_buddy: WalkingBuddy = creature
				var delay := WALK_REACTION_DELAY
				if creature.creature_id == chat_event.who:
					delay = 0.0
				walking_buddy.start_walking(delay)


## Launches the next scene in story mode.
##
## This could be a level, an overworld where the player can move around, or another cutscene.
func _push_story_trail() -> void:
	if Breadcrumb.trail[1] == Global.SCENE_CUTSCENE_DEMO:
		# don't modify the breadcrumb path; we're not returning to the overworld after
		pass
	else:
		# modify the overworld path and spawn IDs to preserve the player's position from the cutscene
		PlayerData.story.environment_path = _current_chat_tree.destination_environment_path()
		
		if _current_chat_tree.destination_environment_path() == _current_chat_tree.chat_environment_path():
			# preserve spawn ids from cutscene
			CutsceneManager.assign_player_spawn_ids(_current_chat_tree)
		else:
			# erase spawn IDs to avoid 'could not locate spawn' warnings when playing multiple cutscenes
			# consecutively
			PlayerData.story.player_spawn_id = ""
			PlayerData.story.sensei_spawn_id = ""
	
	if CutsceneManager.is_front_level():
		# continue to a level (preroll cutscene finished playing)
		
		# [menu > overworld_1 > cutscene] -> [menu > overworld_2 > puzzle]
		Breadcrumb.trail.remove(0)
		CutsceneManager.push_trail()
	elif CutsceneManager.is_front_cutscene():
		# continue to another cutscene (first of multiple cutscenes finished playing)
		
		# [menu > overworld > cutscene_1] -> [menu > overworld > cutscene_2]
		CutsceneManager.replace_trail()
	else:
		# return to the overworld (postroll/misc cutscene finished playing)
		
		# [menu > overworld_1 > cutscene] -> [menu > overworld_2]
		SceneTransition.pop_trail()
		
		# immediately save the player data. the player might quit from the overworld, but we want to save
		# their progress
		PlayerSave.save_player_data()


func _on_ChatUi_chat_finished() -> void:
	PlayerData.chat_history.add_history_item(_current_chat_tree.chat_key)
	CurrentCutscene.clear_launched_cutscene()
	if not CurrentCutscene.chat_tree \
			and Breadcrumb.trail.size() >= 2 and Breadcrumb.trail[1] == Global.SCENE_CUTSCENE_DEMO:
		# go back to CutsceneDemo after playing the cutscene
		SceneTransition.pop_trail()
	elif PlayerData.career.is_career_cutscene():
		# launch the next scene in career mode after playing the cutscene
		PlayerData.career.push_career_trail()
	else:
		# launch the next scene in story mode after playing the cutscene
		_push_story_trail()
