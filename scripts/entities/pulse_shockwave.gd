class_name PulseShockwave
extends Node2D

## Procedural expanding shockwave ring with bright cyan bloom

@export var max_radius: float = 210.0
@export var duration: float = 0.42

var _current_radius: float = 12.0
var _current_alpha: float = 1.0


func _ready() -> void:
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
	# Primary glowing shockwave ring
	var outer_color := Color(0.15, 0.95, 1.0, _current_alpha * 0.95)
	draw_arc(Vector2.ZERO, _current_radius, 0.0, TAU, 48, outer_color, 4.5, true)
	
	# Secondary soft inner halo ring
	if _current_radius > 25.0:
		var inner_color := Color(0.0, 0.75, 1.0, _current_alpha * 0.45)
		draw_arc(Vector2.ZERO, _current_radius * 0.78, 0.0, TAU, 36, inner_color, 2.5, true)
