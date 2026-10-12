class_name Arena
extends Node2D

## Pulse Clash - 2D Isometric Arena
## Renders a high-contrast, clearly visible neon arcade isometric diamond arena.

signal arena_clicked(grid_position: Vector2i, world_position: Vector2)

@export var grid_size: Vector2i = Vector2i(9, 9)
@export var tile_width: float = 76.0
@export var tile_height: float = 38.0

@export_group("Visuals")
@export var tile_color_a: Color = Color(0.065, 0.11, 0.22, 0.95)
@export var tile_color_b: Color = Color(0.045, 0.08, 0.16, 0.95)
@export var base_grid_color: Color = Color(0.12, 0.52, 0.88, 0.75)
@export var border_color: Color = Color(0.05, 0.92, 1.0, 1.0)
@export var border_glow_color: Color = Color(0.0, 0.75, 1.0, 0.35)
@export var pulse_glow_color: Color = Color(0.0, 0.95, 1.0, 0.3)

var _pulse_time: float = 0.0
var _grid_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	_calculate_center_offset()
	queue_redraw()


func _process(delta: float) -> void:
	_pulse_time += delta * 2.2
	queue_redraw()


func _calculate_center_offset() -> void:
	var center_cart := Vector2(float(grid_size.x) * 0.5, float(grid_size.y) * 0.5)
	_grid_offset = -IsometricHelper.cartesian_to_isometric(center_cart)


func _draw() -> void:
	_draw_isometric_grid()
	_draw_perimeter_boundary()
	_draw_corner_nodes()
	_draw_center_pulse_marker()


func _draw_isometric_grid() -> void:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var corners := _get_tile_screen_corners(Vector2i(x, y))
			# Subtle checkerboard contrast between adjacent tiles
			var fill_color := tile_color_a if (x + y) % 2 == 0 else tile_color_b
			draw_polygon(corners, PackedColorArray([fill_color, fill_color, fill_color, fill_color]))
			
			# Electric grid wireframe (1.8px width)
			for i in range(4):
				draw_line(corners[i], corners[(i + 1) % 4], base_grid_color, 1.8, true)


func _draw_perimeter_boundary() -> void:
	var top_vertex := _grid_to_world_raw(Vector2(0, 0))
	var right_vertex := _grid_to_world_raw(Vector2(float(grid_size.x), 0))
	var bottom_vertex := _grid_to_world_raw(Vector2(float(grid_size.x), float(grid_size.y)))
	var left_vertex := _grid_to_world_raw(Vector2(0, float(grid_size.y)))

	var boundary := PackedVector2Array([top_vertex, right_vertex, bottom_vertex, left_vertex])
	var pulse_intensity := 0.75 + sin(_pulse_time) * 0.25

	# Outer soft glow line (width 6.0)
	var glow_color := border_glow_color
	glow_color.a *= pulse_intensity
	for i in range(4):
		draw_line(boundary[i], boundary[(i + 1) % 4], glow_color, 6.0, true)

	# Sharp vibrant neon border (width 3.0)
	var dynamic_border := border_color
	dynamic_border.a = minf(1.0, 0.85 + sin(_pulse_time) * 0.15)
	for i in range(4):
		draw_line(boundary[i], boundary[(i + 1) % 4], dynamic_border, 3.0, true)


func _draw_corner_nodes() -> void:
	# 4 prominent glowing vertex nodes at the diamond tips
	var corners := [
		_grid_to_world_raw(Vector2(0, 0)),
		_grid_to_world_raw(Vector2(float(grid_size.x), 0)),
		_grid_to_world_raw(Vector2(float(grid_size.x), float(grid_size.y))),
		_grid_to_world_raw(Vector2(0, float(grid_size.y)))
	]
	var node_pulse := 1.0 + sin(_pulse_time * 2.0) * 0.15
	for pt in corners:
		draw_circle(pt, 9.0 * node_pulse, border_glow_color)
		draw_circle(pt, 4.5, border_color)
		draw_circle(pt, 2.0, Color.WHITE)


func _draw_center_pulse_marker() -> void:
	var center := _grid_offset + IsometricHelper.cartesian_to_isometric(Vector2(float(grid_size.x) * 0.5, float(grid_size.y) * 0.5))
	var pulse_r := 14.0 + sin(_pulse_time * 2.0) * 3.0
	# Outer subtle origin halo
	draw_circle(center, pulse_r + 6.0, Color(0.0, 0.85, 1.0, 0.12))
	# Mid ring
	draw_arc(center, pulse_r, 0.0, TAU, 32, Color(0.1, 0.9, 1.0, 0.55), 2.0, true)
	# Inner diamond core marker
	draw_circle(center, 5.0, border_color)
	draw_circle(center, 2.5, Color.WHITE)


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
