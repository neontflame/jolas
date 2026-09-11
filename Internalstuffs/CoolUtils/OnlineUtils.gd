extends Node

var masterServer:String = 'https://neontflame.especulamente.com.br/jolas/ms'
var ipEntered:String = '127.0.0.1'
var portEntered:int = 7000
var username:String = ''
var serverName:String = ''

#region Multiplayer Normals
func _ready() -> void:
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
#endregion

#region Multiplayer Derangement
# Emitted when UPnP port mapping setup is completed (regardless of success or failure).
signal upnp_completed(error)

var thread = null
var upnp = null

func setupUPNP(server_port):
	print("[ONLINEUTILS] Verificando UPNP")
	var upnp = UPNP.new()
	var err = upnp.discover()
	
	if err != UPNP.UPNP_RESULT_SUCCESS:
		print("[ONLINEUTILS] ih deu um erro")
		push_error(str(err))
		upnp_completed.emit(err)
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		print("[ONLINEUTILS] UPNP deu certo!!!!")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		upnp_completed.emit(UPNP.UPNP_RESULT_SUCCESS)
		return
	print("[ONLINEUTILS] Ok voce provavelmente vai ter que port forwardear isso na marra")

func setupUPNPThreaded():
	thread = Thread.new()
	print("[ONLINEUTILS] vamos abrir uma thread pra isso!")
	thread.start(setupUPNP.bind(portEntered))

func _exit_tree():
	if thread:
		thread.wait_to_finish()

func closeUPNPThread():
	if upnp != null:
		upnp.delete_port_mapping(portEntered)
		print("[ONLINEUTILS] adios upnp ...")
#endregion
