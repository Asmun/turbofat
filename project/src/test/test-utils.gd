extends "res://addons/gut/test.gd"

enum MoldyFlap {
	BIT_PUNY,
	ROB_RECEIPT,
	MEATY_FALSE,
}

func test_weighted_rand_value() -> void:
	# item #575 should be picked 99.9% of the time
	var weights_map := {}
	for i in range(1000):
		weights_map["item-%s" % i] = 0.001
	weights_map["item-575"] = 1000.0
	
	# we pick three times, just in case we hit the 0.1% chance
	var results := {}
	for _i in range(3):
		results[Utils.weighted_rand_value(weights_map)] = true
	
	assert_has(results, "item-575")


func test_subtract() -> void:
	assert_eq(Utils.subtract([1, 2, 3], [1, 3]), [2])


func test_subtract_duplicates() -> void:
	assert_eq(Utils.subtract([1, 1, 1, 1, 1], [1, 1]), [1, 1, 1])


func test_remove_all() -> void:
	assert_eq([4, 10, 15], Utils.remove_all([1, 4, 10, 1, 15], 1))


func test_remove_all_not_found() -> void:
	assert_eq([1, 4, 10, 1, 15], Utils.remove_all([1, 4, 10, 1, 15], 2))


func test_remove_all_empty() -> void:
	assert_eq([], Utils.remove_all([], 2))


func test_enum_to_snake_case() -> void:
	assert_eq(Utils.enum_to_snake_case(MoldyFlap, MoldyFlap.ROB_RECEIPT, "meaty_false"), "rob_receipt")
	assert_eq(Utils.enum_to_snake_case(MoldyFlap, MoldyFlap.ROB_RECEIPT), "rob_receipt")
	assert_eq(Utils.enum_to_snake_case(MoldyFlap, 13, "meaty_false"), "meaty_false")
	assert_eq(Utils.enum_to_snake_case(MoldyFlap, 13), "bit_puny")


func test_enum_from_snake_case() -> void:
	assert_eq(Utils.enum_from_snake_case(MoldyFlap, "rob_receipt", MoldyFlap.MEATY_FALSE), MoldyFlap.ROB_RECEIPT)
	assert_eq(Utils.enum_from_snake_case(MoldyFlap, "rob_receipt"), MoldyFlap.ROB_RECEIPT)
	assert_eq(Utils.enum_from_snake_case(MoldyFlap, "bogus_610", MoldyFlap.MEATY_FALSE), MoldyFlap.MEATY_FALSE)
	assert_eq(Utils.enum_from_snake_case(MoldyFlap, "bogus_610"), MoldyFlap.BIT_PUNY)


func test_seeded_shuffle_shuffles() -> void:
	var source := ["a", "b", "c", "d", "e", "f", "g"]
	
	var shuffled1 := source.duplicate()
	Utils.seeded_shuffle(shuffled1, 26)
	
	assert_false(shuffled1 == source, "shuffle did not reorder source array (%s, %s)" % [shuffled1, source])


func test_seeded_shuffle_same_seed() -> void:
	var source := ["a", "b", "c", "d", "e", "f", "g"]
	
	var shuffled1 := source.duplicate()
	Utils.seeded_shuffle(shuffled1, 26)
	
	var shuffled2 := source.duplicate()
	Utils.seeded_shuffle(shuffled2, 26)
	
	assert_true(shuffled1 == shuffled2, "same seed resulted in different output (%s, %s)" % [shuffled1, shuffled2])


func test_seeded_shuffle_different_seed() -> void:
	var source := ["a", "b", "c", "d", "e", "f", "g"]
	
	var shuffled1 := source.duplicate()
	Utils.seeded_shuffle(shuffled1, 26)
	
	var shuffled2 := source.duplicate()
	Utils.seeded_shuffle(shuffled2, 18)
	
	assert_false(shuffled1 == shuffled2, "different seed resulted in same output (%s, %s)" % [shuffled1, shuffled2])
