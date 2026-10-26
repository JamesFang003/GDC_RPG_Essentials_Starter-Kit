extends Control

func _ready() -> void:
	update_level()

func update_hp_bar(hp:int) -> void:
	%HitPointsBar.value = hp

func update_level() -> void:
	%Label.set_text(str(PlayerData.level))
