extends Component
class_name MonsterComponent

@export var speed: int
@export var attack_speed: int
@export var distances: Dictionary = {
	"min": 80,
	"max": 200
}

@export var movementComponent:MovementComponent
@export var attackComponent:AttackComponent
@export var aiComponent:AiComponent

@export var rest_time: float = 1
@onready var current_state: Global.States

var monster:Monster
var direction: Vector2
var is_attacking = false
var is_idle = false
var is_dead = false
var is_moving = false
var can_move = true
var attack_started = false


func _ready() -> void:
	monster = componentOwner as Monster
	aiComponent.is_active = true
	movementComponent.speed = speed
	attackComponent.attack_speed = attack_speed
	aiComponent.min_distance = distances["min"]
	aiComponent.max_distance = distances["max"]
	attackComponent.min_distance = distances["min"]
	attackComponent.max_distance = distances["max"]
	aiComponent.set_up_timer()
	attackComponent.connect("done_attacking", Callable(self, "process_attack"))
	monster.connect("take_damage", Callable(self, "take_damage"))
	direction = global_position.direction_to(player.global_position)

func _process(delta: float) -> void:
	if is_dead:
		monster.current_anim = Global.AnimationState.DEATH
		return
		
	if !is_dead:
		direction = movementComponent.direction
		
		current_state = aiComponent.update_ai()
		
		movementComponent.proximity = aiComponent.proximity
		attackComponent.proximity = aiComponent.proximity
			
		match current_state:
			Global.States.ATTACK:
				attack()
			Global.States.MOVE:
				move()
			Global.States.IDLE:
				can_move = true
				movementComponent.is_active = false
				attackComponent.is_active = false
				monster.current_anim = Global.AnimationState.IDLE
	
	
func process_attack(done_attacking: bool):
	aiComponent.is_attacking = !done_attacking
	aiComponent.is_resting = done_attacking
	if done_attacking:
		print("done")
		aiComponent.is_attacking = false
		aiComponent.is_resting = true
		aiComponent.rest_timer.start()
		
func move():
	if !can_move:
		return
	movementComponent.is_active = true
	attackComponent.is_active = false
	direction = movementComponent.direction
	monster.current_anim = Global.AnimationState.WALK
	movementComponent.update_interval = 0
	can_move = false
	
		
func attack():
	if attack_started:
		return
	movementComponent.is_active = false
	attackComponent.is_active = true
	attackComponent.direction = direction
	attackComponent.start_attack()
	monster.current_anim = Global.AnimationState.ATTACK
	if attackComponent.is_active:
		aiComponent.is_idle = attackComponent.is_idle
	attack_started = true
	can_move = true
	
	
func start_attack():
	if !aiComponent.is_resting:
		aiComponent.is_attacking = true
		attack_started = false
func take_damage():
	monster.sprite.self_modulate = Color(1,0,0,1)
	if !aiComponent.is_attacking:
		monster.velocity = direction * -1 * speed * get_process_delta_time()
	await get_tree().create_timer(0.1).timeout
	monster.sprite.self_modulate = Color(1,1,1,1)
