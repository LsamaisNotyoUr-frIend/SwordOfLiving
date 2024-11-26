extends Component
class_name MovementComponent

enum States {RETREAT, APPROACH, ATTACK}
var movement_state = States.APPROACH
var offset_timer = 0.0
var position_offset = Vector2.ZERO
	
var noise = FastNoiseLite.new()
var time = 0.0
var too_close:bool
var allow_update:bool = true
var next_to_player: bool
var minimum_angle_offset = 10
var pull = 80
@onready var timer:float = componentOwner.timer_value
@onready var speed = componentOwner.speed
@onready var player = Global.player


func _ready() -> void:
	var unique_seed = randi()
	
func randomize_movement(_seed):
	RandomNumberGenerator.new().seed = _seed
	
func adjust_course() -> void:
	var main_course = componentOwner.direction
	var target_post = componentOwner.global_position.direction_to(player.global_position)
	var course_error = main_course.angle() - target_post.angle()
	if (abs(course_error) > minimum_angle_offset):
		componentOwner.direction = main_course .rotated((course_error > 0) * pull)
	
func get_monster_movement(number_of_directions:int = 3) -> Vector2:
	var main_direction = componentOwner.global_position.direction_to(player.global_position)
	var directions = []
	var angle_step =30
	next_to_player = false
	
		
	if componentOwner.global_position.distance_to(player.global_position) < (componentOwner.distances["min"] * 1.5):
		next_to_player = true
		
	if !next_to_player:
		for i in range(0, number_of_directions):
			var angle_offset = angle_step * (i - floor(number_of_directions / 2))
			var rotated_direction = main_direction.rotated(deg_to_rad(angle_offset + randi_range(2, 10)))
			directions.append(rotated_direction)
			
		var random_integer = randi() % directions.size()
		return directions[random_integer]
		
	return main_direction
	
		
func handle_movement():
	var distance_to_player = componentOwner.global_position.distance_to(player.global_position)
	var is_attacking = componentOwner.is_attacking
	var distances= componentOwner.distances
	var speed_multiplier = componentOwner.attack_speed_multiplier
	var defaultspeed= componentOwner.const_speed
	
	if distance_to_player < distances["min"] and !is_attacking and allow_update:
		allow_update = false
		await get_tree().create_timer(0.05).timeout
		movement_state = States.RETREAT
		componentOwner.speed *= speed_multiplier
		allow_update = true
		
	if distance_to_player >= distances["max"] and componentOwner.can_move  and allow_update:
		allow_update = false
		componentOwner.speed = defaultspeed
		movement_state = States.APPROACH
		allow_update = true
		
	if distance_to_player <= distances["min"] and is_attacking  and allow_update:
		movement_state = States.ATTACK
		
	process_movement_options()
	
func process_movement_options():
	var vector = get_monster_movement()
	
	if movement_state == States.APPROACH:
		adjust_course()
		componentOwner.direction = vector
		
	if movement_state == States.RETREAT:
		componentOwner.direction = -vector
		
	if movement_state == States.ATTACK:
		componentOwner.direction = componentOwner.global_position.direction_to(player.global_position)
		
	
		
		
	
