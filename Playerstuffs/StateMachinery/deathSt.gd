extends StatePattern

var velocity:Vector2 = Vector2(0,0)
var calledIt:bool = false

func enter_state():
	calledIt = false
	Player.invulnFrames = 240.0
	
	velocity = Vector2(Player.velocity.x * 0.016, -20)
	Player.motion = Vector2(0, 0)
	Player.velocity = Vector2(0, 0)
	
	Player.plySprite.self_modulate.a = 1.0
	Player.plySprite.play('battleSpin')
	Player.plySprite.speed_scale = 1.0

func update():
	Player.plySprite.position += velocity
	velocity.y += 1
	
	if Player.plySprite.position.y > 200:
		if !calledIt:
			calledIt = true
			
			JolasGame.instance.fadeIn(1, 
			func(): 
				print('ok agora volta')
				JolasGame.instance.respawnPlayer() 
				JolasGame.instance.fadeOut(1)
				)
