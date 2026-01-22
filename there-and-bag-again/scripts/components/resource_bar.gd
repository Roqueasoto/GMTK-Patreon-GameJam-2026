extends ProgressBar

signal bar_is_empty(delta: float)

func update(delta: float) -> void:
	var new_value = self.value + delta
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, ^"value", new_value, 0.5)
	
	if new_value <= 0:
		signal_empty_bar(new_value)

func signal_empty_bar(delta: float) -> void:
	bar_is_empty.emit(delta)
