extends "res://addons/gut/test.gd"

func before_each() -> void:
	PlayerData.chat_history.reset()
	
	PlayerData.chat_history.add_history_item("creature/gurus750/level_001")


func after_each() -> void:
	CareerLevelLibrary.worlds_path = LevelLibrary.DEFAULT_WORLDS_PATH


func test_regions() -> void:
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds-simple.json"
	assert_eq(CareerLevelLibrary.regions.size(), 3)
	
	var region_1: CareerRegion = CareerLevelLibrary.regions[1]
	assert_eq(region_1.name, "Even World")
	assert_eq(region_1.start, 10)
	assert_eq(region_1.min_piece_speed, "0")
	assert_eq(region_1.max_piece_speed, "3")
	assert_eq(region_1.length, 10)
	assert_eq(region_1.levels.size(), 3)


func test_region_chefs() -> void:
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds-simple.json"
	
	var region_0: CareerRegion = CareerLevelLibrary.regions[0]
	assert_eq(region_0.chefs.size(), 2)
	
	assert_eq(region_0.chefs[0].id, "chef_38")
	assert_eq(region_0.chefs[0].chance, 0.0)
	assert_eq(region_0.chefs[0].quirky, true)
	
	assert_eq(region_0.chefs[1].id, "chef_36")
	assert_eq(region_0.chefs[1].chance, 0.25)
	assert_eq(region_0.chefs[1].quirky, false)


func test_region_customers() -> void:
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds-simple.json"
	
	var region_0: CareerRegion = CareerLevelLibrary.regions[0]
	assert_eq(region_0.customers.size(), 2)
	
	assert_eq(region_0.customers[0].id, "customer_77")
	assert_eq(region_0.customers[0].chance, 0.10)
	assert_eq(region_0.customers[0].quirky, false)
	
	assert_eq(region_0.customers[1].id, "customer_90")
	assert_eq(region_0.customers[1].chance, 0.0)
	assert_eq(region_0.customers[1].quirky, true)


func test_region_observers() -> void:
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds-simple.json"
	
	var region_0: CareerRegion = CareerLevelLibrary.regions[0]
	assert_eq(region_0.observers.size(), 2)
	
	assert_eq(region_0.observers[0].id, "observer_35")
	assert_eq(region_0.observers[0].chance, 0.30)
	assert_eq(region_0.observers[0].quirky, false)
	
	assert_eq(region_0.observers[1].id, "observer_30")
	assert_eq(region_0.observers[1].chance, 0.0)
	assert_eq(region_0.observers[1].quirky, true)


func test_region_demographics() -> void:
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds-simple.json"
	
	var region_0: CareerRegion = CareerLevelLibrary.regions[0]
	assert_eq(region_0.demographic_data.demographics.size(), 1)
	assert_eq(region_0.demographic_data.demographics[0].type, Creatures.Type.SQUIRREL)
	assert_eq(region_0.demographic_data.demographics[0].chance, 1.0)


## increasing the weight selects faster speeds
func test_piece_speed_between_weight() -> void:
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 0.0, 0.5), "0")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 0.5, 0.5), "2")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 1.0, 0.5), "4")


## adjusting the random parameter selects different speeds
func test_piece_speed_between_r() -> void:
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "3", 0.5, 0.0), "1")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "3", 0.5, 0.4), "1")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "3", 0.5, 0.6), "2")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "3", 0.5, 1.0), "2")


## at the edges, adjusting the random parameter still has an effect, however slight
func test_piece_speed_between_r_edges() -> void:
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 0.0, 0.0), "0")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 0.0, 0.9), "0")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 0.0, 1.0), "1")
	
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 1.0, 0.0), "3")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 1.0, 0.1), "4")
	assert_eq(CareerLevelLibrary.piece_speed_between("0", "4", 1.0, 1.0), "4")


## when min==max, weight and r have no effect
func test_piece_speed_between_narrow() -> void:
	assert_eq(CareerLevelLibrary.piece_speed_between("4", "4", 0.0, 0.0), "4")
	assert_eq(CareerLevelLibrary.piece_speed_between("4", "4", 1.0, 1.0), "4")


func test_region_for_distance() -> void:
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds-simple.json"
	
	assert_eq(CareerLevelLibrary.region_for_distance(0).name, "Permissible World")
	assert_eq(CareerLevelLibrary.region_for_distance(9).name, "Permissible World")
	assert_eq(CareerLevelLibrary.region_for_distance(10).name, "Even World")
	assert_eq(CareerLevelLibrary.region_for_distance(33).name, "Cherries World")
	assert_eq(CareerLevelLibrary.region_for_distance(CareerData.MAX_DISTANCE_TRAVELLED).name, "Cherries World")


