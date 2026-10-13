class_name EnergyShard
extends Area2D

## Pulse Clash - Golden Energy Shard Collectible
## Awards +10 points, features magnetic attraction support for Pulse shockwave.

signal shard_collected(shard: EnergyShard, score_value: int)

@export var score_value: int = 10
@export var attract_speed: float = 450.0

var is_collected: bool = false
var is_being_attracted: bool = false
var _target_player: Node2D = null
var _time: float = 0.0

@onready var visuals: Node2D = $Visuals
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Area monitoring for Player (Player is CharacterBody2D on collision layer 1)
	collision_layer = 2
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	_time = randf() * TAU


func _process(delta: float) -> void:
	_time += delta * 3.5
	if not is_collected:
		# Floating bobbing animation
		visuals.position.y = sin(_time) * 3.0
		visuals.queue_redraw()

	if is_being_attracted and _target_player != null and not is_collected:
		var dir := (_target_player.global_position - global_position).normalized()
		global_position += dir * attract_speed * delta


func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body is Player or body.name == "Player":
		collect()


func attract_to(player_node: Node2D) -> void:
	if is_collected:
		return
	is_being_attracted = true
	_target_player = player_node


const PICKUP_EFFECT_SCENE: PackedScene = preload("res://scenes/entities/shard_pickup_effect.tscn")


func collect() -> void:
	if is_collected:
		return
	is_collected = true
	is_being_attracted = false
	shard_collected.emit(self, score_value)

	# Spawn golden spark burst and floating +10 score popup
	if is_inside_tree() and get_parent() != null:
		var effect: Node2D = PICKUP_EFFECT_SCENE.instantiate()
		effect.position = position
		get_parent().add_child(effect)

	# Lightweight visual collection feedback
	var tween := create_tween().set_parallel(true)
	tween.tween_property(visuals, "scale", Vector2(1.8, 1.8), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(visuals, "modulate:a", 0.0, 0.15)
	tween.chain().tween_callback(_on_collect_finished)


func _on_collect_finished() -> void:
	visible = false


func respawn_at(new_position: Vector2) -> void:
	position = new_position
	is_collected = false
	is_being_attracted = false
	_target_player = null
	visible = true
	visuals.modulate.a = 0.0
	visuals.scale = Vector2(0.2, 0.2)
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(visuals, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(visuals, "modulate:a", 1.0, 0.2)
