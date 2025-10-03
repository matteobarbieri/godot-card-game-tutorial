extends Node2D

var player_deck = ["Warrior", "Wood_Elf", "Wizard", "Warrior", "Warrior", "Warrior", "Warrior", "Warrior"]

const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 0.2
const STARTING_HAND_SIZE = 5

#var player_hand_reference
var card_database_reference
var drawn_card_this_turn = false
var deck_owner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RichTextLabel.text = str(player_deck.size())
	
	card_database_reference = preload("res://scripts/card_database.gd")
	
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		if deck_owner == "player":
			drawn_card_this_turn = false
		
	if deck_owner == "player":
		drawn_card_this_turn = true
	
func draw_card():
	
	if drawn_card_this_turn:
		return
		
	if deck_owner == "player":
		drawn_card_this_turn = true
	
	player_deck.shuffle()
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	$RichTextLabel.text = str(player_deck.size())
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	var card_scene = preload(CARD_SCENE_PATH) 
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://assets/ai_" + card_drawn.to_lower() + "_card.png")
	
	
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.card_type = card_database_reference.CARDS[card_drawn][2]
	
	if new_card.card_type == "Monster":
		new_card.attack = card_database_reference.CARDS[card_drawn][0]
		new_card.health = card_database_reference.CARDS[card_drawn][1]
		new_card.get_node("Attack").text = str(new_card.attack)
		new_card.get_node("Health").text = str(new_card.health)
	
	# TODO Change this probably
	#new_card.position.x = 140
	#new_card.position.y = 955
	
	new_card.position.x = position.x
	new_card.position.y = position.y
	
	%CardManager.add_child(new_card)
	new_card.name = "Card"
	
	# Assign an owner to the card
	new_card.card_owner = deck_owner
	
	if deck_owner == "player":
		%PlayerHand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
		# We play the flip animation only for the cards we can see
		new_card.get_node("AnimationPlayer").play("card_flip")
	else:
		# We can't interact with opponent's hands
		new_card.get_node("Area2D").get_node("CollisionShape2D").disabled = true
		%OpponentHand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
	
	
