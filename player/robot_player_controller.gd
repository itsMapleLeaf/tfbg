extends Node2D
class_name RobotPlayerController

@onready var player := get_parent() as Player
@onready var fov := $FOV as Area2D

func _ready():
	call_deferred("_run_random_loop", 0.5, 3, player.jump)
	call_deferred("_run_movement_loop")
	call_deferred("_run_decision_loop")

func _run_movement_loop():
	while true:
		# danger scenario: we're falling towards a player with a block and have no extra jumps to dodge it
		_avoid_falling_towards_grabbing_player_without_jumps()

		if player.global_position.x < -13 * 50 and player.movement < 0:
			player.set_movement(1)
		if player.global_position.x > 13 * 50 and player.movement > 0:
			player.set_movement(-1)
			
		await _random_timer(0.1, 0.3).timeout
		
func _run_decision_loop():
	while true:
		player.set_movement([1, -1].pick_random())
		
		while not player.grabbing:
			await _random_timer(0.1, 0.5).timeout
			player.grab()
		
		player.set_movement(_get_direction_of_random_player_in_fov())
		if randi() % 2 == 1:
			player.set_movement(0)
		
		await _random_timer(0.2, 0.7).timeout
		player.jump()
		
		if player.grabbing:
			await _random_timer(0.2, 0.7).timeout
			player.release()

func _run_random_loop(min_period: float, max_period: float, fn: Callable):
	while true:
		await _random_timer(min_period, max_period).timeout
		fn.call()

func _temp_timer(wait_time: float) -> Timer:
	var timer := Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.timeout.connect(func(): timer.queue_free())
	add_child(timer)
	timer.start()
	return timer

func _random_timer(min_period: float, max_period: float) -> Timer:
	return _temp_timer(randf_range(min_period, max_period))

func _on_incoming_flying_block_area_entered(node: Area2D):
	if not node is FlyingBlock: return

	var is_incoming = node.direction == signf(player.global_position.x - node.global_position.x)
	if not is_incoming: return

	await _temp_timer(0.1).timeout
	player.jump()

func _get_players_in_fov() -> Array[Node2D]:
	return fov.get_overlapping_bodies().filter(_is_alive_player)

func _get_direction_of_random_player_in_fov():
	var players := _get_players_in_fov()
	if players.is_empty(): return [-1, 1].pick_random()
	
	var other_player: Player = players.pick_random()
	var direction := signf(other_player.global_position.x - player.global_position.x)
	if direction == 0: return [-1, 1].pick_random()
	return direction

func _is_alive_player(node: Node2D) -> bool:
	return node is Player and node != player and node.is_alive

func _avoid_falling_towards_grabbing_player_without_jumps():
	if player.jumps > 0: return
	
	var others := _get_players_in_fov()
	if others.is_empty(): return
	
	var closest: Player = others.reduce(_get_closest_to_self)
	if closest.global_position.distance_to(player.global_position) > 400: return
	
	player.set_movement(player.global_position.x - closest.global_position.x)

func _get_closest_to_self(a: Node2D, b: Node2D) -> Node2D:
	var a_distance := a.global_position.direction_to(player.global_position)
	var b_distance := b.global_position.direction_to(player.global_position)
	if a_distance < b_distance: return a
	return b
