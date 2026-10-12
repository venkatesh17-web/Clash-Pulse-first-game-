extends Control

## Pulse Clash - Main Orchestrator & UI Controller
## Coordinates Menu UI, In-Game HUD, Game-Over Overlay, 2D Isometric Arena, and GameplayManager.

# UI Components
@onready var title_menu: VBoxContainer = $UI/TitleMenu
@onready var high_score_label: Label = $UI/TitleMenu/HighScoreLabel
@onready var start_button: Button = $UI/TitleMenu/StartButton

@onready var in_game_hud: Control = $UI/InGameHUD
@onready var score_label: Label = $UI/InGameHUD/ScoreLabel
@onready var timer_label: Label = $UI/InGameHUD/TimerLabel
@onready var wave_label: Label = $UI/InGameHUD/WaveLabel
@onready var menu_button: Button = $UI/InGameHUD/MenuButton
@onready var pulse_button: Button = $UI/InGameHUD/PulseButton

@onready var game_over_overlay: Control = $UI/GameOverOverlay
@onready var final_score_label: Label = $UI/GameOverOverlay/Card/FinalScoreLabel
@onready var best_score_label: Label = $UI/GameOverOverlay/Card/BestScoreLabel
@onready var time_survived_label: Label = $UI/GameOverOverlay/Card/TimeSurvivedLabel
@onready var restart_button: Button = $UI/GameOverOverlay/Card/RestartButton
@onready var game_over_menu_button: Button = $UI/GameOverOverlay/Card/GameOverMenuButton

@onready var status_label: Label = $UI/StatusLabel

# Gameplay Nodes
@onready var arena: Arena = $IsometricWorldPlaceholder/Arena
@onready var player: Player = $IsometricWorldPlaceholder/Player
@onready var gameplay_manager: GameplayManager = $IsometricWorldPlaceholder/GameplayManager

var _shake_intensity: float = 0.0
var _original_world_pos: Vector2 = Vector2(360, 640)


func trigger_screenshake(amount: float) -> void:
	_shake_intensity = maxf(_shake_intensity, amount)


