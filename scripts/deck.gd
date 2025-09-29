extends Node2D

var player_deck = ["Knight", "Knight", "Knight"]

const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 1

var player_hand_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	player_hand_reference = $"../PlayerHand"
	$RichTextLabel.text = str(player_deck.size())
	


func draw_card():
	
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	$RichTextLabel.text = str(player_deck.size())
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	var card_scene = preload(CARD_SCENE_PATH) 
	
	var new_card = card_scene.instantiate()
	%CardManager.add_child(new_card)
	new_card.name = "Card"
	player_hand_reference.add_card_to_hand(new_card, CARD_DRAW_SPEED)
