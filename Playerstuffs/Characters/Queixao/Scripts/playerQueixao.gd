extends PlayerObject

func fazerACoisa():
	plySprite.play('espada')
	if hitbox_exists('fodaespada'):
		delete_hitboxes('fodaespada')
		delete_hitboxes('fodape')
		delete_hitboxes('fodachifre1')
		delete_hitboxes('fodachifre2')
	# disjoint gigante
	make_hitbox(	Vector2(473.0, 25.0),
						Vector2(44.57, 4.36),
						ATTACK_DMG_LVL['default'],
						2500, 180, 'fodaespada')
	
	make_hitbox(	Vector2(-83.0, 56.0),
						Vector2(1.0, 1.0),
						ATTACK_DMG_LVL['default'],
						2500, 315, 'fodape')
						
	make_hitbox(	Vector2(51.0, -101.0),
						Vector2(0.365, 5.56),
						ATTACK_DMG_LVL['default'],
						2500, 180, 'fodachifre1')
	
	make_hitbox(	Vector2(12.0, -101.0),
						Vector2(0.365, 5.56),
						ATTACK_DMG_LVL['default'],
						2500, 180, 'fodachifre2')
