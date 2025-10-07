extends Node

var battle_timer
var opponent_cards_on_battlefield = []
var player_cards_on_battlefield = []

var is_opponents_turn = false

func get_monster_slots(owner):
	var player_reference
	if owner == "player":
		player_reference = %CardSlots/PlayerSlots
	elif owner == "opponent":
		player_reference = %CardSlots/OpponentSlots
	else:
		assert(false)
		
	var slots_reference = player_reference.get_children()

	var i = 0
	
	var monster_slots = []
	
	for slot in slots_reference:
		if i >= 5:
			break
		monster_slots.append(slot)
		i += 1
	return monster_slots
	
	
#func get_empty_monster_slots2():
	#"""
	#Returns empty monster slots from opponents
	#"""
	#var empty_monster_card_slots = []
	#
	#var i = 0
	#for slot in %CardSlots.get_node("OpponentSlots").get_children():
		#if i >= 5:
			#break
		#if slot.card_in_slot == null:
			#empty_monster_card_slots.append(slot)
		#i += 1
	#return empty_monster_card_slots

func get_empty_monster_slots():
	"""
	Returns empty monster slots from opponents
	"""
	var all_monster_slots = get_monster_slots("opponent")
	var empty_monster_card_slots = []
	
	for slot in all_monster_slots:
		if slot.card_in_slot == null:
			empty_monster_card_slots.append(slot)
	
	return empty_monster_card_slots

func _ready() -> void:
	battle_timer = %BattleTimer
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
func _on_end_turn_button_pressed() -> void:
	is_opponents_turn = true
	opponent_turn()
	
	%CardManager.unselect_selected_monster()
	
	refresh_player_cards()
	
	
	

func end_opponent_turn():
	# End turn
	# Reset player deck draw
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
	is_opponents_turn = false
	%PlayerDeck.drawn_card_this_turn = false
	%CardManager.played_monster_card_this_turn = false
	

func opponent_card_selected(defending_card):
	var attacking_card = %CardManager.selected_monster
	if attacking_card and defending_card in opponent_cards_on_battlefield:
		attack(attacking_card, "player", defending_card)
		%CardManager.selected_monster = null
		
	
	
func refresh_player_cards() -> void:
	var all_monster_slots = get_monster_slots("player")
	
	for slot in all_monster_slots:
		if slot.card_in_slot != null:
			slot.card_in_slot.has_attacked_this_turn = false
	

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
		var selected_slot = get_empty_monster_slots().pick_random()
			
		
		
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
		selected_slot.card_in_slot = chosen_card
		

func opponent_turn():
	
	print("empty monster slots: " + str(get_empty_monster_slots().size()))
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false

	if %OpponentDeck.player_deck.size() > 0:
		%OpponentDeck.draw_card()
	
	await wait(1.0)
	
	# Check if free monster card slots, if not end turn
	if get_empty_monster_slots().size() != 0:
		# Play the card in hand with highest attack
		try_play_card_with_highest_attack()
		
	# Wait for the playing animation to be finished
	await wait(1.0)
	
	# Try attack
	if opponent_cards_on_battlefield.size() > 0:
		var opponent_cards_on_battlefield_cp = opponent_cards_on_battlefield.duplicate()
		for card in opponent_cards_on_battlefield_cp:
			if player_cards_on_battlefield.size() == 0:
				# Perform a direct attack
				await direct_attack(card, "opponent")
			else:
				await attack(card, "opponent")
				
			#await wait(0.5)
		
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
	await tween.finished
	deal_direct_damage(attacking_card, target)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, 0.2)
	await tween2.finished
	

func deal_direct_damage(card, target):
	
	var player_reference
	
	if target == "player":
		player_reference = %Player
	else:
		player_reference = %Opponent
		
	player_reference.health -= card.attack
	player_reference.update_health()
	
func attack(card, attacker, target_card = null):
	var valid_card_targets_reference
	var defender
	
	if attacker == "player":
		valid_card_targets_reference = opponent_cards_on_battlefield
		defender = "opponent"
	else:
		valid_card_targets_reference = player_cards_on_battlefield
		defender = "player"
		#var target_card = valid_card_targets_reference[randi_range(0, valid_card_targets_reference.size() - 1)]
		target_card = valid_card_targets_reference.pick_random()
	
	
	
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
		var discard_pile_reference
		if owner == "player":
			cards_on_battlefield_reference = player_cards_on_battlefield
			discard_pile_reference = %Player/DiscardPile
		else:
			cards_on_battlefield_reference = opponent_cards_on_battlefield
			discard_pile_reference = %Opponent/DiscardPile
			
		cards_on_battlefield_reference.erase(card)
		
		# Also put it in a discard pile?
		card.card_slot_card_is_in.card_in_slot = null
		card.card_slot_card_is_in.get_node("Area2D/CollisionShape2D").disabled = false
		card.card_slot_card_is_in = null
		
		# Disable card's collision
		card.get_node("Area2D/CollisionShape2D").disabled = true
		
		
		if discard_pile_reference.cards_in_discard_pile.size() == 0:
			card.z_index = 2
		else:
			card.z_index = discard_pile_reference.cards_in_discard_pile[-1].z_index + 1
		
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", discard_pile_reference.position, 0.2)
		await tween.finished
		
		#card.visible = false
	else:
		card.update_stats_display()
	
	
func deal_damage_to_card(attacking_card, target_card, attacker):
	
	target_card.health -= attacking_card.attack
