extends Node2D


onready var Player = preload("res://Entities/Player.tscn")

var player
var connected_player
onready var game_scene = $GameScene
onready var lobby = $Lobby
onready var msg_panel = $MsgPanel
onready var msg_panel_msg = $MsgPanel/Msg
onready var msg_timer = $MsgPanel/Timer
onready var game_code_label = $GameScene/GameCodeLabel

var sword_props = {
	
	"fire": {
		
		0: {
			"texture": preload("res://Assets/sword_lvl1_fire.png"),
			"weight": 1,
			"scale": 0.5,
		},
		1: {
			"texture": preload("res://Assets/sword_lvl2_fire.png"),
			"weight": 3,
			"scale": 0.5
		},
		2: {
			"texture": preload("res://Assets/sword_lvl3_fire.png"),
			"weight": 7,
			"scale": 0.4
		},
		3: {
			"texture": preload("res://Assets/sword_lvl4_fire.png"),
			"weight": 12,
			"scale": 0.25
		}
	},
	"ice": {
		
		0: {
			"texture": preload("res://Assets/sword_lvl1_ice.png"),
			"weight": 1,
			"scale": 1
		},
		1: {
			"texture": preload("res://Assets/sword_lvl2_ice.png"),
			"weight": 3,
			"scale": 1
		},
		2: {
			"texture": preload("res://Assets/sword_lvl3_ice.png"),
			"weight": 7,
			"scale": 0.8
		},
		3: {
			"texture": preload("res://Assets/sword_lvl4_ice.png"),
			"weight": 12,
			"scale": 0.5
		}
	},
	"light": {
		
		0: {
			"texture": preload("res://Assets/sword_lvl1_light.png"),
			"weight": 1,
			"scale": 1
		},
		1: {
			"texture": preload("res://Assets/sword_lvl2_light.png"),
			"weight": 3,
			"scale": 1
		},
		2: {
			"texture": preload("res://Assets/sword_lvl3_light.png"),
			"weight": 7,
			"scale": 0.8
		},
		3: {
			"texture": preload("res://Assets/sword_lvl4_light.png"),
			"weight": 12,
			"scale": 0.5
		}
	},
	"magic": {
		
		0: {
			"texture": preload("res://Assets/sword_lvl1_magic.png"),
			"weight": 1,
			"scale": 1
		},
		1: {
			"texture": preload("res://Assets/sword_lvl2_magic.png"),
			"weight": 3,
			"scale": 1
		},
		2: {
			"texture": preload("res://Assets/sword_lvl3_magic.png"),
			"weight": 7,
			"scale": 0.8
		},
		3: {
			"texture": preload("res://Assets/sword_lvl4_magic.png"),
			"weight": 12,
			"scale": 0.5
		}
	},
	"poison": {
		
		0: {
			"texture": preload("res://Assets/sword_lvl1_poison.png"),
			"weight": 1,
			"scale": 1
		},
		1: {
			"texture": preload("res://Assets/sword_lvl2_poison.png"),
			"weight": 3,
			"scale": 1
		},
		2: {
			"texture": preload("res://Assets/sword_lvl3_poison.png"),
			"weight": 7,
			"scale": 0.8
		},
		3: {
			"texture": preload("res://Assets/sword_lvl4_poison.png"),
			"weight": 12,
			"scale": 0.5
		}
	}
}

func _ready():
	Game.connect("game_connected", self, "_on_game_connected") 
	Game.connect("game_disconnected", self, "_on_game_disconnected")
	Game.connect("game_info", self, "_on_game_info")

func end_game(msg):
	player.queue_free()
	if connected_player:
		connected_player.queue_free()
	game_scene.hide()
	player = null
	connected_player = null
	_show_msg(msg, 2.5)
	game_code_label.text = ""


func _on_game_connected(connected_player_id):
	print("ON GAME CONNECTED")
	msg_panel.hide()
	$Lobby/HBoxContainer/MatchCode.text = ""
	lobby.hide()
	game_scene.show()
	
	if not player:
		player = Player.instance()
		player.set_network_master(get_tree().get_network_unique_id())
		player.set_name(str(get_tree().get_network_unique_id()))
		player.position = game_scene.get_node(str(get_tree().get_network_unique_id())).position
		add_child(player)
	
	
	if connected_player_id:
		connected_player = Player.instance()
		connected_player.set_name(str(connected_player_id))
		connected_player.set_network_master(connected_player_id)
		connected_player.position = game_scene.get_node(str(connected_player_id)).position
		add_child(connected_player)
	
	
func _on_game_disconnected(msg):
	end_game("Game Ended: " + msg)


func _on_game_info(game_code):
	game_code_label.text = "Game Code: %s" % game_code


func _on_HostButton_pressed():
	Game.host()
	lobby.hide()
	_show_msg("Creating game...")
	

func _on_JoinButton_pressed():
	print('Joining match ' + $Lobby/HBoxContainer/MatchCode.text)
	Game.join($Lobby/HBoxContainer/MatchCode.text)
	lobby.hide()
	_show_msg("Joining...")

func _show_msg(msg, time=null):
	msg_panel.show()
	msg_panel_msg.text = msg
	
	if time:
		msg_timer.start(time)
	

func _hide_msg():
	msg_panel.hide()


func _on_MsgTimer_timeout():
	msg_panel.hide()
	lobby.show()


func _on_ButtonEndGame_pressed():
	Game.end("Player exited")
