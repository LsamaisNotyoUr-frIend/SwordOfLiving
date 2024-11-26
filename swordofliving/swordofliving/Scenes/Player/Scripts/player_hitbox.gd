class_name PlayerHitBox
extends Area2D

@export var damage:int = 5
@export var isActive: bool = false
@export var isPlayer: bool = true
@export var collision: CollisionShape2D

func _ready() -> void:
	collision_mask = 0
	
func _process(delta: float) -> void:
	if isActive:
		if isPlayer:
			enablePlayer()
		else:
			enable()
	else:
		disable()
		
func disable():
	collision_layer = 0
	
func enable(layer = 5):
	collision_layer = layer 

func enablePlayer(layer = 6):
	collision_layer = layer
	
