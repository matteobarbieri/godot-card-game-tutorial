extends Node

var battle_timer

var empty_monster_card_slots = []

func _ready() -> void:
	battle_timer = %BattleTimer
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	var i = 0
	for slot in %CardSlots.get_node("OpponentSlots").get_children():
		if i >= 5:
			break
		empty_monster_card_slots.append(slot)
		i += 1
	
func _on_end_turn_button_pressed() -> void:
	opponent_turn()

func end_opponent_turn():
	# End turn
	# Reset player deck draw
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
	
	%PlayerDeck.drawn_card_this_turn = false
	%CardManager.played_monster_card_this_turn = false
	

func try_play_card_with_highest_attack():
	var opponent_hand = %"OpponentHand".player_hand
	if opponent_hand.size() > 0:
		# Find card with highest attack
		var highest_attack = -999
		var chosen_card = null
	
		for card in opponent_hand:
			if card.card_type != "Monster":
				continue
			
			if card.attack > highest_attack:
				highest_attack = card.attack
				chosen_card = card
		
		# Assign it to the slot (pick randomly)
		var selected_slot = empty_monster_card_slots[
			randi_range(0, empty_monster_card_slots.size()-1)]
		
		chosen_card.scale = Vector2(%CardManager.CARD_SMALLER_SCALE, %CardManager.CARD_SMALLER_SCALE)
		chosen_card.z_index = -1
		#is_hovering_on_card = false
		chosen_card.card_slot_card_is_in = selected_slot
		
		%"OpponentHand".remove_card_from_hand(chosen_card)
		
		# Card dropped in empty card slot
		%"OpponentHand".animate_card_to_position(
			chosen_card, selected_slot.position, %"OpponentHand".DEFAULT_CARD_MOVE_SPEED)
		chosen_card.get_node("AnimationPlayer").play("card_flip")
		
		#card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		selected_slot.card_in_slot = true
		
		empty_monster_card_slots.erase(selected_slot)

func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false

	if %OpponentDeck.player_deck.size() > 0:
		%OpponentDeck.draw_card()
	
	# Wait 1 second
	battle_timer.start()
	await battle_timer.timeout
	
	# Check if free monster card slots, if not end turn
	if empty_monster_card_slots.size() == 0:
		end_opponent_turn()
		return
	
	# Play the card in hand with highest attack
	try_play_card_with_highest_attack()
	
	
		
	end_opponent_turn()
