extends Node
## Contains variables for preserving state when loading different scenes.

## splash screen which precedes the main menu.
const SCENE_SPLASH := "res://src/main/ui/menu/SplashScreen.tscn"

## menu the user sees after starting the game.
const SCENE_MAIN_MENU := "res://src/main/ui/menu/MainMenu.tscn"

## non-interactive cutscene which shows creatures talking and interacting.
const SCENE_CUTSCENE := "res://src/main/world/Cutscene.tscn"

## overworld which the player character can run around on and talk to other creatures.
const SCENE_FREE_ROAM := "res://src/main/world/FreeRoam.tscn"

## scene for career mode which shows the player's progress between levels
const SCENE_CAREER_MAP := "res://src/main/world/CareerMap.tscn"

## puzzle where a player drops pieces into a playfield of blocks.
const SCENE_PUZZLE := "res://src/main/puzzle/Puzzle.tscn"

## cutscene demo; only used during development
const SCENE_CUTSCENE_DEMO := "res://src/demo/world/CutsceneDemo.tscn"

## The scale of the TextureRect the creature is rendered to
const CREATURE_SCALE := 0.4

## weighted distribution of 'fatnesses' in the range [1.0, 10.0]. most creatures are skinny.
const FATNESSES := [
	1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
	1.1, 1.2, 1.3, 1.5,
	1.8, 2.3,
]

## The factor to multiply by to convert non-isometric coordinates into isometric coordinates
const ISO_FACTOR := Vector2(1.0, 0.5)

## Target number of creature greetings (hello, goodbye) per minute
const GREETINGS_PER_MINUTE := 3.0

## Stores all of the benchmarks which have been started
var _benchmark_start_times := Dictionary()

## A number in the range [-1, 1] which corresponds to how many greetings we've given recently. If it's close to 1,
## we're very unlikely to receive a greeting. If it's close to -1, we're very likely to receive a greeting.
var greetiness := 0.0

func _init() -> void:
	# ensure music, pieces are random
	randomize()


func _process(delta: float) -> void:
	greetiness = clamp(greetiness + delta * GREETINGS_PER_MINUTE / 60, -1.0, 1.0)


## Convert a coordinate from global coordinates to isometric (squashed) coordinates
static func to_iso(vector: Vector2) -> Vector2:
	return vector * ISO_FACTOR


## Convert a coordinate from isometric coordinates to global (unsquashed) coordinates
static func from_iso(vector: Vector2) -> Vector2:
	return vector / ISO_FACTOR


## Sets the start time for a benchmark. Calling 'benchmark_start(foo)' and 'benchmark_finish(foo)' will display a
## message like 'foo took 123 milliseconds'.
func benchmark_start(key: String = "") -> void:
	_benchmark_start_times[key] = OS.get_ticks_msec()


## Prints the amount of time which has passed since a benchmark was started. Calling 'benchmark_start(foo)' and
## 'benchmark_finish(foo)' will display a message like 'foo took 123 milliseconds'.
func benchmark_end(key: String = "") -> void:
	if not _benchmark_start_times.has(key):
		print("Invalid benchmark: %s" % key)
		return
	print("benchmark %s: %.3f msec" % [key, (OS.get_ticks_msec() - _benchmark_start_times[key])])


## Returns 'true' if the creature should greet us. We calculate this based on how many times we've been greeted
## recently.
##
## Novice players or fast players won't mind receiving a lot of sounds related to combos because those sounds are
## associated with positive reinforcement (big combos), but they could get annoyed if creatures say hello/goodbye too
## frequently because those sounds are associated with negative reinforcement (broken combos).
func should_chat() -> bool:
	var should_chat := true
	if greetiness + randf() > 1.0:
		greetiness -= 1.0 / GREETINGS_PER_MINUTE
	else:
		should_chat = false
	return should_chat


func get_overworld_ui() -> OverworldUi:
	var nodes := get_tree().get_nodes_in_group("overworld_ui")
	return nodes[0]


## Locates the node responsible for creating and initializing chat icons, if one exists.
##
## The creatures in free roam mode have chat icons. Career mode and cutscenes do not.
func get_chat_icon_container() -> ChatIcons:
	var nodes := get_tree().get_nodes_in_group("chat_icon_containers")
	return nodes[0] if nodes else null
