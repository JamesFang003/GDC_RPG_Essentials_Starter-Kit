class_name HealthComponent
extends Node

@export var max_health: int = 100
var health:int

func _ready() -> void:
	health = max_health

func take_damage(damage_taken:int) -> int:
	if damage_taken <= 0:
		return health
	health = maxi(health - damage_taken, 0)
	return health
	
func heal_health(damage_heal:int) -> int:
	if damage_heal <= 0:
		return health
	health = mini(health + damage_heal, max_health)
	return health
	
func set_health(new_health:int) -> void:
	health = clampi(new_health, 0, max_health)

func get_health() -> int:
	return health
