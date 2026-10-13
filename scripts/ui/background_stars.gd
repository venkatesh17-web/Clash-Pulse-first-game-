class_name BackgroundAtmosphere
extends ColorRect

## Pulse Clash - Atmospheric Deep Void Background
## Renders a midnight-navy cybernetic gradient with floating energy particles and distant geometric depth.

var _time: float = 0.0
var _particles: Array[Dictionary] = []
const PARTICLE_COUNT: int = 32


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_init_particles()


func _init_particles() -> void:
	_particles.clear()
	var vp_size := get_viewport_rect().size
	for i in range(PARTICLE_COUNT):
		_particles.append({
			"pos": Vector2(randf_range(0.0, vp_size.x), randf_range(0.0, vp_size.y)),
			"speed": randf_range(12.0, 32.0),
			"sway_speed": randf_range(0.8, 2.2),
			"sway_amount": randf_range(6.0, 16.0),
			"base_x": randf_range(0.0, vp_size.x),
			"size": randf_range(1.5, 3.2),
			"color": Color(0.15, 0.75, 1.0) if i % 2 == 0 else Color(0.65, 0.3, 0.95),
			"phase": randf() * TAU
		})


func _process(delta: float) -> void:
	_time += delta
	var vp_size := get_viewport_rect().size

	for p in _particles:
		p["pos"].y -= p["speed"] * delta
		p["pos"].x = p["base_x"] + sin(_time * p["sway_speed"] + p["phase"]) * p["sway_amount"]

		# Wrap around screen edges
		if p["pos"].y < -20.0:
			p["pos"].y = vp_size.y + 20.0
			p["base_x"] = randf_range(0.0, vp_size.x)

	queue_redraw()


func _draw() -> void:
	var vp_size := get_viewport_rect().size

	# 1. Midnight navy gradient fill
	var rect_poly := PackedVector2Array([
		Vector2.ZERO,
		Vector2(vp_size.x, 0.0),
		Vector2(vp_size.x, vp_size.y),
		Vector2(0.0, vp_size.y)
	])
	var colors := PackedColorArray([
		Color(0.015, 0.025, 0.055, 1.0), # Top deep midnight
		Color(0.015, 0.025, 0.055, 1.0),
		Color(0.035, 0.055, 0.10, 1.0),  # Bottom deep blue-navy
		Color(0.035, 0.055, 0.10, 1.0)
	])
	draw_polygon(rect_poly, colors)

	# 2. Distant subtle geometric depth lines (radiating to center)
	var center := vp_size * 0.5
	var grid_color := Color(0.1, 0.35, 0.6, 0.06)
	var ray_count := 8
	for i in range(ray_count):
		var angle := float(i) / float(ray_count) * TAU
		var dir := Vector2(cos(angle), sin(angle))
		draw_line(center + dir * 180.0, center + dir * 900.0, grid_color, 1.0)

	# 3. Ambient energy dust particles
	for p in _particles:
		var pulse := sin(_time * 2.0 + p["phase"]) * 0.2 + 0.8
		var alpha: float = clampf(0.25 * pulse, 0.05, 0.45)
		var c: Color = p["color"]
		c.a = alpha
		draw_circle(p["pos"], p["size"], c)
