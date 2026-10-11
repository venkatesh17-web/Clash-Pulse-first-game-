extends Node

## Pulse Clash - Audio Manager (Autoload)
## Centralized SFX playback helper with procedurally synthesized audio and pooling.

var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_POOL := 8

const SoundSynthScript = preload("res://scripts/utils/sound_synth.gd")

var _shard_sfx: AudioStreamWAV = null
var _pulse_sfx: AudioStreamWAV = null
var _game_over_sfx: AudioStreamWAV = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(MAX_SFX_POOL):
		var player := AudioStreamPlayer.new()
		player.bus = &"Master"
		add_child(player)
		sfx_players.append(player)

	# Pre-synthesize lightweight audio buffers once
	_shard_sfx = SoundSynthScript.create_shard_chime()
	_pulse_sfx = SoundSynthScript.create_pulse_sound()
	_game_over_sfx = SoundSynthScript.create_game_over_sound()


func play_shard_sound() -> void:
	play_sfx(_shard_sfx, randf_range(0.95, 1.15))


func play_pulse_sound() -> void:
	play_sfx(_pulse_sfx, 1.0)


func play_game_over_sound() -> void:
	play_sfx(_game_over_sfx, 1.0)


func play_sfx(stream: AudioStream, pitch_scale: float = 1.0) -> void:
	if not GameManager.sound_enabled or stream == null:
		return

	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = pitch_scale
			player.play()
			return
