extends BossStatePattern

func enter_state():
	Boss.collisions.disabled = true

func exit_state():
	Boss.collisions.disabled = false
