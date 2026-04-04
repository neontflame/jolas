extends StatePattern

# todo: programar o fucking dash
# 3 frames de começo pra pegar o angulo certo
# 15 frames de dash
# 6 frames de hitbox depois
var initFrames:float = 3.0
var dashFrames:float = 15.0
var hitSeconds:float = 0.0

var fuckingAngle:Vector2 = Vector2.ZERO

var leftFloor:bool = false

# step 1: começo
# step 2: dash
var dashStep:int = 1

func enter_state():
	leftFloor = not Player.is_on_floor()
	dashStep = 1
	initFrames = 3.0
	dashFrames = 15.0
	hitSeconds = ((dashFrames + 6.0)/60) * Player.deltaOne
	Player.jumping = false
	Player.plySprite.play("chargedash")
	print("Hi dash")

func update():
	# Player.handlePhys()
	Player.handleCamera()
	handleStep(dashStep)

func handleStep(dashstep:int):
	match dashstep:
		1:
			if initFrames > 0:
				initFrames -= Player.deltaOne
			
			fuckingAngle = Input.get_vector("ctrl_left", "ctrl_right", "ctrl_up", "ctrl_down")
			
			if initFrames <= 0:
				if fuckingAngle == Vector2.ZERO:
					Player.plySprite.play("jump")
					Player.change_state(Player.state_machine.st_air)
					return
				Player.dashTriggered = true
				Player.plySprite.play("dash")
				Player.plySprite.flip_h = fuckingAngle.x < 0
				Player.velToVector(Player.dashSpeed, fuckingAngle)
				Player.make_hitbox_timed(hitSeconds,
					Vector2(1.0, 2.0), 
					Vector2(4.14, 6.25), 
					Player.ATTACK_DMG_LVL["dash"],
					500.0,
					rad_to_deg(fuckingAngle.angle()),
					"dashbox"
					)
				Player.makeAfterimage()
				Player.play_sfx('Thok', 10)
				dashStep = 2
		2:
			if dashFrames > 0:
				dashFrames -= Player.deltaOne
			
			if not Player.is_on_floor():
				leftFloor = true
			
			if dashFrames <= 0 \
			or fuckingAngle == Vector2.ZERO:
				Player.plySprite.play("jump")
				Player.change_state(Player.state_machine.st_air)
				
			if Player.is_on_floor() and leftFloor:
				Player.change_state(Player.state_machine.st_air)
				Player.dashCooldown = 0.0 #wavedavid
		_:
			pass

# Normal straight dashes set Madeline's speed to 240 pixels per second, 
# and normal diagonal dashes set it to around 170. If Madeline has a 
# faster speed, it will be kept, but if the dash is horizontal or 
# up-diagonal, at the end of the dash the horizontal speed is 
# set to 160 and quickly lowers due to friction. For vertical dashes, 
# the vertical speed is set to 120. In the case of a down-diagonal 
# dash, the speed is retained.

# The dash lasts for 15 frames (including 3 freeze frames). 
# The period of 6 frames after the dash is known as Dash Attack, 
# since Madeline can interact with entities during it as if she 
# is still in the dash state. However, this can be avoided by 
# jumping or grabbing the block. You cannot begin another dash 
# until it has ended (for 15 frames), even if the dash was canceled 
# by entering another state (such as bouncing off a spring). 

# Eu peguei isso da wiki de celeste btw
