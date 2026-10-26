## When extending in the future, make abstract, and implement physics process
class_name InputComponent
extends Node

@export var actor: CharacterBody2D
@export var move_direction: Vector2 = Vector2.ZERO
@export var jump_requested: bool = false
@export var jump_canceled: bool = false
@export var pause: bool = false
var attacking:bool = false

func is_requesting_horizontal() -> bool:
	return move_direction.x != 0.0

func is_requesting_vertical() -> bool:
	return move_direction.y != 0.0

func is_jump_requested() -> bool:
	return jump_requested

func is_jump_canceled() -> bool:
	return jump_canceled

func is_pause() -> bool:
	return pause

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	move_direction = Input.get_vector("Left","Right","Up","Down")
	var toggle_pause = Input.is_action_just_pressed("Space")
	if toggle_pause:
		pause = !pause
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#print("Attacking")
		attacking = true
	else:
		attacking = false
