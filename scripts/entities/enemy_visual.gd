class_name EnemyVisual
extends Node2D

## Procedural crimson chaser visual with high mobile contrast, stun feedback, and collision flash.

var _time: float = 0.0
var _is_stunned: bool = false
var _is_spawning: bool = false
var _hit_flash: float = 0.0


func set_stunned(stunned: bool) -> void:
	_is_stunned = stunned
	queue_redraw()


func set_spawning(spawning: bool) -> void:
	_is_spawning = spawning
	queue_redraw()


func trigger_hit_flash() -> void:
	_hit_flash = 0.4
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta * 5.0
	if _hit_flash > 0.0:
		_hit_flash = maxf(0.0, _hit_flash - delta)
	queue_redraw()


func _draw() -> void:
	var pulse := sin(_time)

	# 1. Spawning / Materializing State (Warmup)
	if _is_spawning:
		var spawn_r := 28.0 + pulse * 4.0
		draw_arc(Vector2.ZERO, spawn_r, _time * 3.0, _time * 3.0 + PI * 1.5, 32, Color(1.0, 0.2, 0.35, 0.9), 2.5, true)
		draw_arc(Vector2.ZERO, spawn_r * 0.6, -_time * 4.0, -_time * 4.0 + PI, 24, Color(1.0, 0.8, 0.2, 0.8), 2.0, true)
		draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.1, 0.25, 0.4))
		draw_circle(Vector2.ZERO, 4.0, Color.WHITE)
		return

	# Predator Polygon Geometry
	var predator_shape := PackedVector2Array([
		Vector2(22, 0),     # Forward spearhead
		Vector2(-7, -14),   # Top wing
		Vector2(-18, -7),   # Top rear
		Vector2(-12, 0),    # Rear notch
		Vector2(-18, 7),    # Bottom rear
		Vector2(-7, 14)     # Bottom wing
	])

	# 2. Collision Impact Flash
	if _hit_flash > 0.0:
		var flash_ratio := _hit_flash / 0.4
		draw_circle(Vector2.ZERO, 36.0 * flash_ratio, Color(1.0, 0.9, 0.9, 0.85))
		draw_colored_polygon(predator_shape, Color.WHITE)
		draw_polyline(predator_shape, Color(1.0, 0.2, 0.3, 1.0), 3.0, true)
		return

	# 3. Stunned State: Paralyzed with crackling electric shock arcs
	if _is_stunned:
		# Ambient electric stun corona
		var stun_glow := 30.0 + pulse * 3.0
		draw_circle(Vector2.ZERO, stun_glow, Color(0.15, 0.75, 1.0, 0.28))
		
		# Paralyzed predator body (dimmed ember)
		draw_colored_polygon(predator_shape, Color(0.35, 0.12, 0.22, 0.9))
		draw_polyline(predator_shape, Color(0.3, 0.85, 1.0, 0.95), 2.0, true)

		# Rotating dual electric stun rings
		draw_arc(Vector2.ZERO, 24.0, _time * 4.0, _time * 4.0 + PI * 1.4, 32, Color(1.0, 0.92, 0.2, 0.95), 3.0, true)
		draw_arc(Vector2.ZERO, 18.0, -_time * 5.0, -_time * 5.0 + PI * 1.2, 28, Color(0.2, 0.95, 1.0, 0.9), 2.5, true)

		# Electric zap nodes on wings
		draw_circle(Vector2(-7, -14), 4.0, Color(1.0, 0.95, 0.4, 1.0))
		draw_circle(Vector2(-7, 14), 4.0, Color(1.0, 0.95, 0.4, 1.0))
		draw_circle(Vector2(22, 0), 4.5, Color(0.3, 0.95, 1.0, 1.0))
		return

	# 4. Active Pursuer State: Aggressive crimson bloom
	# Floor contact shadow (isometric perspective anchor)
	var shadow_poly := PackedVector2Array([
		Vector2(0, 10),
		Vector2(14, 15),
		Vector2(0, 20),
		Vector2(-14, 15)
	])
	draw_colored_polygon(shadow_poly, Color(0.02, 0.01, 0.05, 0.6))

	var glow_r := 28.0 + pulse * 3.5
	draw_circle(Vector2.ZERO, glow_r, Color(1.0, 0.12, 0.25, 0.35))

	# Vibrant crimson predator body
	draw_colored_polygon(predator_shape, Color(0.92, 0.06, 0.2, 1.0))
	draw_polyline(predator_shape, Color(1.0, 0.45, 0.55, 1.0), 2.4, true)

	# High contrast center core
	draw_circle(Vector2.ZERO, 8.0, Color(0.12, 0.02, 0.04, 0.95))
	# Crimson hot eye
	draw_circle(Vector2(4, 0), 4.2, Color(1.0, 0.88, 0.92, 1.0))
