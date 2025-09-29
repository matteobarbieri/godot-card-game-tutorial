extends Node2D

var player_deck = ["Warrior", "Wood_Elf", "Wizard", "Warrior"]

const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 0.2

var player_hand_reference
var card_database_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_hand_reference = $"../PlayerHand"
	$RichTextLabel.text = str(player_deck.size())
	
	card_database_reference = preload("res://scripts/card_database.gd")
	
func draw_card():
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
	new_card.get_node("Attack").text = str(card_database_reference.CARDS[card_drawn][0])
	new_card.get_node("Health").text = str(card_database_reference.CARDS[card_drawn][1])
	
	
	%CardManager.add_child(new_card)
	new_card.name = "Card"
	player_hand_reference.add_card_to_hand(new_card, CARD_DRAW_SPEED)
