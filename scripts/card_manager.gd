extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const DEFAULT_CARD_SCALE = 0.8
const CARD_BIGGER_SCALE = 0.85
const CARD_SMALLER_SCALE = 0.6

var screen_size
var card_being_dragged
var is_hovering_on_card

var player_hand_reference

var played_monster_card_this_turn = false

var selected_monster

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_hovered_over_card(card):
	if card.card_slot_card_is_in:
		return
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	
	
func on_hovered_off_card(card):
	
	if card.health <= 0:
		return
	
	if !card.card_slot_card_is_in and !card_being_dragged :
		highlight_card(card, false)
		
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false	
	

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
		card.z_index = 1

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	
	var result = space_state.intersect_point(parameters)
	
	if result.size() > 0:
		#print(result[0].collider.get_parent())
		
		return get_card_with_higher_z(result)
	
	return null
	
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	
	var result = space_state.intersect_point(parameters)
	
	if result.size() > 0:
		#print(result[0].collider.get_parent())
		
		return result[0].collider.get_parent()
	
	return null


func get_card_with_higher_z(result):
	var highest_z = -999
	var card_to_return = null
	
	for r in result:
		var candidate_card = r.collider.get_parent()
		if candidate_card.z_index > highest_z:
			highest_z = candidate_card.z_index
			card_to_return = candidate_card
			
	return card_to_return
		

func card_clicked(card):
	
	print("Card clicked!")
	
	if card.card_slot_card_is_in:
		if %BattleManager.is_opponents_turn == false:
			if card.has_attacked_this_turn:
				return
			if %BattleManager.opponent_cards_on_battlefield.size() == 0:
				%BattleManager.direct_attack(card, "player")
				card.has_attacked_this_turn = true
				return
			else:
				select_card_for_battle(card)
		
		pass
	else:
		start_drag(card)


func unselect_selected_monster() -> void :
	if selected_monster:
		selected_monster.position.y += 20
		selected_monster = null
	

func select_card_for_battle(card):
	
	# Toggle selected card
	if selected_monster:
		# TODO this could probably be improved
		if selected_monster == card:
			card.position.y += 20
			selected_monster = null
		else:
			selected_monster.position.y += 20
			selected_monster = card
			card.position.y -= 20
	else:
		selected_monster = card
		card.position.y -= 20
	
	

func start_drag(card):
	card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
	card_being_dragged = card
	
func finish_drag():
	card_being_dragged.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
	var card_slot_found = raycast_check_for_card_slot()
	
	if card_slot_found and not card_slot_found.card_in_slot:
		# If card is the right slot
		if card_slot_found.card_slot_owner == "player" and card_being_dragged.card_type == card_slot_found.card_slot_type:
			if !played_monster_card_this_turn:
				# Card dropped in card slot
				
				played_monster_card_this_turn = true
				card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE)
				card_being_dragged.z_index = -1
				is_hovering_on_card = false
				card_being_dragged.card_slot_card_is_in = card_slot_found
				
				player_hand_reference.remove_card_from_hand(card_being_dragged)
				
				# Card dropped in empty card slot
				card_being_dragged.position = card_slot_found.position
				#card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
				card_slot_found.card_in_slot = card_being_dragged
				card_slot_found.get_node("Area2D/CollisionShape2D").disabled = true
				%BattleManager.player_cards_on_battlefield.append(card_being_dragged)
				card_being_dragged = null
				return
		
	player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)
	

func on_left_click_released():
	if card_being_dragged:
		finish_drag()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y)
		)
