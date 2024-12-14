extends Component
class_name AiComponent


@export var cooldown_time:float = 1

var current_state = Global.States.IDLE
var direction:Vector2 = Vector2.ZERO
var is_attacking:bool = false
var done_attacking:bool
var proximity = Global.Proximity.FAR
var is_resting = false
var rest_timer: Timer = Timer.new()
var is_idle
var is_moving = true
var min_distance
var max_distance
var last_state_change_time: float = 0.0
var state_change_cooldown: float = 0.5


func _ready() -> void:
	set_up_timer()
	
func set_up_timer():
	rest_timer = Timer.new()
	rest_timer.wait_time = cooldown_time
	rest_timer.autostart = false
	rest_timer.one_shot = true
	rest_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	rest_timer.connect("timeout", Callable(self, "on_rest_timeout"))
	add_child(rest_timer)
	
	
func update_ai() -> Global.States:
	checkPlayerDistance()
	match current_state:
		Global.States.ATTACK:
			if is_resting:
				current_state = Global.States.IDLE
			if is_idle:
				current_state = Global.States.IDLE
		Global.States.MOVE:
			if is_attacking:
				current_state = Global.States.ATTACK
			if is_resting:
				current_state = Global.States.IDLE
		Global.States.IDLE:
			if is_attacking:
				current_state = Global.States.ATTACK
			if !is_attacking and !is_resting:
				current_state = Global.States.MOVE
	return current_state
	
func checkPlayerDistance():
	var distance = componentOwner.global_position.distance_to(player.global_position)
	if distance < min_distance and !is_attacking:
		proximity = Global.Proximity.CLOSE
	elif distance >= max_distance:
		proximity = Global.Proximity.FAR
	elif distance > (min_distance * 1.5):
		proximity = Global.Proximity.MID
		
func on_rest_timeout():
	is_resting = false
