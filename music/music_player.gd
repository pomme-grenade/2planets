extends AudioStreamPlayer

func set_lowpass_active(active: bool) -> void:
	var bus_idx = AudioServer.get_bus_index(self.get_bus())
	AudioServer.set_bus_effect_enabled(bus_idx, 0, active)
