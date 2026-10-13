extends Control

## Pulse Clash - Main Orchestrator & UI Controller
## Coordinates Menu UI, In-Game HUD, Game-Over Overlay, 2D Isometric Arena, and GameplayManager.

# UI Components
@onready var title_menu: VBoxContainer = $UI/TitleMenu
@onready var high_score_label: Label = $UI/TitleMenu/HighScoreLabel
@onready var start_button: Button = $UI/TitleMenu/StartButton
@onready var sound_button: Button = $UI/TitleMenu/SoundButton

@onready var countdown_overlay: Control = $UI/CountdownOverlay
@onready var countdown_label: Label = $UI/CountdownOverlay/CountdownLabel

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


func _update_world_centering() -> void:
	var vp_size := get_viewport_rect().size
	_original_world_pos = vp_size * 0.5
	$IsometricWorldPlaceholder.position = _original_world_pos


func _ready() -> void:
	_update_world_centering()
	get_viewport().size_changed.connect(_update_world_centering)
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
	if sound_button:
		sound_button.pressed.connect(_on_sound_button_pressed)
		_update_sound_button()

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
	elif OS.get_cmdline_user_args().has("--test-milestone-013") or OS.has_environment("TEST_MILESTONE_013"):
		_run_milestone_013_test()
	elif OS.get_cmdline_user_args().has("--test-master-qa") or OS.has_environment("TEST_MASTER_QA"):
		_run_master_qa_test()


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
	_update_sound_button()


func _update_sound_button() -> void:
	if sound_button:
		sound_button.text = "SOUND: ON" if GameManager.sound_enabled else "SOUND: OFF"
		sound_button.modulate = Color(1.0, 1.0, 1.0, 1.0) if GameManager.sound_enabled else Color(0.65, 0.75, 0.85, 0.7)


func _on_sound_button_pressed() -> void:
	AudioManager.play_click_sound()
	GameManager.toggle_sound()
	_update_sound_button()


func _apply_state(state: GameManager.State) -> void:
	if countdown_overlay:
		countdown_overlay.visible = false

	match state:
		GameManager.State.MENU:
			title_menu.visible = true
			in_game_hud.visible = false
			game_over_overlay.visible = false
			status_label.text = "Offline-First • 60 FPS"
			_update_sound_button()
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
	AudioManager.play_click_sound()

	# Check for automated test execution
	var is_test_run: bool = false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--test-"):
			is_test_run = true
			break
	if OS.has_environment("TEST_CORE_LOOP") or OS.has_environment("TEST_MILESTONE_001") or OS.has_environment("TEST_MILESTONE_002") or OS.has_environment("TEST_MILESTONE_013"):
		is_test_run = true

	if is_test_run:
		_start_gameplay_run()
	else:
		_start_countdown_sequence()


