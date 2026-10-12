class_name Arena
extends Node2D

## Pulse Clash - 2D Isometric Arena
## Renders a clearly visible, prominent diamond-shaped tiled arena matching portrait mobile screens.

signal arena_clicked(grid_position: Vector2i, world_position: Vector2)

@export var grid_size: Vector2i = Vector2i(9, 9)
@export var tile_width: float = 76.0
@export var tile_height: float = 68.0

@export_group("Visuals")
@export var tile_color_a: Color = Color(0.08, 0.16, 0.32, 1.0)
@export var tile_color_b: Color = Color(0.05, 0.10, 0.22, 1.0)
@export var tile_inset_highlight: Color = Color(0.2, 0.75, 1.0, 0.25)
@export var base_grid_color: Color = Color(0.18, 0.72, 1.0, 0.8)
@export var border_color: Color = Color(0.1, 0.96, 1.0, 1.0)
@export var border_glow_color: Color = Color(0.0, 0.8, 1.0, 0.4)
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
	_draw_arena_ground_halo()
	_draw_stage_plinth()
	_draw_isometric_grid()
	_draw_perimeter_boundary()
	_draw_corner_nodes()
	_draw_center_pulse_marker()


func _draw_arena_ground_halo() -> void:
	# Subtle outer perimeter energy floor glow beneath the tiles
	var top_vertex := _grid_to_world_raw(Vector2(0, 0))
	var right_vertex := _grid_to_world_raw(Vector2(float(grid_size.x), 0))
	var bottom_vertex := _grid_to_world_raw(Vector2(float(grid_size.x), float(grid_size.y)))
	var left_vertex := _grid_to_world_raw(Vector2(0, float(grid_size.y)))

	var outer_expansion := 16.0
	var halo_poly := PackedVector2Array([
		top_vertex + Vector2(0, -outer_expansion),
		right_vertex + Vector2(outer_expansion, 0),
		bottom_vertex + Vector2(0, outer_expansion),
		left_vertex + Vector2(-outer_expansion, 0)
	])
	var halo_color := Color(0.0, 0.4, 0.8, 0.12)
	draw_colored_polygon(halo_poly, halo_color)


func _draw_stage_plinth() -> void:
	# Subtle 3D floating isometric platform slab drop along bottom edges
	var right_vertex := _grid_to_world_raw(Vector2(float(grid_size.x), 0))
	var bottom_vertex := _grid_to_world_raw(Vector2(float(grid_size.x), float(grid_size.y)))
	var left_vertex := _grid_to_world_raw(Vector2(0, float(grid_size.y)))

	var depth := Vector2(0, 10.0)

	# Left bottom plinth face
	var left_plinth := PackedVector2Array([
		left_vertex,
		bottom_vertex,
		bottom_vertex + depth,
		left_vertex + depth
	])
	draw_colored_polygon(left_plinth, Color(0.025, 0.06, 0.14, 0.95))
	draw_line(left_vertex + depth, bottom_vertex + depth, Color(0.1, 0.55, 0.75, 0.5), 1.5, true)

	# Right bottom plinth face
	var right_plinth := PackedVector2Array([
		bottom_vertex,
		right_vertex,
		right_vertex + depth,
		bottom_vertex + depth
	])
	draw_colored_polygon(right_plinth, Color(0.018, 0.045, 0.11, 0.95))
	draw_line(bottom_vertex + depth, right_vertex + depth, Color(0.08, 0.45, 0.65, 0.5), 1.5, true)

	# Front corner vertical spine
	draw_line(bottom_vertex, bottom_vertex + depth, Color(0.15, 0.85, 1.0, 0.75), 2.0, true)


func _draw_isometric_grid() -> void:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var corners := _get_tile_screen_corners(Vector2i(x, y))
			
			# High-contrast checkerboard tile fills with center nexus highlight
			var is_nexus: bool = abs(x - 4) <= 1 and abs(y - 4) <= 1
			var fill_color: Color
			if is_nexus:
				fill_color = Color(0.10, 0.20, 0.38, 1.0) if (x + y) % 2 == 0 else Color(0.07, 0.14, 0.28, 1.0)
			else:
				fill_color = tile_color_a if (x + y) % 2 == 0 else tile_color_b
			
			draw_polygon(corners, PackedColorArray([fill_color, fill_color, fill_color, fill_color]))

			# Subtle top-facing tile bevel/highlight for tactile 3D tile feel
			draw_line(corners[0], corners[1], tile_inset_highlight, 1.2, true)
			draw_line(corners[0], corners[3], tile_inset_highlight, 1.2, true)

			# Crisp electric neon grid wireframe (2.0px stroke)
			for i in range(4):
				draw_line(corners[i], corners[(i + 1) % 4], base_grid_color, 2.0, true)


