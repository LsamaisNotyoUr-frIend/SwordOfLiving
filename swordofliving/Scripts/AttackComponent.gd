extends Component
class_name AttackComponent


@export var attack_speed:int
@export_enum("CHARGE", "MELEE", "RANGED") var attack_pattern:int 
@export var attack_time: float = 2
@export var easing_time: float = 0.2
@export var attack_speed_multiplier:float = 2
var min_distance
var max_distance
var proximity = Global.Proximity.CLOSE
var direction:Vector2
var attack_timer:Timer
var is_idle
var is_attacking


signal done_attacking(bool)

func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_time
	attack_timer.autostart = false
	attack_timer.one_shot = true
	attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	attack_timer.connect("timeout", Callable(self, "on_timeout"))
	add_child(attack_timer)
	
func _physics_process(delta: float) -> void:
	if is_active:
		match attack_pattern:
			0:
				if is_attacking:
					componentOwner.velocity = ((direction * attack_speed * delta) * attack_speed_multiplier)
					componentOwner.move_and_slide()
			1:
				if is_attacking:
					componentOwner.velocity = ((direction * attack_speed * delta) * attack_speed_multiplier)
					if componentOwner.global_position.distance_to(player.global_position) <= min_distance:
						componentOwner.velocity = Vector2.ZERO
					componentOwner.move_and_slide()
			2:
				pass
	
func on_timeout():
	print("done")
	done_attacking.emit(true)
	is_attacking = false
	is_active = false
	
func start_attack():
	done_attacking.emit(false)
	attack_timer.start()
	is_attacking = true
	
	
