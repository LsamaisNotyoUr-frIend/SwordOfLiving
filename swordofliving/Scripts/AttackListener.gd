class_name AttackListener
extends Area2D
## AttackListener Class
## An Area2D node that listens for player entry and emits a signal when a player enters its area.


var isPlayerInside:bool = false

## [b]playEntered[/b] ([i]bool[/i])
## Signal emitted when the player enters the area.
signal playEntered(bool)

signal playExited(bool)

signal playInside(bool)

## Initializes the AttackListener by setting the collision mask and layer.
## Connects the `body_entered` signal to the `processEntrance` function.
func _ready() -> void:
	collision_mask = 2
	collision_layer = 14
	connect("body_entered", Callable(self, "processEntrance"))
	connect("body_exited", Callable(self, "processExit"))
	
## Processes the entrance of a body into the AttackListener's area.
## Checks if the body is an instance of the `Player` class and emits the `playEntered` signal if true.
## @param body: The `Node2D` instance that entered the area.
func processEntrance(body: Node2D):
	if body is Player:
		emit_signal("playEntered", true)
		isPlayerInside = true
		
func processExit(body:Node2D):
	if body is Player:
		emit_signal("playExited", true)
		isPlayerInside = false
