class_name PulseShockwave
extends Node2D

## Procedural expanding dual-color shockwave ring (Cyan + Electric Violet) with energy rays

@export var max_radius: float = 230.0
@export var duration: float = 0.45

var _current_radius: float = 12.0
var _current_alpha: float = 1.0


func _ready() -> void:
	z_index = 4
	var tween := create_tween().set_parallel(true)
	tween.tween_method(_set_radius, 12.0, max_radius, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_alpha, 1.0, 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)


func _set_radius(r: float) -> void:
	_current_radius = r
	queue_redraw()


func _set_alpha(a: float) -> void:
	_current_alpha = a
	queue_redraw()


func _draw() -> void:
	# 1. Primary outer electric cyan shockwave ring
	var cyan_color := Color(0.2, 0.96, 1.0, _current_alpha * 0.95)
	draw_arc(Vector2.ZERO, _current_radius, 0.0, TAU, 54, cyan_color, 4.0, true)

	# 2. Resonant electric violet mid-ring
	if _current_radius > 20.0:
		var violet_color := Color(0.72, 0.25, 1.0, _current_alpha * 0.85)
		draw_arc(Vector2.ZERO, _current_radius * 0.84, 0.0, TAU, 44, violet_color, 3.0, true)

	# 3. Soft ambient core halo
	if _current_radius > 35.0:
		var halo_color := Color(0.1, 0.5, 0.95, _current_alpha * 0.25)
		draw_circle(Vector2.ZERO, _current_radius * 0.65, halo_color)

	# 4. Radiating energy rays (8 high-energy spokes)
	if _current_radius > 30.0:
		var ray_color := Color(0.4, 0.88, 1.0, _current_alpha * 0.7)
		for i in range(8):
			var angle := float(i) / 8.0 * TAU
			var ray_dir := Vector2(cos(angle), sin(angle))
			var start_pt := ray_dir * (_current_radius * 0.7)
			var end_pt := ray_dir * (_current_radius * 1.08)
			draw_line(start_pt, end_pt, ray_color, 2.0, true)
