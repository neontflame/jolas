extends Area2D

var playerIsWatering:bool = false
var lePlayer:PlayerObject

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerObject:
		lePlayer = body
		playerIsWatering = true

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerObject:
		playerIsWatering = false
		lePlayer = null

func _physics_process(delta: float) -> void:
	if playerIsWatering:
		$TheWaterStep.global_position = lePlayer.global_position + Vector2(
			0,
			lePlayer.player_collisions.shape.get_rect().size.y / 3
		)
		$TheWaterStep.z_index = lePlayer.z_index + 1
		$TheWaterStep.visible = lePlayer.is_on_floor()
		if lePlayer.is_on_floor():
			$TheWaterStep/CPUParticles2D.emitting = abs(lePlayer.motion.x) > 50
			if abs(lePlayer.motion.x) > 50:
				if not $TheWaterStep/AudioStreamPlayer2D.playing:
					$TheWaterStep/AudioStreamPlayer2D.play()
				var thePitcher = clampf(abs(lePlayer.motion.x / lePlayer.SOFT_MAX_SPEED), 0.5, 1.5)
				$TheWaterStep/AudioStreamPlayer2D.pitch_scale = thePitcher + randf_range(-0.1, 0.2)
				$TheWaterStep/AudioStreamPlayer2D.volume_linear = clampf(thePitcher, 0.25, 1)
				$TheWaterStep/CPUParticles2D.amount = remap(thePitcher, 0.5, 1.5, 2, 8)
	else:
		$TheWaterStep.visible = false
