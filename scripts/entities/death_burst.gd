class_name DeathBurst
extends Node2D

## Pulse Clash - Collision Death Burst Effect
## Renders a high-energy core detonation shockwave and shattered particle shards on player-enemy contact.

var _lifetime: float = 0.5
var _elapsed: float = 0.0

var _particles: Array[Dictionary] = []


func _ready() -> void:
	for i in range(12):
		var angle := randf() * TAU
		var speed := randf_range(80.0, 220.0)
		_particles.append({
			"vel": Vector2(cos(angle), sin(angle)) * speed,
			"pos": Vector2.ZERO,
			"color": Color(0.1, 0.9, 1.0) if i % 2 == 0 else Color(1.0, 0.2, 0.35),
			"size": randf_range(3.0, 6.0)
		})
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _lifetime:
		queue_free()
		return

	for p in _particles:
		p["pos"] += p["vel"] * delta
		p["vel"] *= 0.94 # Drag

	queue_redraw()


func _draw() -> void:
	var progress := clampf(_elapsed / _lifetime, 0.0, 1.0)
	var alpha := 1.0 - progress

	# Expanding core blast wave
	var ring_r := 10.0 + progress * 65.0
	draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 32, Color(1.0, 0.3, 0.4, alpha * 0.9), 3.5, true)
	draw_arc(Vector2.ZERO, ring_r * 0.7, 0.0, TAU, 28, Color(0.2, 0.95, 1.0, alpha * 0.8), 2.5, true)

	# Initial white-hot core flash
	if progress < 0.25:
		var flash_alpha := (1.0 - progress / 0.25)
		draw_circle(Vector2.ZERO, 25.0 * flash_alpha, Color(1.0, 1.0, 1.0, flash_alpha * 0.9))

	# Shattered energy shards
	for p in _particles:
		var c: Color = p["color"]
		c.a = alpha
		draw_circle(p["pos"], p["size"] * (1.0 - progress * 0.5), c)
