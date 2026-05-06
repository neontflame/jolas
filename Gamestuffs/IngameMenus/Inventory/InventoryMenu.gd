extends "res://Menustuffs/Submenu.gd"

@export var anim:AnimationPlayer

var viewingItem:bool = false
var exiting:bool = false

func _ready() -> void:
	CoolMenu.curSelected = 0
	CoolMenu.play_sfx('Unwrap')
	anim.play('getIn')

func _process(delta: float) -> void:
	if not exiting:
		$MenuCanvas/Control/InventoryThing.active = not viewingItem
		if Input.is_action_just_pressed("ui_accept"):
			if not viewingItem:
				if len(InventoryUtils.inventory) > CoolMenu.curSelected:
					CoolMenu.play_sfx('Go')
					viewingItem = true
					$MenuCanvas/Control/ItemDesc.renderItem(CoolMenu.curSelected)
					anim.play('showAbout')
		if Input.is_action_just_pressed("ui_cancel"):
			if viewingItem:
				CoolMenu.play_sfx('Back')
				viewingItem = false
				anim.play('hideAbout')
			else:
				exiting = true
				JolasGame.instance.unpauseGame()
				CoolMenu.play_sfx('Wrap')
				$AnimationPlayer.play('getOut')
				await get_tree().create_timer(0.5).timeout
				CoolMenu.instance.unmakeMenu()
