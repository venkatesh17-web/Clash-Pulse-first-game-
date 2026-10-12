class_name Player
extends CharacterBody2D

## Pulse Clash - Player Entity
## High-visibility cyan energy orb with continuous tap-and-drag isometric movement.

signal destination_reached(at_position: Vector2)
signal movement_started(from_position: Vector2, to_position: Vector2)

@export_group("Movement")
@export var move_speed: float = 340.0
@export var stopping_distance: float = 10.0
@export var acceleration: float = 2400.0
@export var deceleration: float = 3000.0
@export var boundary_margin: float = 0.35

@export_group("Visuals")
@export var enable_trail: bool = true
@export var trail_length: int = 16
@export var trail_min_distance: float = 4.0

var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_invulnerable: bool = false

var _is_dragging: bool = false
var _arena: Arena = null

@onready var visuals: Node2D = $Visuals
@onready var trail: Line2D = $Trail
@onready var orb_renderer: Node2D = $Visuals/OrbRenderer


func _ready() -> void:
	target_position = position
	_find_arena()
	if trail:
		trail.top_level = true
		trail.clear_points()


func _find_arena() -> void:
	if get_parent():
		_arena = get_parent().get_node_or_null("Arena") as Arena
	if _arena == null and is_inside_tree():
		_arena = get_tree().root.find_child("Arena", true, false) as Arena


func set_invulnerable(val: bool) -> void:
	is_invulnerable = val
	if orb_renderer and "is_invulnerable" in orb_renderer:
		orb_renderer.is_invulnerable = val


func _unhandled_input(event: InputEvent) -> void:
	if GameManager.current_state != GameManager.State.PLAYING:
		_is_dragging = false
		return

	# Desktop Mouse Input
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_update_destination_from_event(event.position)
			else:
				_is_dragging = false
				# Stop smoothly near current position on finger/mouse release
				target_position = position

	elif event is InputEventMouseMotion:
		if _is_dragging:
			_update_destination_from_event(event.position)

	# Mobile Touchscreen Input
	elif event is InputEventScreenTouch:
		if event.pressed:
			_is_dragging = true
			_update_destination_from_event(event.position)
		else:
			_is_dragging = false
			# Stop smoothly near current position on touch release
			target_position = position

	elif event is InputEventScreenDrag:
		_is_dragging = true
		_update_destination_from_event(event.position)


func _update_destination_from_event(screen_pos: Vector2) -> void:
	var parent_node := get_parent()
	if parent_node == null:
		return
	
	# Accurately transform screen/canvas coordinate to parent world coordinate
	var world_coord := get_canvas_transform().affine_inverse() * screen_pos
	var local_dest: Vector2 = parent_node.to_local(world_coord)
	set_destination(local_dest)


func set_destination(dest: Vector2) -> void:
	if _arena != null:
		target_position = _arena.clamp_to_arena(dest, boundary_margin)
	else:
		target_position = dest


func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.State.PLAYING:
		velocity = Vector2.ZERO
		is_moving = false
		_is_dragging = false
		return

	var to_target := target_position - position
	var dist := to_target.length()

	if dist > stopping_distance:
		var was_moving := is_moving
		is_moving = true

		if not was_moving:
			movement_started.emit(position, target_position)
			visuals.scale = Vector2(1.22, 0.82)

		var move_dir := to_target.normalized()
		var desired_vel := move_dir * move_speed
		velocity = velocity.move_toward(desired_vel, acceleration * delta)
		position += velocity * delta

		# Arena boundary clamping
		if _arena != null:
			position = _arena.clamp_to_arena(position, boundary_margin)

		# Dynamic rotation and stretch along movement vector
		visuals.rotation = lerp_angle(visuals.rotation, move_dir.angle(), delta * 14.0)
		var speed_ratio := clampf(velocity.length() / move_speed, 0.0, 1.0)
		var target_scale := Vector2(1.0 + 0.14 * speed_ratio, 1.0 - 0.10 * speed_ratio)
		visuals.scale = visuals.scale.lerp(target_scale, delta * 10.0)

		_update_trail(true)

	else:
		# Stopping / Resting
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

		if is_moving:
			is_moving = false
			destination_reached.emit(position)
			visuals.scale = Vector2(0.85, 1.18)

		visuals.scale = visuals.scale.lerp(Vector2.ONE, delta * 8.0)
		visuals.rotation = lerp_angle(visuals.rotation, 0.0, delta * 6.0)

		_update_trail(false)


func _update_trail(moving: bool) -> void:
	if not enable_trail or trail == null:
		return

	trail.global_position = Vector2.ZERO
	trail.global_rotation = 0.0

	if moving:
		var current_pos := global_position
		if trail.get_point_count() == 0 or current_pos.distance_to(trail.get_point_position(trail.get_point_count() - 1)) >= trail_min_distance:
			trail.add_point(current_pos)
		while trail.get_point_count() > trail_length:
			trail.remove_point(0)
	else:
		if trail.get_point_count() > 0:
			trail.remove_point(0)


func reset_to_center() -> void:
	position = Vector2.ZERO
	target_position = Vector2.ZERO
	velocity = Vector2.ZERO
	is_moving = false
	_is_dragging = false
	set_invulnerable(false)
	if visuals:
		visuals.scale = Vector2.ONE
		visuals.rotation = 0.0
	if trail:
		trail.clear_points()
