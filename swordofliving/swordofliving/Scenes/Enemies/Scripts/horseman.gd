extends Monster




func handle_death():
	current_anim = AnimationState.DEATH
	await get_tree().create_timer(death_time).timeout
	queue_free()
	
func _on_attack_listener_play_entered(_bool: Variant) -> void:
	pass
		
func _on_attack_listener_play_exited(_bool: Variant) -> void:
	pass
	
func specific_interaction():
	pass
		
