class_name Hero
extends AnimatedSprite2D

enum State { RUNNING, SLASHING }

var current_state: State = State.RUNNING


func _ready() -> void:
	animation_finished.connect(_on_animation_finished)


func _unhandled_input(event: InputEvent) -> void:
	var event_key: InputEventKey = event as InputEventKey
	if event_key and event_key.physical_keycode == KEY_SPACE and event_key.is_pressed() and not event_key.is_echo():
		if current_state == State.RUNNING:
			_change_state(State.SLASHING)


func _change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	match current_state:
		State.RUNNING:
			play("run")
		State.SLASHING:
			play("slash")


func _on_animation_finished() -> void:
	if current_state == State.SLASHING:
		_change_state(State.RUNNING)
