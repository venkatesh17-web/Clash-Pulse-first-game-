class_name EnergyShardVisual
extends Node2D

## Procedural golden energy crystal visual

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta * 4.0
	queue_redraw()


func _draw() -> void:
	var pulse := sin(_time)
	var glow_r := 13.0 + pulse * 1.5

	# Outer warm golden glow
	draw_circle(Vector2.ZERO, glow_r, Color(1.0, 0.82, 0.1, 0.28))

	# Outer diamond facet
	var outer_diamond := PackedVector2Array([
		Vector2(0, -10),
		Vector2(7, 0),
		Vector2(0, 10),
		Vector2(-7, 0)
	])
	draw_colored_polygon(outer_diamond, Color(0.95, 0.75, 0.05, 1.0))
	draw_polyline(outer_diamond, Color(1.0, 0.95, 0.4, 1.0), 1.5, true)

	# Inner crystal facet
	var inner_diamond := PackedVector2Array([
		Vector2(0, -6),
		Vector2(4, 0),
		Vector2(0, 6),
		Vector2(-4, 0)
	])
	draw_colored_polygon(inner_diamond, Color(1.0, 0.92, 0.4, 0.9))

	# Core glint
	draw_circle(Vector2(0, -1.5), 1.8, Color(1.0, 1.0, 1.0, 0.95))
