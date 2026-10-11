class_name EnemyVisual
extends Node2D

## Procedural crimson chaser visual with stun feedback

var _time: float = 0.0
var _is_stunned: bool = false


func set_stunned(stunned: bool) -> void:
	_is_stunned = stunned
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta * 5.0
	queue_redraw()


func _draw() -> void:
	var pulse := sin(_time)
	
	if _is_stunned:
		# Stunned state: electric yellow/cyan flashing ring
		var stun_glow := 16.0 + pulse * 2.0
		draw_circle(Vector2.ZERO, stun_glow, Color(0.2, 0.8, 1.0, 0.3))
		draw_arc(Vector2.ZERO, 13.0, _time * 4.0, _time * 4.0 + PI * 1.5, 24, Color(1.0, 0.9, 0.2, 0.9), 2.5)
		draw_circle(Vector2.ZERO, 9.0, Color(0.2, 0.3, 0.5, 0.85))
		draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.95, 0.4, 1.0))
		return

	# Active Pursuer state: Aggressive crimson glow
	var glow_r := 16.0 + pulse * 2.0
	draw_circle(Vector2.ZERO, glow_r, Color(1.0, 0.15, 0.25, 0.3))

	# Crimson predator polygon (sharp diamond with forward needle)
	var predator_shape := PackedVector2Array([
		Vector2(12, 0),    # Forward point
		Vector2(-4, -8),   # Top wing
		Vector2(-10, -4),  # Top rear
		Vector2(-7, 0),    # Rear indent
		Vector2(-10, 4),   # Bottom rear
		Vector2(-4, 8)     # Bottom wing
	])
	draw_colored_polygon(predator_shape, Color(0.85, 0.08, 0.18, 1.0))
	draw_polyline(predator_shape, Color(1.0, 0.35, 0.45, 1.0), 1.5, true)

	# Dark center core
	draw_circle(Vector2(0, 0), 4.5, Color(0.15, 0.02, 0.04, 0.95))
	# Crimson hot eye
	draw_circle(Vector2(2, 0), 2.5, Color(1.0, 0.8, 0.85, 1.0))
