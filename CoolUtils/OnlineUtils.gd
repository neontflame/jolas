extends Node

var masterServer:String = 'https://neontflame.especulamente.com.br/jolas/ms'
var ipEntered:String = '127.0.0.1'
var portEntered:int = 7000
var username:String = ''
var serverName:String = ''

func _ready() -> void:
	MultiplayerMayhem.PORT = portEntered
	MultiplayerMayhem.player_info["name"] = username
	$HTTPRequest.request_completed.connect(func(result, response_code, headers, body):
		print(body.get_string_from_utf8())
	)

func sendServerHeartbeat():
	var loadedModsStringed = ''
	
	var modIndex:int = 1
	for mod in GameUtils.loadedModsFolderless:
		loadedModsStringed += mod
		if len(GameUtils.loadedModsFolderless) > modIndex:
			loadedModsStringed += "\n"
		modIndex += 1
		
	var nomeServidor = serverName
	if serverName == '':
		nomeServidor = 'Servidor de ' + username
	
	var heartbeatUrl = "%s/heartbeat.php?port=%s&nome=%s" % [
		masterServer,
		portEntered,
		nomeServidor.uri_encode(),
	]
	if len(GameUtils.loadedModsFolderless) > 0:
		heartbeatUrl += "&mods=" + loadedModsStringed.uri_encode()
	
	print(heartbeatUrl)
	var requesty = $HTTPRequest.request(heartbeatUrl)
	if requesty != OK:
		print("[ONLINEUTILS] Heartbeat falhou... seu server não vai aparecer publicamente!")
		return
	$Timer.start()

func _on_timer_timeout() -> void:
	if GPStats.is_hosting:
		sendServerHeartbeat()
