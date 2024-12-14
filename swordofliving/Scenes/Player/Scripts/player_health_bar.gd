class_name  PlayerHealthBar
extends ProgressBar

@export var progress_bar: ProgressBar
var health:float = 10 :set = set_health
	
var target_health: int
var max_health: int
var transition_speed: float = 7.0
var timer = 0
var modifyHealth:bool = false

func _physics_process(delta: float) -> void:
	if progress_bar.value != value:
		progress_bar.value = lerp(progress_bar.value, value, delta * transition_speed)
		
func init_health(_health):
	health = _health
	max_value = health
	value = health
	progress_bar.max_value = health
	progress_bar.value = health

func set_health(new_health):
	var previous_health = health
	health = min(max_value, new_health)
	value = health
	if health < previous_health:
		modifyHealth = true
	else:
		progress_bar.value = health
