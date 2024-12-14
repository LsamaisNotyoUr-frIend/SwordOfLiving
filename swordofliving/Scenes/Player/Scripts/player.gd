class_name Player
extends CharacterBody2D

@export var speed:float = 1500
@export var anim_player:AnimationPlayer
@export var hitbox: PlayerHitBox
@export var hurtbox: PlayerHurtBox
@export var health: int
@export var health_bar:PlayerHealthBar
@export var sprite:AnimatedSprite2D
@export var stun_time: float

enum AnimationState {IDLE, WALK, ATTACK}
var current_anim: AnimationState = AnimationState.IDLE
var current_direction: String = "downleft"
var is_attacking: bool = false
var input:Vector2
var can_move:bool = true
var is_dead:bool = false
var reverse:bool = false
var hitbox_active: bool = false

var reverse_time:float

signal EmptyHealthBar

func _ready() -> void:
	Global.player = self
	hitbox.enablePlayer()
	hurtbox.enablePlayer()
	health_bar.init_health(health)
	anim_player.play("idle1up")
	
func _physics_process(delta: float) -> void:
	
	input = Input.get_vector("left","right", "up", "down").normalized()
	
	if is_attacking:
		velocity = Vector2.ZERO  # Stop movement during attack
	elif input != Vector2.ZERO and can_move:
		current_anim = AnimationState.WALK
		current_direction = get_direction(input.angle())
		velocity = input * speed * delta
	else:
		current_anim = AnimationState.IDLE
		velocity = Vector2.ZERO

	if Input.is_action_just_pressed("attack") and can_move:
		is_attacking = true
		current_anim = AnimationState.ATTACK
		await get_tree().create_timer(0.98).timeout
		is_attacking = false 
		
	if reverse:
		velocity = (input * -1) * speed * delta
		
	play_animation()
	move_and_slide()
	
func _process(delta: float) -> void:
	if reverse and !is_dead:
		reverse_time -= delta
		sprite.self_modulate = Color(1, 0, 0, 1)
	else:
		sprite.self_modulate = Color(1, 1, 1, 1)
		
	if reverse_time < 0:
		reverse = false
	
	if health <= 0:
		is_attacking = false
		is_dead = true
		can_move = false
	
func get_direction(angle) -> String:
	if angle > -PI / 8 and angle <= PI / 8:
		return "right"
		
	elif angle > PI / 8 and angle <= 3 * PI / 8:
		return "downright"
		
	elif angle > 3 * PI / 8 and angle <= 5 * PI / 8:
		return "down"
		
	elif angle > 5 * PI / 8 and angle <= 7 * PI / 8:
		return "downleft"
		
	elif angle > -3 * PI / 8 and angle <= -PI / 8:
		return "upright"
		
	elif angle > -5 * PI / 8 and angle <= -3 * PI / 8:
		return "up"
		
	elif angle > -7 * PI / 8 and angle <= -5 * PI / 8:
		return "upleft"
		
	else:
		return "left"
		
func play_animation():
	var anim_name: String
	
	if current_anim == AnimationState.IDLE:
		anim_name = "idle1" + current_direction
	elif current_anim == AnimationState.WALK:
		anim_name = "walk" + current_direction
	elif current_anim == AnimationState.ATTACK:
		anim_name = "attack" + current_direction

	anim_player.play(anim_name)
	
func takeDamage(damage: int) -> void:
	health -= damage
	can_move = false
	health_bar.set_health(health)
	reverse = true
	reverse_time = 0.2
	await get_tree().create_timer(stun_time).timeout
	can_move = true
	
func activate_hitbox():
	if hitbox_active:
		return
	hitbox.collision.disabled = false
	hitbox_active = true
		
