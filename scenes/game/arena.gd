class_name Arena
extends Node2D

## Pulse Clash - 2D Isometric Arena
## Renders a lightweight, high-performance neon arcade isometric grid and perimeter.

signal arena_clicked(grid_position: Vector2i, world_position: Vector2)

@export var grid_size: Vector2i = Vector2i(9, 9)
@export var tile_width: float = 64.0
@export var tile_height: float = 32.0

@export_group("Visuals")
@export var base_grid_color: Color = Color(0.12, 0.25, 0.45, 0.4)
@export var border_color: Color = Color(0.15, 0.85, 1.0, 0.9)
@export var pulse_glow_color: Color = Color(0.0, 0.95, 1.0, 0.25)
@export var cell_fill_color: Color = Color(0.04, 0.08, 0.16, 0.6)

var _pulse_time: float = 0.0
var _grid_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Center the arena grid around (0, 0) of the arena node
	_calculate_center_offset()
	queue_redraw()


func _process(delta: float) -> void:
	_pulse_time += delta * 2.0
	# Subtle boundary breathing effect (very low CPU usage)
	queue_redraw()


func _calculate_center_offset() -> void:
	# Center of the Cartesian grid in isometric space
	var center_cart := Vector2(float(grid_size.x) * 0.5, float(grid_size.y) * 0.5)
	_grid_offset = -IsometricHelper.cartesian_to_isometric(center_cart)


func _draw() -> void:
	_draw_isometric_grid()
	_draw_perimeter_boundary()
	_draw_center_pulse_marker()


func _draw_isometric_grid() -> void:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var corners := _get_tile_screen_corners(Vector2i(x, y))
			# Cell fill
			draw_polygon(corners, PackedColorArray([cell_fill_color, cell_fill_color, cell_fill_color, cell_fill_color]))
			# Cell wireframe
			for i in range(4):
				draw_line(corners[i], corners[(i + 1) % 4], base_grid_color, 1.0, true)


func _draw_perimeter_boundary() -> void:
	var top_left := _grid_to_world_raw(Vector2(0, 0))
	var top_right := _grid_to_world_raw(Vector2(float(grid_size.x), 0))
	var bottom_right := _grid_to_world_raw(Vector2(float(grid_size.x), float(grid_size.y)))
	var bottom_left := _grid_to_world_raw(Vector2(0, float(grid_size.y)))

	var boundary := PackedVector2Array([top_left, top_right, bottom_right, bottom_left])
	var pulse_alpha := 0.7 + sin(_pulse_time) * 0.2
	var dynamic_border := border_color
	dynamic_border.a = pulse_alpha

	# Glowing outer border
	for i in range(4):
		draw_line(boundary[i], boundary[(i + 1) % 4], dynamic_border, 2.5, true)


func _draw_center_pulse_marker() -> void:
	var center := _grid_offset + IsometricHelper.cartesian_to_isometric(Vector2(float(grid_size.x) * 0.5, float(grid_size.y) * 0.5))
	var glow_size := 8.0 + sin(_pulse_time * 1.5) * 2.0
	draw_circle(center, glow_size + 4.0, pulse_glow_color)
	draw_circle(center, 4.0, border_color)


func _get_tile_screen_corners(grid_pos: Vector2i) -> PackedVector2Array:
	var cart := Vector2(float(grid_pos.x), float(grid_pos.y))
	var top := _grid_to_world_raw(cart)
	var right := _grid_to_world_raw(cart + Vector2(1, 0))
	var bottom := _grid_to_world_raw(cart + Vector2(1, 1))
	var left := _grid_to_world_raw(cart + Vector2(0, 1))
	return PackedVector2Array([top, right, bottom, left])


func _grid_to_world_raw(cart_pos: Vector2) -> Vector2:
	return _grid_offset + IsometricHelper.cartesian_to_isometric(cart_pos)


## Public Helpers for Gameplay Entities

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var center_of_tile := Vector2(float(grid_pos.x) + 0.5, float(grid_pos.y) + 0.5)
	return _grid_offset + IsometricHelper.cartesian_to_isometric(center_of_tile)


func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local_iso := world_pos - _grid_offset
	var cart := IsometricHelper.isometric_to_cartesian(local_iso)
	return Vector2i(int(floor(cart.x)), int(floor(cart.y)))


func is_within_bounds(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < grid_size.x and grid_pos.y >= 0 and grid_pos.y < grid_size.y


func clamp_to_arena(world_pos: Vector2, margin: float = 0.25) -> Vector2:
	var local_iso := world_pos - _grid_offset
	var cart := IsometricHelper.isometric_to_cartesian(local_iso)
	var clamped_cart := Vector2(
		clampf(cart.x, margin, float(grid_size.x) - margin),
		clampf(cart.y, margin, float(grid_size.y) - margin)
	)
	return _grid_offset + IsometricHelper.cartesian_to_isometric(clamped_cart)


func is_world_inside_arena(world_pos: Vector2, margin: float = 0.0) -> bool:
	var local_iso := world_pos - _grid_offset
	var cart := IsometricHelper.isometric_to_cartesian(local_iso)
	return cart.x >= margin and cart.x <= float(grid_size.x) - margin and cart.y >= margin and cart.y <= float(grid_size.y) - margin


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_mouse_pos := to_local(event.position)
		var grid_pos := world_to_grid(local_mouse_pos)
		if is_within_bounds(grid_pos):
			var world_pos := grid_to_world(grid_pos)
			arena_clicked.emit(grid_pos, world_pos)
