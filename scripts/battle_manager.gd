extends Node

var battle_timer
var empty_monster_card_slots = []
var opponent_cards_on_battlefield = []
var player_cards_on_battlefield = []


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
		chosen_card.z_index = 1
		#is_hovering_on_card = false
		chosen_card.card_slot_card_is_in = selected_slot
		
		%"OpponentHand".remove_card_from_hand(chosen_card)
		opponent_cards_on_battlefield.append(chosen_card)
		
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
	
	await wait(1.0)
	
	# Check if free monster card slots, if not end turn
	if empty_monster_card_slots.size() != 0:
		# Play the card in hand with highest attack
		try_play_card_with_highest_attack()
		
	# Wait for the playing animation to be finished
	await wait(1.0)
	
	# Try attack
	if opponent_cards_on_battlefield.size() > 0:
		for card in opponent_cards_on_battlefield:
			if player_cards_on_battlefield.size() == 0:
				# Perform a direct attack
				direct_attack(card, "opponent")
			else:
				attack(card, "opponent")
				
			await wait(0.5)
		
	end_opponent_turn()


func wait(wait_time):
	battle_timer.wait_time = wait_time
	battle_timer.start()
	await battle_timer.timeout

func direct_attack(attacking_card, attacker):
	
	# Wait 1 second
	await wait(1.0)
	
	var new_pos
	var target
	
	if attacker == "opponent":
		target = "player"
		new_pos = Vector2(attacking_card.position.x, attacking_card.position.y + 20)
	else:
		target = "opponent"
		new_pos = Vector2(attacking_card.position.x, attacking_card.position.y - 20)
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, 0.2)
	deal_direct_damage(attacking_card, target)
	tween.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, 0.2)
	
	

func deal_direct_damage(card, target):
	
	var player_reference
	
	if target == "player":
		player_reference = %Player
	else:
		player_reference = %Opponent
		
	player_reference.health -= card.attack
	player_reference.update_health()
	
func attack(card, attacker):
	var valid_card_targets_reference
	var defender
	
	if attacker == "player":
		valid_card_targets_reference = opponent_cards_on_battlefield
		defender = "opponent"
	else:
		valid_card_targets_reference = player_cards_on_battlefield
		defender = "player"
	
	#var target_card = valid_card_targets_reference[randi_range(0, valid_card_targets_reference.size() - 1)]
	var target_card = valid_card_targets_reference.pick_random()
	
	# TODO Tween animation to move the card towards target
	
	var new_pos = card.position + 0.8 * (target_card.position - card.position)
	
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, 0.2)
	await tween.finished
	deal_damage_to_card(card, target_card, attacker)
	deal_damage_to_card(target_card, card, defender)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(card, "position", card.card_slot_card_is_in.position, 0.2)
	await tween2.finished
	
	update_card(card, attacker)
	update_card(target_card, defender)
	
func update_card(card, owner):
	if card.health <= 0:
		var cards_on_battlefield_reference
		if owner == "player":
			cards_on_battlefield_reference = player_cards_on_battlefield
		else:
			cards_on_battlefield_reference = opponent_cards_on_battlefield
			
		cards_on_battlefield_reference.erase(card)
		
		# TODO Also put it in a discard pile?
		card.card_slot_card_is_in.card_in_slot = null
		card.card_slot_card_is_in = null
		card.visible = false
	else:
		card.update_stats_display()
	
	
func deal_damage_to_card(attacking_card, target_card, attacker):
	
	target_card.health -= attacking_card.attack
