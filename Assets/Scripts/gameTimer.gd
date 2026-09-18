extends Node

signal time_changed(time_remaining: float)
signal time_up
signal time_low(time_remaining: float)

@export var starting_time: float = 60.0
@export var low_time_threshold: float = 10.0

var time_remaining: float = 0.0
var is_running: bool = false
var _has_fired_low_warning: bool = false

func _ready() -> void:
	reset()

func _process(delta: float) -> void:
	if not is_running:
		return

	time_remaining = max(time_remaining - delta, 0.0)
	time_changed.emit(time_remaining)

	if not _has_fired_low_warning and time_remaining <= low_time_threshold and time_remaining > 0.0:
		_has_fired_low_warning = true
		time_low.emit(time_remaining)

	if time_remaining <= 0.0:
		is_running = false
		time_up.emit()

func add_time(amount: float) -> void:
	if not is_running:
		return
	time_remaining = max(time_remaining + amount, 0.0)
	time_changed.emit(time_remaining)
	if time_remaining <= 0.0:
		is_running = false
		time_up.emit()

func start() -> void:
	is_running = true

func stop() -> void:
	is_running = false

func reset(new_starting_time: float = starting_time) -> void:
	starting_time = new_starting_time
	time_remaining = new_starting_time
	is_running = false
	_has_fired_low_warning = false
	time_changed.emit(time_remaining)

func get_time_formatted() -> String:
	var seconds := int(time_remaining)
	var millis := int((time_remaining - seconds) * 100)
	return "%02d:%02d" % [seconds, millis]
