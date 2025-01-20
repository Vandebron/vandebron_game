extends Node


func _ready() -> void:
	test_all()


func test_all() -> void:
	score_should_do_delimiters_right_1()
	score_should_do_delimiters_right_2()
	score_should_do_delimiters_right_3()


func score_should_do_delimiters_right_1() -> void:
	var score: int = 400_000
	var actual: String = Utils.decimal_with_separators(score)
	var expected := "400,000"
	assert(actual == expected, "Expected %s but was %s" % [expected, actual])


func score_should_do_delimiters_right_2() -> void:
	var score: int = 12_000_000
	var actual: String = Utils.decimal_with_separators(score)
	var expected := "12,000,000"
	assert(actual == expected, "Expected %s but was %s" % [expected, actual])


func score_should_do_delimiters_right_3() -> void:
	var score: int = 1_000_000
	var actual: String = Utils.decimal_with_separators(score)
	var expected := "1,000,000"
	assert(actual == expected, "Expected %s but was %s" % [expected, actual])
