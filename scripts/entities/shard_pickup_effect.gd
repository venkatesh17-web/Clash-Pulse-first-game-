class_name ShardPickupEffect
extends Node2D

## Pulse Clash - Energy Shard Collection Burst Effect
## Renders 8 golden spark particles and a floating "+10" score popup.

var _lifetime: float = 0.55
var _elapsed: float = 0.0

var _particles: Array[Dictionary] = []
var _label: Label = null


func _ready() -> void:
	z_index = 6
	# Create 8 golden spark bursts
	for i in range(8):
		var angle := float(i) / 8.0 * TAU + randf_range(-0.2, 0.2)
		var speed := randf_range(70.0, 150.0)
		_particles.append({
			"pos": Vector2.ZERO,
			"vel": Vector2(cos(angle), sin(angle)) * speed,
			"size": randf_range(2.5, 4.5),
			"color": Color(1.0, 0.92, 0.3) if i % 2 == 0 else Color(1.0, 1.0, 0.8)
		})

	# Create floating +10 score text
	_label = Label.new()
	_label.text = "+10"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.position = Vector2(-30, -28)
	_label.custom_minimum_size = Vector2(60, 24)
	_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.3, 1.0))
	_label.add_theme_color_override("font_shadow_color", Color(0.4, 0.3, 0.0, 0.8))
	_label.add_theme_constant_override("shadow_offset_y", 2)
	_label.add_theme_font_size_override("font_size", 22)
	add_child(_label)

	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _lifetime:
		queue_free()
		return

	var progress := _elapsed / _lifetime

	# Move particles outwards with drag
	for p in _particles:
		p["pos"] += p["vel"] * delta
		p["vel"] *= 0.92

	# Float score text upwards and fade out
	if _label:
		_label.position.y -= delta * 38.0
		_label.modulate.a = 1.0 - (progress * progress)

	queue_redraw()


func _draw() -> void:
	var progress := _elapsed / _lifetime
	var alpha := 1.0 - progress

	# Expanding golden pickup ring
	var ring_r := 6.0 + progress * 24.0
	draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 24, Color(1.0, 0.88, 0.2, alpha * 0.85), 2.0, true)

	# Radiating spark particles
	for p in _particles:
		var c: Color = p["color"]
		c.a = alpha
		draw_circle(p["pos"], p["size"] * (1.0 - progress * 0.6), c)
