class_name SoundSynth
extends RefCounted

## Pulse Clash - Procedural Audio Synthesizer
## Generates lightweight, zero-memory PCM sound effects entirely in code.

const SAMPLE_RATE: int = 22050


static func create_shard_chime() -> AudioStreamWAV:
	var duration := 0.12
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t := float(i) / float(SAMPLE_RATE)
		# Dual ascending frequencies (880Hz + 1320Hz) with exponential decay
		var env := exp(-t * 22.0)
		var s1 := sin(t * 880.0 * TAU)
		var s2 := sin(t * 1320.0 * TAU) * 0.5
		var sample := int((s1 + s2) * env * 18000.0)
		sample = clampi(sample, -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	return wav


static func create_pulse_sound() -> AudioStreamWAV:
	var duration := 0.32
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t := float(i) / float(SAMPLE_RATE)
		# Low frequency resonant sweep (240Hz down to 70Hz)
		var freq := lerpf(240.0, 70.0, t / duration)
		var env := exp(-t * 9.0)
		var sample := int(sin(t * freq * TAU) * env * 24000.0)
		sample = clampi(sample, -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	return wav


static func create_game_over_sound() -> AudioStreamWAV:
	var duration := 0.45
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t := float(i) / float(SAMPLE_RATE)
		# Descending crunch tone (300Hz down to 60Hz) with noise distortion
		var freq := lerpf(300.0, 60.0, t / duration)
		var env := exp(-t * 6.5)
		var noise := randf_range(-0.15, 0.15)
		var sample := int((sin(t * freq * TAU) + noise) * env * 22000.0)
		sample = clampi(sample, -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	return wav


static func create_ui_click_sound() -> AudioStreamWAV:
	var duration := 0.04
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t := float(i) / float(SAMPLE_RATE)
		var env := exp(-t * 90.0)
		var sample := int(sin(t * 1400.0 * TAU) * env * 16000.0)
		sample = clampi(sample, -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	return wav


static func create_stun_zap_sound() -> AudioStreamWAV:
	var duration := 0.22
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t := float(i) / float(SAMPLE_RATE)
		var env := exp(-t * 14.0)
		# Rapidly buzzing frequency with noise modulation
		var mod := sin(t * 80.0 * TAU) * 120.0
		var freq := 520.0 + mod
		var noise := randf_range(-0.1, 0.1)
		var sample := int((sin(t * freq * TAU) + noise) * env * 20000.0)
		sample = clampi(sample, -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	return wav


static func create_countdown_beep(high_pitch: bool = false) -> AudioStreamWAV:
	var duration := 0.14 if high_pitch else 0.09
	var total_samples := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var target_freq := 880.0 if high_pitch else 440.0
	for i in range(total_samples):
		var t := float(i) / float(SAMPLE_RATE)
		var env := exp(-t * (18.0 if high_pitch else 26.0))
		var sample := int(sin(t * target_freq * TAU) * env * 18000.0)
		sample = clampi(sample, -32767, 32767)
		bytes.encode_s16(i * 2, sample)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	return wav
