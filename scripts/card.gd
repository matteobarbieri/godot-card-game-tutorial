extends Node2D

signal hovered
signal hovered_off


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All cards must be a child of Card Manager
	get_parent().connect_card_signals(self)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	#print("hovered")
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	#print("hovered off")
	emit_signal("hovered_off", self)
