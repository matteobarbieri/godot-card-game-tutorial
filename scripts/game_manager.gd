extends Node

func _ready() -> void:
	
	%PlayerDeck.deck_owner = "player"
	%OpponentDeck.deck_owner = "opponent"
	
	%PlayerHand.hand_owner = "player"
	%OpponentHand.hand_owner = "opponent"
	
	for slot in %CardSlots.get_node("OpponentSlots").get_children():
		slot.card_slot_owner = "opponent"
		
	for slot in %CardSlots.get_node("PlayerSlots").get_children():
		slot.card_slot_owner = "player"
