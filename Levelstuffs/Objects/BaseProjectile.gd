extends Area2D    
class_name BaseProjectile

var velocity:Vector2 = Vector2(0,0)
var cooldown:int = 10

var projectileOwner # a gente ta usando essa variavel
var power := 1

var used:bool = false

func launch(direction:Vector2, speed:float):
	velocity = direction * speed    

func _physics_process(delta: float) -> void:
	position += velocity
	if cooldown > 0:
		cooldown -= 1

func _on_body_entered(body):
	if not used:
		before_hit()
		call_deferred("on_hit")
		# print(body.name + " entered!")

func before_hit():
	pass

func on_hit():
	pass

func apply_additional_data(data: Dictionary):
	if data.has("direction") and data.has("speed"):
		launch(data.direction, data.speed)
	if data.has("rotation"):
		rotation = data.rotation
	if data.has("power"):
		power = data.power
	if data.has("owner_id"):
		if GPStats.is_multiplayer:
			if (JolasGame.instance.charDict.has(data["owner_id"])):
				projectileOwner = JolasGame.instance.charDict[data["owner_id"]]
		if data["owner_id"] == -1:
			projectileOwner = GPStats.charObject
		pass

func play_sfx(name:String, volumeDB:float = 0.0):
	if $AudioStreamPlayer2D.playing: $AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.stream = load("res://Gamestuffs/Sounds/Ingame/" + name + ".ogg")
	$AudioStreamPlayer2D.volume_db = GeneralUtils.get_volume_db('sfx', volumeDB)
	$AudioStreamPlayer2D.play()
