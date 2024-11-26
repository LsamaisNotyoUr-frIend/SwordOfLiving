class_name BlockBox
extends Area2D

## An Area2D for detecting hits to a shield or blocking item.
## This node handles calculating whether an attack is blocked and determining any damage overspill.

## The damage the shield or item can withstand without overspill.
@export var block_damage: int = 10

## The damage received from the collision.
var damage_received: int

## The damage that couldn't be blocked (occurs when block_damage < damage_received).
var overspill_damage: int

## True when the damage was completely blocked (block_damage >= damage_received).
var perfect_block: bool

## Emitted when the blockBox successfully blocks an attack but there is leftover damage.
## The `damage_amount` parameter indicates the amount of damage that wasn't blocked.
signal block_detected(damage_amount)

func _process(delta: float) -> void:
	if block_damage >= damage_received:
		perfect_block = true
		overspill_damage = 0
	else:
		perfect_block = false
		overspill_damage = damage_received - block_damage