func test_region_weight_for_distance() -> void:
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds-simple.json"
	
	assert_eq(CareerLevelLibrary.region_weight_for_distance(
		CareerLevelLibrary.region_for_distance(10), 10), 0.0)
	assert_almost_eq(CareerLevelLibrary.region_weight_for_distance(
		CareerLevelLibrary.region_for_distance(15), 15), 0.55, 0.01)
	assert_eq(CareerLevelLibrary.region_weight_for_distance(
		CareerLevelLibrary.region_for_distance(19), 19), 1.0)


func test_trim_levels_by_characters_customer() -> void:
	var region := CareerRegion.new()
	region.customers.append(CareerRegion.CreatureAppearance.new())
	region.customers.back().from_json_string("(quirky) customer_211")
	
	var all_levels := []
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_211",
		"customer_ids": ["customer_211"],
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_212",
		"customer_ids": ["customer_212"],
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_213",
	})
	var trimmed_levels := CareerLevelLibrary.trim_levels_by_characters(region, all_levels, [], ["customer_211"], [])
	assert_eq(trimmed_levels.size(), 1)
	assert_eq(trimmed_levels[0].level_id, "level_211")


func test_trim_levels_by_characters_chef() -> void:
	var region := CareerRegion.new()
	region.chefs.append(CareerRegion.CreatureAppearance.new())
	region.chefs.back().from_json_string("(quirky) chef_211")
	
	var all_levels := []
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_211",
		"chef_id": "chef_211",
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_212",
		"chef_id": "chef_212",
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_213",
	})
	
	var trimmed_levels := CareerLevelLibrary.trim_levels_by_characters(region, all_levels, ["chef_211"], [], [])
	assert_eq(trimmed_levels.size(), 1)
	assert_eq(trimmed_levels[0].level_id, "level_211")


func test_trim_levels_by_characters_observer() -> void:
	var region := CareerRegion.new()
	region.observers.append(CareerRegion.CreatureAppearance.new())
	region.observers.back().from_json_string("(quirky) observer_211")
	
	var all_levels := []
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_211",
		"observer_id": "observer_211",
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_212",
		"observer_id": "observer_212",
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_213",
	})
	
	var trimmed_levels := CareerLevelLibrary.trim_levels_by_characters(region, all_levels, [], [], ["observer_211"])
	assert_eq(trimmed_levels.size(), 1)
	assert_eq(trimmed_levels[0].level_id, "level_211")


func test_trim_levels_by_characters_anonymous_customer() -> void:
	var region := CareerRegion.new()
	region.chefs.append(CareerRegion.CreatureAppearance.new())
	region.chefs.back().from_json_string("(quirky) chef_211")
	region.customers.append(CareerRegion.CreatureAppearance.new())
	region.customers.back().from_json_string("(quirky) customer_212")
	
	var all_levels := []
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_211",
		"chef_id": "chef_211",
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_212",
		"customer_ids": ["customer_212"],
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_213",
		"chef_id": "chef_213",
		"customer_ids": ["customer_213"],
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_214",
	})
	
	var trimmed_levels := CareerLevelLibrary.trim_levels_by_characters(
			region, all_levels, [], [CareerLevel.NONQUIRKY_CUSTOMER], [])
	assert_eq(trimmed_levels.size(), 2)
	assert_eq(trimmed_levels[0].level_id, "level_213")
	assert_eq(trimmed_levels[1].level_id, "level_214")


func test_trim_levels_by_characters_all() -> void:
	var region := CareerRegion.new()
	region.chefs.append(CareerRegion.CreatureAppearance.new())
	region.chefs.back().from_json_string("(quirky) chef_211")
	region.customers.append(CareerRegion.CreatureAppearance.new())
	region.customers.back().from_json_string("(quirky) customer_212")
	
	var all_levels := []
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_211",
		"chef_id": "chef_211",
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_212",
		"customer_ids": ["customer_212"],
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_213",
	})
	
	var trimmed_levels := CareerLevelLibrary.trim_levels_by_characters(region, all_levels, [], [], [])
	assert_eq(trimmed_levels.size(), 3)


func test_trim_levels_by_available_if() -> void:
	var all_levels := []
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_211",
		"chef_id": "chef_211",
		"available_if": "chat_finished creature/gurus750/level_001"
	})
	all_levels.append(CareerLevel.new())
	all_levels.back().from_json_dict({
		"id": "level_212",
		"chef_id": "chef_211",
		"available_if": "chat_finished creature/gurus750/level_002"
	})
	
	var trimmed_levels := CareerLevelLibrary.trim_levels_by_available_if(all_levels)
	assert_eq(trimmed_levels.size(), 1)
	assert_eq(trimmed_levels[0].level_id, "level_211")
