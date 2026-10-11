class_name PlayerOrbRenderer
extends Node2D

## Pulse Clash - Player Visual Renderer
## Procedural cyan energy orb with high-contrast silhouette and subtle pulse glow.

var pulse_time: float = 0.0


func _process(delta: float) -> void:
	pulse_time += delta * 3.5
	queue_redraw()


func _draw() -> void:
	var pulse := sin(pulse_time)
	
	# Layer 1: Outer soft cyan glow
	var glow_radius := 18.0 + pulse * 2.0
	draw_circle(Vector2.ZERO, glow_radius, Color(0.0, 0.85, 1.0, 0.22))
	
	# Layer 2: Electric cyan corona ring
	var ring_radius := 12.0 + pulse * 0.8
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 32, Color(0.2, 0.95, 1.0, 0.65), 2.0, true)
	
	# Layer 3: Dark contrast silhouette ring (ensures visibility over bright & dark backgrounds)
	draw_circle(Vector2.ZERO, 9.5, Color(0.02, 0.06, 0.14, 0.95))
	
	# Layer 4: Cyan energy nucleus
	draw_circle(Vector2.ZERO, 6.5, Color(0.1, 0.88, 1.0, 1.0))
	
	# Layer 5: Hot white core
	draw_circle(Vector2.ZERO, 2.8, Color(1.0, 1.0, 1.0, 1.0))
