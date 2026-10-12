class_name GameplayManager
extends Node2D

## Pulse Clash - Core Gameplay Manager
## Manages energy shard spawning, enemy pursuit waves, pulse abilities, and survival scoring.

signal run_started
signal run_ended(final_score: int, survival_time: float)
signal pulse_triggered(cooldown_duration: float)
signal pulse_cooldown_tick(remaining: float, total: float)
signal enemies_updated(active_count: int, max_count: int)
signal grace_period_tick(remaining: float)

@export_group("Pulse Tuning")
@export var pulse_stun_radius: float = 160.0
@export var pulse_attract_radius: float = 210.0
@export var pulse_stun_duration: float = 1.5
@export var pulse_cooldown: float = 5.0

@export_group("Spawning Limits")
@export var shard_count: int = 6
@export var max_enemies: int = 8
@export var initial_grace_period: float = 2.5
@export var enemy_wave_interval: float = 9.0

# Scene preloads
const SHARD_SCENE: PackedScene = preload("res://scenes/entities/energy_shard.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")
const SHOCKWAVE_SCENE: PackedScene = preload("res://scenes/entities/pulse_shockwave.tscn")

var is_run_active: bool = false
var survival_time: float = 0.0
var pulse_cooldown_remaining: float = 0.0
var grace_time_remaining: float = 0.0
var _wave_timer: float = 0.0

var _shards: Array[EnergyShard] = []
var _enemies: Array[Enemy] = []

@onready var arena: Arena = get_parent().get_node_or_null("Arena") as Arena
@onready var player: Player = get_parent().get_node_or_null("Player") as Player
@onready var entities_container: Node2D = self


func _ready() -> void:
	if arena == null:
		arena = get_tree().root.find_child("Arena", true, false) as Arena
	if player == null:
		player = get_tree().root.find_child("Player", true, false) as Player


func start_new_run() -> void:
	is_run_active = true
	survival_time = 0.0
	pulse_cooldown_remaining = 0.0
	_wave_timer = 0.0
	grace_time_remaining = initial_grace_period

	_clear_all_entities()

	if player:
		player.reset_to_center()
		player.set_invulnerable(true)

	_spawn_initial_shards()
	_spawn_enemy(true) # Initial enemy spawned far at perimeter corner

	run_started.emit()
	pulse_cooldown_tick.emit(0.0, pulse_cooldown)
	enemies_updated.emit(_enemies.size(), max_enemies)
	grace_period_tick.emit(grace_time_remaining)


func end_run() -> void:
	if not is_run_active:
		return
	is_run_active = false
	GameManager.current_state = GameManager.State.GAME_OVER

	var final_score := GameManager.current_score
	if final_score > GameManager.high_score:
		GameManager.high_score = final_score

	AudioManager.play_game_over_sound()
	run_ended.emit(final_score, survival_time)


func _physics_process(delta: float) -> void:
	if not is_run_active or GameManager.current_state != GameManager.State.PLAYING:
		return

	survival_time += delta

	# Grace Period Countdown
	if grace_time_remaining > 0.0:
		grace_time_remaining = maxf(0.0, grace_time_remaining - delta)
		grace_period_tick.emit(grace_time_remaining)
		if grace_time_remaining <= 0.0 and player:
			player.set_invulnerable(false)

	# Pulse Cooldown Tick
	if pulse_cooldown_remaining > 0.0:
		pulse_cooldown_remaining = maxf(0.0, pulse_cooldown_remaining - delta)
		pulse_cooldown_tick.emit(pulse_cooldown_remaining, pulse_cooldown)

	# Dynamic Wave Progression
	_wave_timer += delta
	if _wave_timer >= enemy_wave_interval and _enemies.size() < max_enemies:
		_wave_timer = 0.0
		_spawn_enemy(false)


func can_activate_pulse() -> bool:
	return is_run_active and pulse_cooldown_remaining <= 0.0 and GameManager.current_state == GameManager.State.PLAYING


