extends CharacterBody2D

signal game_over(victorious:bool)
signal update_hp(health:int)

enum State {IDLE,RUN,ATTACK,DEAD}
var state:State = State.IDLE

@export var health:int = 100
@export var attack_damage = 50
var speed:float = 300.0
const JUMP_VELOCITY = -400.0
var attack_speed = 0.6
@onready var input: InputComponent = $InputComponent

@onready var animination_tree: AnimationTree = $AnimationTree
@onready var animination_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@export var death_packed:PackedScene 

func _ready() -> void:
	animination_tree.set_active(true)
	calculate_stats()

func _physics_process(_delta: float) -> void:
	if state!= State.ATTACK:
		movement_loop()
	
func _unhandled_input(_event: InputEvent) -> void:
	if input.attacking:
		attack()
	
func movement_loop() -> void:
	#print(input.move_direction)
	set_velocity(input.move_direction*speed)
	move_and_slide()
	
	if state==State.IDLE or state==State.RUN:
		if input.move_direction.x < 0:
			$Sprite2D.flip_h=true
		elif input.move_direction.x > 0:
			$Sprite2D.flip_h=false
	
	if input.move_direction!=Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif input.move_direction==Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()
	
func update_animation() -> void:
	match state:
		State.IDLE:
			animination_playback.travel("idle")
		State.RUN:
			animination_playback.travel("run")
		State.ATTACK:
			animination_playback.travel("attack")

func attack() -> void:
	if state == State.ATTACK:
		return
	#print("Attacking")
	state = State.ATTACK
	
	var mouse_pos = get_global_mouse_position()
	var attack_dir = (mouse_pos-global_position).normalized()
	$Sprite2D.flip_h = (attack_dir.x < 0) and abs(attack_dir.x) >= abs(attack_dir.y)
	$Hitbox.scale.x = -1 if attack_dir.x < 0 else 1
	animination_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	await get_tree().create_timer(attack_speed).timeout
	state = State.IDLE
	#print("Idle")

func take_damage(damage_taken:int) -> void:
	#print(damage_taken)
	health -= damage_taken
	update_hp.emit(health)
	if health <= 0:
		death()

func death() -> void:
	var death_scene: Node2D = death_packed.instantiate()
	death_scene.position = global_position+Vector2(0.0,-32.0)
	%Effects.add_child(death_scene)
	queue_free()
	game_over.emit(false)

func _on_hitbox_area_entered(area: Area2D) -> void:
	area.owner.take_damage(attack_damage)

func calculate_stats() -> void:
	attack_speed = Equations.calculate_attack_speed()
	var time_factor:float = Equations.BASE_ATTACK_SPEED / attack_speed
	animination_tree.set("parameters/attack/TimeScale/scale",time_factor)
	print(attack_speed)