func _ready() -> void:
	_update_ui()
	_apply_state(GameManager.current_state)

	# Global state connections
	GameManager.high_score_updated.connect(_on_high_score_updated)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.game_state_changed.connect(_on_game_state_changed)

	# Button connections
	start_button.pressed.connect(_on_start_button_pressed)
	restart_button.pressed.connect(_on_start_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	game_over_menu_button.pressed.connect(_on_menu_button_pressed)
	pulse_button.pressed.connect(_on_pulse_button_pressed)

	# GameplayManager connections
	if gameplay_manager:
		gameplay_manager.run_ended.connect(_on_run_ended)
		gameplay_manager.pulse_cooldown_tick.connect(_on_pulse_cooldown_tick)
		gameplay_manager.enemies_updated.connect(_on_enemies_updated)
		gameplay_manager.grace_period_tick.connect(_on_grace_period_tick)

	# Automated CLI verification hooks
	if OS.get_cmdline_user_args().has("--test-milestone-001") or OS.has_environment("TEST_MILESTONE_001"):
		_run_self_test()
	elif OS.get_cmdline_user_args().has("--test-milestone-002") or OS.has_environment("TEST_MILESTONE_002"):
		_run_milestone_002_test()
	elif OS.get_cmdline_user_args().has("--test-core-loop") or OS.has_environment("TEST_CORE_LOOP"):
		_run_core_loop_test()


func _process(delta: float) -> void:
	# Screen shake update
	if _shake_intensity > 0.0:
		_shake_intensity = maxf(0.0, _shake_intensity - 26.0 * delta)
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_intensity
		$IsometricWorldPlaceholder.position = _original_world_pos + offset
	else:
		$IsometricWorldPlaceholder.position = _original_world_pos

	if gameplay_manager and gameplay_manager.is_run_active:
		var total_sec := int(gameplay_manager.survival_time)
		var mins := total_sec / 60
		var secs := total_sec % 60
		timer_label.text = "TIME: %02d:%02d" % [mins, secs]


func _update_ui() -> void:
	high_score_label.text = "HIGH SCORE: %d" % GameManager.high_score
	score_label.text = "SCORE: %d" % GameManager.current_score
	status_label.text = "Offline-First • 60 FPS"


func _apply_state(state: GameManager.State) -> void:
	match state:
		GameManager.State.MENU:
			title_menu.visible = true
			in_game_hud.visible = false
			game_over_overlay.visible = false
			status_label.text = "Offline-First • 60 FPS"
			if player:
				player.reset_to_center()
		GameManager.State.PLAYING:
			title_menu.visible = false
			in_game_hud.visible = true
			game_over_overlay.visible = false
			status_label.text = "Arena Active • Drag to Glide"
		GameManager.State.PAUSED:
			status_label.text = "Game Paused"
		GameManager.State.GAME_OVER:
			title_menu.visible = false
			in_game_hud.visible = false
			game_over_overlay.visible = true
			status_label.text = "Run Ended • Tap to Restart"


func _on_high_score_updated(new_score: int) -> void:
	high_score_label.text = "HIGH SCORE: %d" % new_score


func _on_score_changed(new_score: int) -> void:
	score_label.text = "SCORE: %d" % new_score


func _on_game_state_changed(new_state: GameManager.State) -> void:
	_apply_state(new_state)


func _on_start_button_pressed() -> void:
	GameManager.current_score = 0
	GameManager.current_state = GameManager.State.PLAYING
	if gameplay_manager:
		gameplay_manager.start_new_run()


func _on_menu_button_pressed() -> void:
	if gameplay_manager:
		gameplay_manager.is_run_active = false
	GameManager.current_state = GameManager.State.MENU


func _on_pulse_button_pressed() -> void:
	if gameplay_manager:
		var activated := gameplay_manager.activate_pulse()
		if activated:
			trigger_screenshake(7.0)
			status_label.text = "Shockwave Activated!"


func _on_pulse_cooldown_tick(remaining: float, _total: float) -> void:
	if remaining <= 0.0:
		pulse_button.disabled = false
		pulse_button.text = "PULSE"
		pulse_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		pulse_button.disabled = true
		pulse_button.text = "%.1fs" % remaining
		pulse_button.modulate = Color(0.65, 0.75, 0.85, 0.65)


func _on_grace_period_tick(remaining: float) -> void:
	if remaining > 0.0:
		status_label.text = "SHIELD ACTIVE (%.1fs) • GLIDE TO MOVE" % remaining
	elif GameManager.current_state == GameManager.State.PLAYING:
		status_label.text = "Arena Active • Drag to Glide"


func _on_enemies_updated(active: int, max_count: int) -> void:
	wave_label.text = "CHASERS: %d/%d" % [active, max_count]


func _on_run_ended(final_score: int, survived_seconds: float) -> void:
	trigger_screenshake(14.0)
	final_score_label.text = "FINAL SCORE: %d" % final_score
	best_score_label.text = "BEST SCORE: %d" % GameManager.high_score

	var total_sec := int(survived_seconds)
	var mins := total_sec / 60
	var secs := total_sec % 60
	time_survived_label.text = "SURVIVED: %02d:%02d" % [mins, secs]


# ---------------------------------------------------------------------------
# AUTOMATED TEST HARNESSES
# ---------------------------------------------------------------------------

func _run_self_test() -> void:
	print("--- BEGIN AUTOMATED SELF TEST ---")
	assert(arena != null, "Arena must not be null")
	assert(arena is Node2D, "Arena must be a Node2D")
	print("[PASS] Arena is valid Node2D")

	var coord := Vector2i(2, 3)
	var world := arena.grid_to_world(coord)
	var roundtrip := arena.world_to_grid(world)
	assert(roundtrip == coord, "Grid conversion mismatch: %s != %s" % [roundtrip, coord])
	print("[PASS] Arena coordinate conversions verified for (2, 3)")

	_on_start_button_pressed()
	assert(GameManager.current_state == GameManager.State.PLAYING, "State should be PLAYING")
	assert(title_menu.visible == false, "Menu should be hidden")
	assert(in_game_hud.visible == true, "HUD should be visible")
	print("[PASS] StartButton state transition verified")

	_on_menu_button_pressed()
	assert(GameManager.current_state == GameManager.State.MENU, "State should be MENU")
	assert(title_menu.visible == true, "Menu should be visible")
	assert(in_game_hud.visible == false, "HUD should be hidden")
	print("[PASS] Menu return transition verified")

	print("--- ALL VERIFICATION TESTS PASSED ---")
	get_tree().quit(0)


func _run_milestone_002_test() -> void:
	print("--- BEGIN MILESTONE 002 TEST SUITE ---")
	assert(player != null, "Player must not be null")
	assert(player is CharacterBody2D, "Player must be a CharacterBody2D")
	assert(player.visuals != null, "Player visuals node must exist")
	assert(player.trail != null, "Player trail Line2D must exist")
	print("[PASS] Player entity structure verified")

	assert(player.position == Vector2.ZERO, "Player must start centered at (0, 0)")
	assert(player.is_moving == false, "Player must start stationary")
	print("[PASS] Player starts centered and stationary")

	GameManager.current_state = GameManager.State.MENU
	player.set_destination(Vector2(100, 100))
	player._physics_process(0.016)
	assert(player.position == Vector2.ZERO, "Player must not move while on MENU")
	print("[PASS] Menu state gate verified")

	_on_start_button_pressed()
	assert(GameManager.current_state == GameManager.State.PLAYING, "Game state must be PLAYING")

	var valid_target := Vector2(150, 75)
	player.set_destination(valid_target)
	for i in range(10):
		player._physics_process(0.016)
	assert(player.is_moving == true, "Player should be in motion")
	assert(player.position.length() > 0.0, "Player should have moved away from center")
	print("[PASS] Continuous movement physics verified")

	_on_menu_button_pressed()
	assert(GameManager.current_state == GameManager.State.MENU, "State must be MENU")
	assert(player.position == Vector2.ZERO, "Player must reset to center")
	print("[PASS] Return to menu verified")

	print("--- ALL MILESTONE 002 TESTS PASSED SUCCESSFULLY ---")
	get_tree().quit(0)


func _run_core_loop_test() -> void:
	print("--- BEGIN CORE GAMEPLAY LOOP VERIFICATION ---")
	assert(gameplay_manager != null, "GameplayManager must exist")
	assert(arena != null, "Arena must exist")
	assert(player != null, "Player must exist")

	# 1. Start Run
	_on_start_button_pressed()
	assert(gameplay_manager.is_run_active == true, "GameplayManager must be active")
	assert(gameplay_manager._shards.size() == 6, "Must spawn exactly 6 shards")
	assert(gameplay_manager._enemies.size() >= 1, "Must spawn at least 1 enemy")
	print("[PASS] New run started: 6 shards and initial enemy spawned")

	# 2. Shard Collection & Scoring
	var initial_score := GameManager.current_score
	var shard: EnergyShard = gameplay_manager._shards[0]
	shard.collect()
	assert(GameManager.current_score == initial_score + 10, "Collecting shard must award 10 points")
	print("[PASS] Shard collection awarded +10 points (Current: %d)" % GameManager.current_score)

	# 3. Pulse Activation & Enemy Stun
	var enemy: Enemy = gameplay_manager._enemies[0]
	enemy.position = player.position + Vector2(50, 0) # Within stun radius
	var pulse_ok := gameplay_manager.activate_pulse()
	assert(pulse_ok == true, "Pulse activation should succeed")
	assert(enemy.is_stunned == true, "Enemy within stun radius must be stunned by Pulse")
	assert(gameplay_manager.pulse_cooldown_remaining > 0.0, "Pulse cooldown must be active")
	assert(gameplay_manager.can_activate_pulse() == false, "Cannot re-pulse while cooldown active")
	print("[PASS] Pulse ability triggered: Shockwave spawned, enemy stunned, cooldown active")

	# 4. Enemy Contact & Game-Over Sequence (Grace period bypassed for test)
	player.set_invulnerable(false)
	gameplay_manager.grace_time_remaining = 0.0
	enemy.is_stunned = false
	enemy.hit_player.emit()
	assert(gameplay_manager.is_run_active == false, "Enemy contact must end the run")
	assert(GameManager.current_state == GameManager.State.GAME_OVER, "State must transition to GAME_OVER")
	assert(game_over_overlay.visible == true, "Game-Over overlay must be visible")
	print("[PASS] Enemy contact ends run, GAME_OVER state activated, overlay displayed")

	# 5. Play Again / Quick Restart
	restart_button.emit_signal("pressed")
	assert(GameManager.current_state == GameManager.State.PLAYING, "Quick restart must re-enter PLAYING")
	assert(game_over_overlay.visible == false, "Game-Over overlay must hide on restart")
	assert(gameplay_manager.is_run_active == true, "New run must be active")
	assert(GameManager.current_score == 0, "Score must reset to 0 on restart")
	print("[PASS] Quick restart successfully initiated new run with fresh state")

	# 6. Return to Main Menu
	menu_button.emit_signal("pressed")
	assert(GameManager.current_state == GameManager.State.MENU, "Must return to MENU")
	assert(title_menu.visible == true, "Title menu restored")
	assert(in_game_hud.visible == false, "HUD hidden")
	print("[PASS] Menu return verified")

	print("--- ALL CORE GAMEPLAY LOOP TESTS PASSED SUCCESSFULLY ---")
	get_tree().quit(0)
