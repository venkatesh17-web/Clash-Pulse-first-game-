class_name Enemy
extends CharacterBody2D

## Pulse Clash - Pursuer Enemy Entity
## Hunts the player continuously. Stunnable via signature Pulse ability.

signal hit_player

@export var base_speed: float = 135.0
@export var acceleration: float = 420.0

var is_stunned: bool = false
var stun_timer: float = 0.0
var spawn_warmup: float = 0.0
var target_player: Node2D = null

var _arena: Arena = null

@onready var visuals: Node2D = $Visuals
@onready var hit_area: Area2D = $HitArea


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	_find_arena()
	if hit_area:
		hit_area.body_entered.connect(_on_hit_area_body_entered)


func _find_arena() -> void:
	if get_parent():
		_arena = get_parent().get_node_or_null("Arena") as Arena
	if _arena == null and is_inside_tree():
		_arena = get_tree().root.find_child("Arena", true, false) as Arena


func start_spawn_warmup(duration: float) -> void:
	spawn_warmup = duration
	velocity = Vector2.ZERO
	if visuals == null:
		visuals = get_node_or_null("Visuals")
	if visuals and visuals.has_method("set_spawning"):
		visuals.set_spawning(true)


func apply_stun(duration: float = 1.5) -> void:
	is_stunned = true
	stun_timer = duration
	velocity = Vector2.ZERO
	if visuals == null:
		visuals = get_node_or_null("Visuals")
	if visuals and visuals.has_method("set_stunned"):
		visuals.set_stunned(true)


func trigger_hit_flash() -> void:
	if visuals == null:
		visuals = get_node_or_null("Visuals")
	if visuals and visuals.has_method("trigger_hit_flash"):
		visuals.trigger_hit_flash()


func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.State.PLAYING:
		velocity = Vector2.ZERO
		return

	# Spawn warmup countdown (initial perimeter materialization)
	if spawn_warmup > 0.0:
		spawn_warmup -= delta
		velocity = Vector2.ZERO
		if spawn_warmup <= 0.0:
			if visuals and visuals.has_method("set_spawning"):
				visuals.set_spawning(false)
		return

	# Stun countdown
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
			if visuals.has_method("set_stunned"):
				visuals.set_stunned(false)
		return

	# Pursuit logic with smooth inertia steering
	if target_player != null and is_instance_valid(target_player):
		var to_player := target_player.global_position - global_position
		var dir := to_player.normalized()
		var desired_vel := dir * base_speed
		velocity = velocity.move_toward(desired_vel, acceleration * delta)
		position += velocity * delta

		# Boundary constraint
		if _arena != null:
			position = _arena.clamp_to_arena(position, 0.35)

		# Orient visuals towards player
		if dir.length() > 0.1:
			visuals.rotation = lerp_angle(visuals.rotation, dir.angle(), delta * 8.0)


func _on_hit_area_body_entered(body: Node2D) -> void:
	if is_stunned or spawn_warmup > 0.0:
		return
	if body is Player or body.name == "Player":
		trigger_hit_flash()
		hit_player.emit()
