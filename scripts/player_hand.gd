extends Node2D

const HAND_COUNT = 8
const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_WIDTH = 200
const HAND_Y_POSITION = 890

var player_hand = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var card_scene = preload(CARD_SCENE_PATH)
	
	center_screen_x = get_viewport().size.x / 2
	
	for i in range(HAND_COUNT):
		var new_card = card_scene.instantiate()
		%CardManager.add_child(new_card)
		new_card.name = "Card"
		add_card_to_hand(new_card)

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions()
	else:
		animate_card_to_position(card, card.starting_position)
	
func update_hand_positions():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_new_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position)
		
func calculate_new_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset
	

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()
		
