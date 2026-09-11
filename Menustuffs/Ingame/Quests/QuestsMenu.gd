extends "res://Menustuffs/Submenu.gd"

@export var questMainThing:Node2D
@export var questDesc:Node2D
@export var anim:AnimationPlayer

var exiting = false

func _ready() -> void:
	CoolMenu.curSelected = 0
	CoolMenu.play_sfx('Unwrap')
	anim.play('getIn')

func _process(delta: float) -> void:
	if not exiting:
		if Input.is_action_just_pressed("ui_accept"):
			if questMainThing.isActive:
				if len(QuestUtils.assignedQuests) > 0:
					questMainThing.isActive = false
					questDesc.renderQuest(QuestUtils.assignedQuests[CoolMenu.curSelected])
					anim.play('showDesc')
					CoolMenu.play_sfx('Go')
				else:
					CoolMenu.play_sfx('Back')
				
		if Input.is_action_just_pressed("ui_cancel"):
			if not questMainThing.isActive:
				anim.play('hideDesc')
				questMainThing.isActive = true
				CoolMenu.play_sfx('Back')
			else:
				exiting = true
				JolasGame.instance.unpauseGame()
				CoolMenu.play_sfx('Wrap')
				$AnimationPlayer.play('getOut')
				await get_tree().create_timer(0.5).timeout
				CoolMenu.instance.unmakeMenu()
