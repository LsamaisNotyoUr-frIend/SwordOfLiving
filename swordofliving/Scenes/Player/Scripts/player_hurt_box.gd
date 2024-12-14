class_name PlayerHurtBox
extends Area2D
## An Area2D that represents a part of an entity that can be damaged.
## This node manages detecting incoming hits and handling invincibility states.



## [b]active_enemies[/b] ([i]int[/i]) The number of enemies currently inside the characters Hurtbox
var active_enemies:int

## Initializes the HurtBox by disabling its collision layer and connecting the `area_entered` signal to the `processHit` function.
func _ready() -> void:
	collision_layer = 0
	connect("area_entered", Callable(self, "processHit"))
	connect("area_exited", Callable(self, "processExit"))

## Enables the HurtBox for the player by setting the collision mask.
## @param layer: The collision mask layer to set for the player (default is 5).
func enablePlayer(layer = 5):
	collision_mask = layer

## Enables the HurtBox for non-player entities by setting the collision mask.
## @param layer: The collision mask layer to set for non-player entities (default is 6).
func enable(layer = 6):
	collision_mask = layer

## Disables the HurtBox by clearing its collision mask.
func disable():
	collision_mask = 0

## Processes an incoming hit by checking if the area is a `Hitbox`.
## @param area: The `Area2D` instance that entered the HurtBox's area.
func processHit(area: Area2D):
	if area is Hitbox:
		print("entered")
		active_enemies += 1
		var hitbox = area as Hitbox
		processDamage(hitbox)
	else:
		return
		
func processExit(area: Area2D):
	if area is Hitbox:
		active_enemies = max(active_enemies - 1, 0)

## Processes the damage from a `Hitbox` by calling the `takeDamage()` method on the hitbox's owner if it exists.
## @param hitbox: The `Hitbox` instance from which the damage originates.
func processDamage(hitbox: Hitbox):
	var hit_owner = owner
	if hit_owner.has_method("takeDamage"):
		var damage = hitbox.damage
		if active_enemies > 2:
		# Reduce damage based on the number of active enemies.
		# Example: reduce damage by 20% for each additional enemy (capped at 50% reduction).
			var reduction_factor = min(0.5, 0.2 * (active_enemies - 1))
			damage *= (1 - reduction_factor)
		hit_owner.takeDamage(damage)

## Disables the HurtBox temporarily to create an invincibility effect and then re-enables it after a set duration.
## @param isPlayer: A boolean indicating if the HurtBox belongs to a player (default is true).
## @param time: The duration of the invincibility in seconds (default is 0.1).
func invincibility(isPlayer: bool = true, time: float = 0.1):
	disable()
	await get_tree().create_timer(time).timeout
	if isPlayer:
		enablePlayer()
	else:
		enable()

## Returns the current collision mask of the HurtBox.
## @return: The integer value of the current collision mask.
func getLayer() -> int:
	return collision_mask
