class_name Monster
extends CharacterBody2D

enum AnimationState {IDLE, WALK, ATTACK, DEATH}

@export_enum("MELEE:02", "CHARGE:04", "RANGED:08") var enemy_type:int = 4
@export_color_no_alpha var color: Color
@export var distances: Dictionary = {
	"max": 200,
	"min": 60
}

@export_category("Components")
@export_group("DamageComponents")
@export var hurtbox: HurtBox
@export var hitbox: Hitbox
@export_group("AnimationComponents")
@export var anim_player: AnimationPlayer
@export var sprite: AnimatedSprite2D
@export_group("HealthComponents")
@export var health_bar: HealthBar
@export var health: int
@export_group("AttackComponents")
@export var attackListener: AttackListener
@export var components: Array[Component]

@export_category("Utilities")
@export_group("movement")
@export var attack_speed_multiplier:float = 1
@export var speed: float = 1500
@export_group("Extra_utilities")
@export var timer_value:float = 0.2
@export var death_time:float = 0.73
@export var reverse_time_value:float = 0.2


var current_direction: String = "downleft"
var current_anim= AnimationState.IDLE
var direction: Vector2 = Vector2.ZERO
var reverse_direction: Vector2
var can_move: bool = true
var reverse: bool = false
var is_attacking: bool = false
var is_dead:bool = false
var update_direction: bool = true
var timer:float
var const_speed: float
var movement_component: MovementComponent
var reverse_time = 0

@onready var player:Player = Global.player

func _ready() -> void:
	const_speed = speed
	hurtbox.enable()
	hitbox.enable()
	health_bar.init_health(health)
	for component in components:
		if component is MovementComponent:
			movement_component = component

func _physics_process(delta: float) -> void:
	if timer <= 0:
		reset_timer()
	if timer > 0 :
		timer -= delta
		
	print(direction)
		
	if can_move and !is_dead and !reverse:
		current_anim = AnimationState.WALK
		velocity = direction * speed * delta
		current_direction = get_direction(direction.angle())
	elif !can_move and !is_dead:
		current_anim = AnimationState.IDLE
		
	if health <= 0:
		is_dead = true
		
	if is_dead:
		can_move = false
		handle_death()
		
	if reverse:
		velocity = reverse_direction * speed * delta
		
	print(is_dead)
	handleAnimations()
	move_and_slide()
	
func _process(delta: float) -> void:
	if reverse and !is_dead:
		reverse_time -= delta
		sprite.self_modulate = Color(1, 0, 0, 1)
	else:
		sprite.self_modulate = Color(1, 1, 1, 1)
		
	if reverse_time < 0:
		can_move = true
		reverse = false
	

func reset_timer() -> void:
	if is_dead:
		return
	if update_direction and movement_component:
		await movement_component.handle_movement()
		reverse_direction = -direction
		timer = timer_value
	
## [takeDamage() method]
## Reduces the monster's health by the specified amount of damage, disables movement temporarily, and prints a debug message.
## After a delay of 0.5 seconds, the monster can move again.
##
## [u]Parameters:[/u]
## - [b]damage[/b] ([i]int[/i]): The amount of damage to apply to the monster's health.
func takeDamage(damage: int) -> void:
	reverse_time = 0
	reverse = true
	reverse_time = reverse_time_value
	health -= damage
	can_move = false
	health_bar.set_health(health)
	health_bar.visible = true
	await get_tree().create_timer(0.5).timeout
	health_bar.visible = false
	
	
func handle_death():
	emit_signal("death")
	current_anim = AnimationState.DEATH
	queue_free()
	
func handleAnimations():
	var anim_name: String
	
	if current_anim == AnimationState.IDLE:
		anim_name = "idle" + current_direction
	elif current_anim == AnimationState.WALK:
		anim_name = "walk" + current_direction
	elif current_anim == AnimationState.ATTACK:
		anim_name = "attack" + current_direction
	elif current_anim == AnimationState.DEATH:
		anim_name = "death" + current_direction

	anim_player.play(anim_name)
	
func get_direction(angle) -> String:
	if angle > -PI / 4 and angle <= PI / 4:
		return "right"

	elif angle > PI / 4 and angle <= 3 * PI / 4:
		return "down"

	elif angle > -3 * PI / 4 and angle <= -PI / 4:
		return "up"

	else:
		return "left"
	
	
	