func activate_pulse() -> bool:
	if not can_activate_pulse() or player == null:
		return false

	pulse_cooldown_remaining = pulse_cooldown
	pulse_triggered.emit(pulse_cooldown)

	# 1. Spawn Shockwave VFX
	var shockwave: Node2D = SHOCKWAVE_SCENE.instantiate()
	shockwave.position = player.position
	add_child(shockwave)

	# 2. Stun Nearby Enemies
	var player_pos := player.position
	for enemy in _enemies:
		if is_instance_valid(enemy):
			var dist := player_pos.distance_to(enemy.position)
			if dist <= pulse_stun_radius:
				enemy.apply_stun(pulse_stun_duration)

	# 3. Magnetically Attract Nearby Energy Shards
	for shard in _shards:
		if is_instance_valid(shard) and not shard.is_collected:
			var dist := player_pos.distance_to(shard.position)
			if dist <= pulse_attract_radius:
				shard.attract_to(player)

	AudioManager.play_pulse_sound()
	return true


func _spawn_initial_shards() -> void:
	for i in range(shard_count):
		var shard: EnergyShard = SHARD_SCENE.instantiate()
		shard.shard_collected.connect(_on_shard_collected)
		entities_container.add_child(shard)
		_shards.append(shard)
		_respawn_shard(shard)


func _on_shard_collected(shard: EnergyShard, score_value: int) -> void:
	if not is_run_active:
		return
	AudioManager.play_shard_sound()
	GameManager.current_score += score_value

	get_tree().create_timer(0.4).timeout.connect(func():
		if is_run_active and is_instance_valid(shard):
			_respawn_shard(shard)
	)


func _respawn_shard(shard: EnergyShard) -> void:
	if arena == null:
		return

	var valid_grid_pos := _get_random_cell_away_from_player(2.2)
	var world_pos := arena.grid_to_world(valid_grid_pos)
	shard.respawn_at(world_pos)


func _spawn_enemy(initial: bool) -> void:
	if arena == null or _enemies.size() >= max_enemies:
		return

	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.target_player = player
	enemy.hit_player.connect(_on_enemy_hit_player)

	# Fair starting speed (112 px/s) scaling smoothly with survival time
	var speed_multiplier := 1.0 + minf(0.45, survival_time * 0.006)
	enemy.base_speed = 112.0 * speed_multiplier

	var spawn_cell: Vector2i
	if initial:
		spawn_cell = _get_furthest_perimeter_cell()
	else:
		spawn_cell = _get_random_perimeter_cell()

	enemy.position = arena.grid_to_world(spawn_cell)
	entities_container.add_child(enemy)
	_enemies.append(enemy)

	if initial:
		enemy.apply_stun(1.8)

	enemies_updated.emit(_enemies.size(), max_enemies)


func _on_enemy_hit_player() -> void:
	# Invulnerability protection during initial grace period
	if player and player.is_invulnerable:
		return
	end_run()


func _get_random_cell_away_from_player(min_distance_tiles: float) -> Vector2i:
	if arena == null:
		return Vector2i(1, 1)

	var p_cell := Vector2i(4, 4)
	if player:
		p_cell = arena.world_to_grid(player.position)

	for attempt in range(30):
		var rx := randi_range(0, arena.grid_size.x - 1)
		var ry := randi_range(0, arena.grid_size.y - 1)
		var cell := Vector2i(rx, ry)
		var dist := Vector2(cell - p_cell).length()
		if dist >= min_distance_tiles:
			return cell

	return Vector2i(randi_range(0, arena.grid_size.x - 1), randi_range(0, arena.grid_size.y - 1))


func _get_furthest_perimeter_cell() -> Vector2i:
	if arena == null:
		return Vector2i(0, 0)
	var max_x := arena.grid_size.x - 1
	var max_y := arena.grid_size.y - 1
	var corners := [
		Vector2i(0, 0),
		Vector2i(max_x, 0),
		Vector2i(0, max_y),
		Vector2i(max_x, max_y)
	]
	return corners[randi_range(0, 3)]


func _get_random_perimeter_cell() -> Vector2i:
	if arena == null:
		return Vector2i(0, 0)

	var max_x := arena.grid_size.x - 1
	var max_y := arena.grid_size.y - 1
	var side := randi_range(0, 3)

	match side:
		0: return Vector2i(randi_range(0, max_x), 0)
		1: return Vector2i(max_x, randi_range(0, max_y))
		2: return Vector2i(randi_range(0, max_x), max_y)
		_: return Vector2i(0, randi_range(0, max_y))


func _clear_all_entities() -> void:
	for shard in _shards:
		if is_instance_valid(shard):
			shard.queue_free()
	_shards.clear()

	for enemy in _enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_enemies.clear()
