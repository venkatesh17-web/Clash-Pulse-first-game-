class_name EnemyVisual
extends Node2D

## Procedural crimson chaser visual with high mobile contrast and stun feedback

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
		# Stunned state: electric yellow and cyan flashing corona
		var stun_glow := 28.0 + pulse * 3.0
		draw_circle(Vector2.ZERO, stun_glow, Color(0.2, 0.85, 1.0, 0.35))
		draw_arc(Vector2.ZERO, 22.0, _time * 4.0, _time * 4.0 + PI * 1.5, 32, Color(1.0, 0.95, 0.2, 0.95), 3.0, true)
		draw_circle(Vector2.ZERO, 15.0, Color(0.15, 0.25, 0.45, 0.9))
		draw_circle(Vector2.ZERO, 8.0, Color(1.0, 0.95, 0.4, 1.0))
		return

	# Active Pursuer state: Aggressive crimson bloom
	var glow_r := 26.0 + pulse * 3.0
	draw_circle(Vector2.ZERO, glow_r, Color(1.0, 0.12, 0.25, 0.32))

	# Crimson predator polygon (scaled ~2x for high mobile visibility)
	var predator_shape := PackedVector2Array([
		Vector2(22, 0),     # Forward spearhead
		Vector2(-7, -14),   # Top wing
		Vector2(-18, -7),   # Top rear
		Vector2(-12, 0),    # Rear notch
		Vector2(-18, 7),    # Bottom rear
		Vector2(-7, 14)     # Bottom wing
	])
	draw_colored_polygon(predator_shape, Color(0.88, 0.06, 0.18, 1.0))
	draw_polyline(predator_shape, Color(1.0, 0.4, 0.5, 1.0), 2.2, true)

	# High contrast center core
	draw_circle(Vector2.ZERO, 7.5, Color(0.12, 0.02, 0.04, 0.95))
	# Crimson hot eye
	draw_circle(Vector2(4, 0), 4.0, Color(1.0, 0.85, 0.9, 1.0))