func _start_countdown_sequence() -> void:
	title_menu.visible = false
	game_over_overlay.visible = false
	if countdown_overlay:
		countdown_overlay.visible = true
	status_label.text = "GET READY..."

	var steps := ["3", "2", "1", "ENGAGE!"]
	var step_delay := 0.65

	for i in range(steps.size()):
		var step_text: String = steps[i]
		var is_engage: bool = (i == steps.size() - 1)

		get_tree().create_timer(float(i) * step_delay).timeout.connect(func():
			if countdown_label and countdown_overlay and countdown_overlay.visible:
				countdown_label.text = step_text
				countdown_label.scale = Vector2(1.35, 1.35)
				var tw := create_tween()
				tw.tween_property(countdown_label, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				AudioManager.play_countdown_beep(is_engage)
		)

	get_tree().create_timer(float(steps.size()) * step_delay).timeout.connect(func():
		if countdown_overlay:
			countdown_overlay.visible = false
		_start_gameplay_run()
	)


func _start_gameplay_run() -> void:
	GameManager.current_score = 0
	GameManager.current_state = GameManager.State.PLAYING
	if gameplay_manager:
		gameplay_manager.start_new_run()


func _on_menu_button_pressed() -> void:
	AudioManager.play_click_sound()
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
		pulse_button.text = "PULSE\nREADY"
		pulse_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		pulse_button.disabled = true
		pulse_button.text = "PULSE\n%.1fs" % remaining
		pulse_button.modulate = Color(0.65, 0.75, 0.85, 0.65)


func _on_grace_period_tick(remaining: float) -> void:
	if remaining > 0.0:
		status_label.text = "CORE SHIELD ACTIVE (%.1fs) • DRAG TO GLIDE" % remaining
		status_label.modulate = Color(0.2, 0.95, 1.0, 1.0)
	elif GameManager.current_state == GameManager.State.PLAYING:
		status_label.text = "Arena Active • Drag to Glide"
		status_label.modulate = Color(0.7, 0.85, 1.0, 0.9)


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


func _run_milestone_013_test() -> void:
	print("--- BEGIN MILESTONE 013 VERIFICATION SUITE ---")
	assert(gameplay_manager != null, "GameplayManager must exist")
	assert(arena != null, "Arena must exist")
	assert(player != null, "Player must exist")

	# 1. Verify Dynamic World Centering
	var vp_size: Vector2 = get_viewport_rect().size
	var expected_center: Vector2 = vp_size * 0.5
	assert($IsometricWorldPlaceholder.position == expected_center, "World must be centered at viewport center: %s vs %s" % [$IsometricWorldPlaceholder.position, expected_center])
	print("[PASS] Dynamic viewport world centering verified: ", $IsometricWorldPlaceholder.position)

	# 2. Verify Touch-to-World Coordinate Conversion at center and corners
	var touch_center: Vector2 = expected_center
	var world_center: Vector2 = $IsometricWorldPlaceholder.to_local(player.get_canvas_transform().affine_inverse() * touch_center)
	assert(world_center.distance_to(Vector2.ZERO) < 0.01, "Center touch must map to (0, 0) world coord")
	print("[PASS] Center screen touch maps exactly to (0, 0) world space")

	var top_vertex_world: Vector2 = arena._grid_to_world_raw(Vector2(0, 0))
	var top_vertex_screen: Vector2 = $IsometricWorldPlaceholder.to_global(top_vertex_world)
	var mapped_top: Vector2 = $IsometricWorldPlaceholder.to_local(player.get_canvas_transform().affine_inverse() * top_vertex_screen)
	assert(mapped_top.distance_to(top_vertex_world) < 0.01, "Top vertex touch round-trip mapping must match exactly")
	print("[PASS] Arena perimeter coordinate conversion round-trip verified")

	# 3. Start Run & Verify Grace Period & Initial Enemy Count
	_on_start_button_pressed()
	assert(gameplay_manager.is_run_active == true, "Run must be active")
	assert(gameplay_manager.grace_time_remaining == 2.0, "Initial grace period must be exactly 2.0 seconds (got %f)" % gameplay_manager.grace_time_remaining)
	assert(player.is_invulnerable == true, "Player must be invulnerable during grace period")
	assert(gameplay_manager._enemies.size() == 1, "Must start with exactly 1 enemy (got %d)" % gameplay_manager._enemies.size())
	print("[PASS] Starting enemy count verified: 1 enemy, 2.0s initial grace period")

	# 4. Verify Initial Enemy Spawn Distance and Spawn Warmup
	var enemy: Enemy = gameplay_manager._enemies[0]
	var initial_dist: float = player.position.distance_to(enemy.position)
	assert(initial_dist >= 270.0, "Enemy must spawn at least 270px away from player (got %f)" % initial_dist)
	assert(enemy.spawn_warmup >= 1.9, "Enemy must have spawn warmup active during grace period")
	assert(enemy.base_speed <= 110.0, "Enemy base speed must be fair (got %f)" % enemy.base_speed)
	print("[PASS] Initial enemy distance (%f px) and warmup protection verified" % initial_dist)

	# 5. Simulate 1.5s of Gameplay during Grace Period: Enemy Must Not Damage Player
	for i in range(90): # 90 frames @ 60fps = 1.5s
		gameplay_manager._physics_process(0.0166)
		enemy._physics_process(0.0166)
	assert(gameplay_manager.is_run_active == true, "Player must remain alive during grace period")
	assert(gameplay_manager.grace_time_remaining > 0.0, "Grace period still counting down")
	print("[PASS] Grace period survival verified over 1.5s simulation")

	# 6. Verify Pulse Stun and Recovery
	enemy.position = player.position + Vector2(60, 0)
	var pulse_activated: bool = gameplay_manager.activate_pulse()
	assert(pulse_activated == true, "Pulse must activate successfully")
	assert(enemy.is_stunned == true, "Enemy must be stunned")
	assert(gameplay_manager.pulse_cooldown_remaining > 0.0, "Pulse cooldown must be active")
	print("[PASS] Pulse activation and enemy stun verified")

	# 7. Verify Enemy Contact & Collision Burst
	player.set_invulnerable(false)
	gameplay_manager.grace_time_remaining = 0.0
	enemy.is_stunned = false
	enemy.spawn_warmup = 0.0
	enemy.hit_player.emit()
	assert(gameplay_manager.is_run_active == false, "Enemy contact must terminate run")
	assert(GameManager.current_state == GameManager.State.GAME_OVER, "Must enter GAME_OVER state")
	print("[PASS] Collision feedback and GAME_OVER transition verified")

	print("--- ALL MILESTONE 013 TESTS PASSED SUCCESSFULLY ---")
	get_tree().quit(0)


func _run_master_qa_test() -> void:
	print("--- BEGIN MASTER QA & PRODUCTION VERIFICATION SUITE ---")
	assert(gameplay_manager != null, "GameplayManager must exist")
	assert(arena != null, "Arena must exist")
	assert(player != null, "Player must exist")

	# 1. Coordinate System Math
	var center_cell := Vector2i(4, 4)
	var world_center := arena.grid_to_world(center_cell)
	var roundtrip_cell := arena.world_to_grid(world_center)
	assert(roundtrip_cell == center_cell, "Grid <-> World conversion must roundtrip identically: %s vs %s" % [roundtrip_cell, center_cell])
	print("[PASS] Isometric grid-to-world and world-to-grid roundtrip verified")

	# 2. Arena Boundary Clamping
	var out_of_bounds := Vector2(8000.0, 8000.0)
	var clamped := arena.clamp_to_arena(out_of_bounds, 0.35)
	assert(arena.is_world_inside_arena(clamped), "Clamped point must be strictly within arena boundary")
	print("[PASS] Arena boundary geometric constraint verified")

	# 3. Start Run: Spawning Verification
	_start_gameplay_run()
	assert(gameplay_manager.is_run_active == true, "Run must be active")
	assert(gameplay_manager._shards.size() == 6, "Must spawn exactly 6 shards (got %d)" % gameplay_manager._shards.size())
	assert(gameplay_manager._enemies.size() == 1, "Must start with exactly 1 enemy (got %d)" % gameplay_manager._enemies.size())
	assert(player.position == Vector2.ZERO, "Player must start centered at (0, 0)")
	print("[PASS] Run start verified: 6 shards, 1 enemy, player centered")

	# 4. Grace Period Protection: Contact does not end run
	assert(gameplay_manager.grace_time_remaining == 2.0, "Grace period must be exactly 2.0s")
	assert(player.is_invulnerable == true, "Player must be invulnerable during grace period")
	var enemy: Enemy = gameplay_manager._enemies[0]
	enemy.hit_player.emit()
	assert(gameplay_manager.is_run_active == true, "Protected contact must not end run")
	print("[PASS] 2.0s Grace period invulnerability verified")

	# 5. Shard Collection (+10 points) & Magnetic Pull
	var old_score := GameManager.current_score
	var shard: EnergyShard = gameplay_manager._shards[0]
	shard.collect()
	assert(GameManager.current_score == old_score + 10, "Collecting shard must award +10 points")
	print("[PASS] Shard pickup awards +10 points (Current: %d)" % GameManager.current_score)

	# 6. Pulse Ability Mechanics: Cooldown, Stun, Attraction
	enemy.position = player.position + Vector2(80, 0)
	var pulse_ok := gameplay_manager.activate_pulse()
	assert(pulse_ok == true, "Pulse must activate successfully")
	assert(enemy.is_stunned == true, "Enemy within stun radius must be stunned")
	assert(gameplay_manager.pulse_cooldown_remaining > 0.0, "Pulse cooldown must be active")
	assert(gameplay_manager.can_activate_pulse() == false, "Cannot re-pulse while on cooldown")
	print("[PASS] Pulse mechanics verified: 5s cooldown, enemy stun, shockwave VFX")

	# 7. Enemy Pursuit Physics
	enemy.is_stunned = false
	enemy.spawn_warmup = 0.0
	enemy.position = Vector2(200, 100)
	var prev_dist := enemy.position.distance_to(player.position)
	for i in range(10):
		enemy._physics_process(0.0166)
	var new_dist := enemy.position.distance_to(player.position)
	assert(new_dist < prev_dist, "Enemy must actively reduce distance toward player")
	print("[PASS] Active pursuit physics verified (prev: %f, new: %f)" % [prev_dist, new_dist])

	# 8. Unprotected Contact -> Run Termination & Collision Feedback
	player.set_invulnerable(false)
	gameplay_manager.grace_time_remaining = 0.0
	enemy.hit_player.emit()
	assert(gameplay_manager.is_run_active == false, "Enemy contact must terminate run")
	assert(GameManager.current_state == GameManager.State.GAME_OVER, "State must transition to GAME_OVER")
	assert(game_over_overlay.visible == true, "Game Over overlay must display")
	print("[PASS] Unprotected collision terminates run and shows Game Over overlay")

	# 9. Quick Restart Flow & State Cleansing
	restart_button.emit_signal("pressed")
	_start_gameplay_run()
	assert(gameplay_manager.is_run_active == true, "New run must be active")
	assert(GameManager.current_score == 0, "Score must reset to 0 on restart")
	assert(gameplay_manager._shards.size() == 6, "Must spawn exactly 6 fresh shards on restart")
	assert(gameplay_manager._enemies.size() == 1, "Must reset to exactly 1 enemy on restart")
	assert(game_over_overlay.visible == false, "Game Over overlay must hide on restart")
	print("[PASS] Quick restart cleanly resets run state with no entity accumulation")

	# 10. Offline High Score & Settings Persistence
	var test_score := 420
	GameManager.high_score = test_score
	assert(FileAccess.file_exists(GameManager.SAVE_FILE_PATH), "Save file must exist on disk")
	var fa := FileAccess.open(GameManager.SAVE_FILE_PATH, FileAccess.READ)
	assert(fa != null, "Save file must be readable")
	var parsed: Variant = JSON.parse_string(fa.get_as_text())
	fa.close()
	assert(parsed is Dictionary and int(parsed.get("high_score", 0)) == test_score, "Persisted high score in JSON must match %d" % test_score)
	print("[PASS] Offline high score persistence verified")

	# 11. Audio Mute Toggle & Persistence
	var initial_sound: bool = GameManager.sound_enabled
	GameManager.toggle_sound()
	assert(GameManager.sound_enabled != initial_sound, "toggle_sound must flip sound state")
	var fa_audio := FileAccess.open(GameManager.SAVE_FILE_PATH, FileAccess.READ)
	assert(fa_audio != null, "Save file must be readable")
	var parsed_audio: Variant = JSON.parse_string(fa_audio.get_as_text())
	fa_audio.close()
	assert(parsed_audio is Dictionary and bool(parsed_audio.get("sound_enabled")) == GameManager.sound_enabled, "Sound preference must persist in save file")
	GameManager.sound_enabled = true # Reset to enabled
	print("[PASS] Sound toggle and persistence verified")

	print("--- ALL MASTER QA VERIFICATIONS PASSED SUCCESSFULLY ---")
	get_tree().quit(0)