func _draw_perimeter_boundary() -> void:
	var top_vertex := _grid_to_world_raw(Vector2(0, 0))
	var right_vertex := _grid_to_world_raw(Vector2(float(grid_size.x), 0))
	var bottom_vertex := _grid_to_world_raw(Vector2(float(grid_size.x), float(grid_size.y)))
	var left_vertex := _grid_to_world_raw(Vector2(0, float(grid_size.y)))

	var boundary := PackedVector2Array([top_vertex, right_vertex, bottom_vertex, left_vertex])
	var pulse_intensity := 0.75 + sin(_pulse_time) * 0.25

	# Outer soft glowing bloom perimeter (8px stroke)
	var glow_color := border_glow_color
	glow_color.a *= pulse_intensity
	for i in range(4):
		draw_line(boundary[i], boundary[(i + 1) % 4], glow_color, 8.0, true)

	# Sharp vibrant neon cyan boundary (3.5px stroke)
	var dynamic_border := border_color
	dynamic_border.a = minf(1.0, 0.9 + sin(_pulse_time) * 0.1)
	for i in range(4):
		draw_line(boundary[i], boundary[(i + 1) % 4], dynamic_border, 3.5, true)

	# Inner boundary inset line (4px inside) for crisp high-tech double perimeter
	var inset_top := top_vertex + Vector2(0, 4)
	var inset_right := right_vertex + Vector2(-4, 0)
	var inset_bottom := bottom_vertex + Vector2(0, -4)
	var inset_left := left_vertex + Vector2(4, 0)
	var inner_boundary := PackedVector2Array([inset_top, inset_right, inset_bottom, inset_left])
	for i in range(4):
		draw_line(inner_boundary[i], inner_boundary[(i + 1) % 4], Color(0.1, 0.85, 1.0, 0.35), 1.2, true)


func _draw_corner_nodes() -> void:
	# 4 prominent glowing vertex diamond markers at the diamond tips
	var corners := [
		_grid_to_world_raw(Vector2(0, 0)),
		_grid_to_world_raw(Vector2(float(grid_size.x), 0)),
		_grid_to_world_raw(Vector2(float(grid_size.x), float(grid_size.y))),
		_grid_to_world_raw(Vector2(0, float(grid_size.y)))
	]
	var node_pulse := 1.0 + sin(_pulse_time * 2.0) * 0.2
	for pt in corners:
		# Outer glowing bloom
		draw_circle(pt, 12.0 * node_pulse, border_glow_color)
		# Glowing diamond marker
		var diamond := PackedVector2Array([
			pt + Vector2(0, -7),
			pt + Vector2(7, 0),
			pt + Vector2(0, 7),
			pt + Vector2(-7, 0)
		])
		draw_colored_polygon(diamond, border_color)
		draw_polyline(diamond, Color.WHITE, 1.5, true)


func _draw_center_pulse_marker() -> void:
	var center := _grid_offset + IsometricHelper.cartesian_to_isometric(Vector2(float(grid_size.x) * 0.5, float(grid_size.y) * 0.5))
	var pulse_r := 16.0 + sin(_pulse_time * 2.0) * 3.5

	# Outer concentric core halo
	draw_circle(center, pulse_r + 8.0, Color(0.0, 0.85, 1.0, 0.15))
	# Mid electric ring
	draw_arc(center, pulse_r, 0.0, TAU, 36, Color(0.15, 0.95, 1.0, 0.7), 2.5, true)
	# Inner diamond core marker
	var core_diamond := PackedVector2Array([
		center + Vector2(0, -6),
		center + Vector2(6, 0),
		center + Vector2(0, 6),
		center + Vector2(-6, 0)
	])
	draw_colored_polygon(core_diamond, border_color)
	draw_circle(center, 3.0, Color.WHITE)


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
