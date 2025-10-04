extends Node

const STARTING_HEALTH = 20

const HEALTH_Y = 500
const PLAYER_HEALTH_X = 300
const OPPONENT_HEALTH_X = 1600

var player_type
var health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = STARTING_HEALTH
	
	var x = PLAYER_HEALTH_X if player_type == "player" else OPPONENT_HEALTH_X
	
	$Health.position.x = x
	$Health.position.y = HEALTH_Y
	
	update_health()

func update_health():
	$Health.text = str(health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
