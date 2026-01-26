extends ProgressBar

signal bar_is_empty(delta: float)

var tween: Tween
var target_value: float

func _ready():
	target_value = value

func update(delta: float) -> void:
	var old_target = target_value
	target_value += delta

	# If the bar was not empty, but now it is, signal it.
	if old_target > 0 and target_value <= 0:
		signal_empty_bar(target_value)

	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	# The final value for the tween should not be negative.
	tween.tween_property(self, ^"value", max(0, target_value), 0.4)

func signal_empty_bar(delta: float) -> void:
	bar_is_empty.emit(delta)
