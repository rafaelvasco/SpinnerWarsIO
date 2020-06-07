extends Node

signal game_connected(other_player_id)
signal game_disconnected()
signal game_info(game_code)
signal connection_failed()

var connected : bool = false
var game_code : String = ""

const MAIN_SERVER_WS_URL = "wss://spinnerioms.azurewebsites.net"

func _ready():
# warning-ignore:return_value_discarded
	MultiplayerClient.connect("connected", self, "_on_network_connected")
# warning-ignore:return_value_discarded
	MultiplayerClient.connect("connection_failed", self, "_on_connection_failed")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected",self,"_on_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed",self,"_on_connection_failed")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")


func host():
	self.connected = false
# warning-ignore:return_value_discarded
	MultiplayerClient.host_game(MAIN_SERVER_WS_URL)

func join(code : String):
	self.game_code = code
	self.connected = false
# warning-ignore:return_value_discarded
	MultiplayerClient.join_game(MAIN_SERVER_WS_URL, code)

func end(msg):
	connected = false
	MultiplayerClient.stop()
	get_tree().network_peer = null
	emit_signal("game_disconnected", msg)


func _on_network_connected(game_code : String):
	self.game_code = game_code
	print("Game code is %s" % self.game_code)
	emit_signal("game_info", game_code)
	get_tree().network_peer = MultiplayerClient.rtc_mp
	
	if get_tree().is_network_server():
		emit_signal("game_connected", null)

func _on_connection_failed():
	end("Connection Failed")


func _on_player_connected(id : int):
	print("Player connected")
	connected = true
	emit_signal("game_connected", id)

# warning-ignore:unused_argument
func _on_player_disconnected(id):
	end("Player Disconnected")

func _on_server_disconnected():
	_on_player_disconnected(1)
