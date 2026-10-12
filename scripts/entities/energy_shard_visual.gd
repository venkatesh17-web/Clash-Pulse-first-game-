class_name EnergyShardVisual
extends Node2D

## Procedural golden energy crystal visual with high mobile visibility

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta * 4.0
	queue_redraw()


func _draw() -> void:
	var pulse := sin(_time)
	var glow_r := 22.0 + pulse * 2.5

	# Outer warm golden glow bloom
	draw_circle(Vector2.ZERO, glow_r, Color(1.0, 0.85, 0.15, 0.32))

	# Outer diamond crystal facet (scaled ~2x)
	var outer_diamond := PackedVector2Array([
		Vector2(0, -18),
		Vector2(13, 0),
		Vector2(0, 18),
		Vector2(-13, 0)
	])
	draw_colored_polygon(outer_diamond, Color(0.96, 0.78, 0.06, 1.0))
	draw_polyline(outer_diamond, Color(1.0, 0.96, 0.5, 1.0), 2.0, true)

	# Inner crystal facet
	var inner_diamond := PackedVector2Array([
		Vector2(0, -11),
		Vector2(8, 0),
		Vector2(0, 11),
		Vector2(-8, 0)
	])
	draw_colored_polygon(inner_diamond, Color(1.0, 0.94, 0.5, 0.95))

	# Core glint sparkle
	draw_circle(Vector2(0, -2.5), 3.2, Color(1.0, 1.0, 1.0, 1.0))
