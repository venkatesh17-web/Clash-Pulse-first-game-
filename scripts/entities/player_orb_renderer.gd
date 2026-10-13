class_name PlayerOrbRenderer
extends Node2D

## Pulse Clash - Player Visual Renderer
## High-visibility procedural cyan energy orb with prominent mobile scale and shield glow.

var pulse_time: float = 0.0
var is_invulnerable: bool = false


func _process(delta: float) -> void:
	pulse_time += delta * 4.0
	queue_redraw()


func _draw() -> void:
	var pulse := sin(pulse_time)

	# Layer 0: Floor contact shadow (anchors player in isometric 3D space)
	var shadow_poly := PackedVector2Array([
		Vector2(0, 12),
		Vector2(16, 17),
		Vector2(0, 22),
		Vector2(-16, 17)
	])
	draw_colored_polygon(shadow_poly, Color(0.012, 0.03, 0.08, 0.65))
	
	# Invulnerability Shield Effect (during grace period)
	if is_invulnerable:
		var shield_r := 34.0 + pulse * 3.0
		draw_arc(Vector2.ZERO, shield_r, pulse_time * 2.0, pulse_time * 2.0 + PI * 1.6, 32, Color(0.2, 0.95, 1.0, 0.9), 3.0, true)
		draw_arc(Vector2.ZERO, shield_r - 4.0, -pulse_time * 2.5, -pulse_time * 2.5 + PI * 1.4, 28, Color(1.0, 1.0, 1.0, 0.7), 2.0, true)
		draw_circle(Vector2.ZERO, shield_r, Color(0.0, 0.85, 1.0, 0.15))

	# Layer 1: Outer soft cyan glow (Large radius for high mobile readability)
	var glow_radius := 28.0 + pulse * 3.0
	draw_circle(Vector2.ZERO, glow_radius, Color(0.0, 0.85, 1.0, 0.28))
	
	# Layer 2: Electric cyan corona ring
	var ring_radius := 20.0 + pulse * 1.2
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 36, Color(0.25, 0.95, 1.0, 0.8), 2.5, true)
	
	# Layer 3: Dark contrast silhouette ring (prevents blend-in with bright floors or effects)
	draw_circle(Vector2.ZERO, 15.0, Color(0.02, 0.06, 0.15, 0.95))
	
	# Layer 4: Vivid cyan energy nucleus
	draw_circle(Vector2.ZERO, 11.0, Color(0.05, 0.9, 1.0, 1.0))
	
	# Layer 5: Concentrated bright white core
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 1.0, 1.0, 1.0))
