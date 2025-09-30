extends Node

func _ready() -> void:
	
	for slot in %CardSlots.get_node("OpponentSlots").get_children():
		slot.card_slot_owner = "opponent"
		
	for slot in %CardSlots.get_node("PlayerSlots").get_children():
		slot.card_slot_owner = "player"
	
	pass
