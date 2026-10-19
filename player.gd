extends CharacterBody2D

enum State {IDLE,RUN,ATTACK,DEAD}
var state:State = State.IDLE

var speed:float = 300.0
const JUMP_VELOCITY = -400.0
var attack_speed = 0.6
@onready var input: InputComponent = $InputComponent

@onready var animination_tree: AnimationTree = $AnimationTree
@onready var animination_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready() -> void:
	animination_tree.set_active(true)

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
	print("Attacking")
	state = State.ATTACK
	
	var mouse_pos = get_global_mouse_position()
	var attack_dir = (mouse_pos-global_position).normalized()
	print(mouse_pos)
	print(attack_dir)
	$Sprite2D.flip_h = (attack_dir.x < 0) and abs(attack_dir.x) >= abs(attack_dir.y)
	animination_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	await get_tree().create_timer(attack_speed).timeout
	state = State.IDLE
	print("Idle")
