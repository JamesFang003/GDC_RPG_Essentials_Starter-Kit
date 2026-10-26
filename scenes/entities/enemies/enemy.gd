extends CharacterBody2D

signal died(exp:int)

enum State {IDLE,CHASE,RETURN,ATTACK,DEAD}
var state:State = State.IDLE

#@export var health:int = 100
@export var speed:int = 128
@export var attack_damage:int = 10
@export var attack_speed:float = 1
@export var aggro_range:float = 256.0
@export var attack_range:float = 80.0
@export var experience:int = 600

@export var death_packed:PackedScene 
@onready var animination_tree: AnimationTree = $AnimationTree
@onready var animination_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var spawn_point:Vector2 = global_position
@onready var nav_agent:NavigationAgent2D = $NavigationAgent2D
@onready var healthComponent: HealthComponent = $HealthComponent

var navigation_ready := false

func _ready() -> void:
	animination_tree.set_active(true)
	var map = nav_agent.get_navigation_map()
	if NavigationServer2D.map_get_iteration_id(map) == 0:
		await get_tree().physics_frame
	navigation_ready = true

func _physics_process(_delta: float) -> void:
	movement_loop()

func movement_loop() -> void:
	if state==State.DEAD or state==State.ATTACK:
		return
	
	if not is_instance_valid(player):
		var current_player := get_player()
		if not is_instance_valid(current_player):
			return
	
	var distance:float = global_position.distance_to(player.position)

	if distance <= attack_range:
		state=State.ATTACK
		attack()
	elif distance < aggro_range:
		state = State.CHASE
		move()
	elif global_position.distance_to(spawn_point) > 32:
		state = State.RETURN
		move()
	elif state != State.IDLE:
		state = State.IDLE
		update_animation()
	
func move() -> void:
	if not navigation_ready:
		return
	
	if state == State.CHASE:
		nav_agent.target_position=player.global_position
	elif state == State.RETURN:
		nav_agent.target_position=spawn_point
		
	var next_path_position:Vector2 = nav_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position)*speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(velocity)
	
	if state == State.IDLE or state==State.CHASE:
		if velocity.x < 0:
			$Sprite2D.flip_h = true
		elif velocity.x > 0:
			$Sprite2D.flip_h = false
	
	move_and_slide()
	update_animation()

func attack() -> void:
	#print("Attacking")
	if player==null:
		return
	var mouse_pos = player.global_position
	var attack_dir = (mouse_pos-global_position).normalized()
	$Sprite2D.flip_h = (attack_dir.x < 0) and abs(attack_dir.x) >= abs(attack_dir.y)
	$Hitbox.scale.x = -1 if attack_dir.x < 0 else 1
	animination_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	#print("Animation state: ", animination_tree.get("parameters/playback").get_current_node())
	
	await get_tree().create_timer(attack_speed).timeout
	state = State.IDLE
	#print("Idle")

func update_animation() -> void:
	match state:
		State.IDLE:
			animination_playback.travel("idle")
		State.CHASE:
			animination_playback.travel("run")
		State.RETURN:
			animination_playback.travel("run")
		State.ATTACK:
			animination_playback.travel("attack")

func take_damage(damage_taken:int) -> void:
	#print(damage_taken)
	var current_health = healthComponent.take_damage(damage_taken)
	if current_health <= 0:
		death()

func death() -> void:
	var death_scene: Node2D = death_packed.instantiate()
	death_scene.position = global_position+Vector2(0.0,-32.0)
	%Effects.add_child(death_scene)
	died.emit(experience)
	queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	area.owner.take_damage(attack_damage)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	nav_agent.velocity = safe_velocity
	
func get_player() -> CharacterBody2D:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	return player
