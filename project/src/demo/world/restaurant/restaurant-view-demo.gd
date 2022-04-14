extends Control
## A demo which shows off the restaurant view.
##
## Keys:
## 	[D]: Ring the doorbell
## 	[F]: Feed the creature
## 	[I]: Launch an idle animation
## 	[V]: Say something
## 	[N]: Change the nametag names
## 	[1-9,0]: Change the creature's size from 10% to 100%
## 	SHIFT+[1-9,0]: Change the creature's comfort from 0.0 -> 1.0 -> -1.0
## 	[Q,W,E]: Switch to the 1st, 2nd or 3rd creature.
## 	arrows: Change the creature's orientation
## 	brace keys: Change the creature's appearance

const FATNESS_KEYS = [10.0, 1.0, 1.5, 2.0, 3.0, 5.0, 6.0, 7.0, 8.0, 9.0]
const NAMES = [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore" \
		+ " magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea" \
		+ " commodo consequat.",
	"",
	"Lo",
	"Lorem",
	"Lorem ipsum",
	"Lorem ipsum dolor",
	"Lorem ipsum dolor sit amet",
	"Lorem ipsum dolor sit amet, consectetur",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incidid",
]

var _current_name_index := 4

func _ready() -> void:
	$RestaurantView.summon_customer()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_D: $RestaurantView/RestaurantViewport/Scene.get_node("DoorChime").play_door_chime()
		KEY_F: _customer().feed(Foods.FoodType.BROWN_0)
		KEY_I: _customer().creature_visuals.get_node("Animations/IdleTimer").start(0.01)
		KEY_N:
			_current_name_index = (_current_name_index + 1) % NAMES.size()
			_customer().creature_name = NAMES[_current_name_index]
			_player().creature_name = NAMES[_current_name_index]
		KEY_V:
			_customer().get_node("CreatureSfx").play_goodbye_voice()
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			if Input.is_key_pressed(KEY_SHIFT):
				# shift pressed; change creature's comfort
				match Utils.key_scancode(event):
					KEY_1: $RestaurantView.get_customer().set_comfort(0.00) # hasn't eaten
					KEY_2: $RestaurantView.get_customer().set_comfort(0.30)
					KEY_3: $RestaurantView.get_customer().set_comfort(0.60)
					KEY_4: $RestaurantView.get_customer().set_comfort(1.00) # ate enough
					KEY_5: $RestaurantView.get_customer().set_comfort(-0.10) # starting to overeat
					KEY_6: $RestaurantView.get_customer().set_comfort(-0.30)
					KEY_7: $RestaurantView.get_customer().set_comfort(-0.50) # ate too much
					KEY_8: $RestaurantView.get_customer().set_comfort(-0.70)
					KEY_9: $RestaurantView.get_customer().set_comfort(-0.90)
					KEY_0: $RestaurantView.get_customer().set_comfort(-1.00) # ate way too much
			else:
				# shift not pressed; change creature's fatness
				$RestaurantView.get_customer().set_fatness(FATNESS_KEYS[Utils.key_num(event)])
		KEY_Q: $RestaurantView.set_current_creature_index(0)
		KEY_W: $RestaurantView.set_current_creature_index(1)
		KEY_E: $RestaurantView.set_current_creature_index(2)
		KEY_BRACKETLEFT, KEY_BRACKETRIGHT:
			$RestaurantView.summon_customer()
		KEY_RIGHT:
			$RestaurantView.get_customer().set_orientation(Creatures.SOUTHEAST)
		KEY_DOWN:
			$RestaurantView.get_customer().set_orientation(Creatures.SOUTHWEST)
		KEY_LEFT:
			$RestaurantView.get_customer().set_orientation(Creatures.NORTHWEST)
		KEY_UP:
			$RestaurantView.get_customer().set_orientation(Creatures.NORTHEAST)


func _customer() -> Creature:
	return $RestaurantView/RestaurantViewport/Scene.get_customer()


func _player() -> Creature:
	return $RestaurantView/RestaurantViewport/Scene.get_player()
