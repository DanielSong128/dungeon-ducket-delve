extends KinematicBody2D

export var walk_speed = 4
const TILE_SIZE = 8

var initial_position = Vector2(0,0)
var input_direction = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0
var coins_collected = 0
var chests = []

onready var anim_player = $AnimationPlayer
onready var ray = $RayCast2D

signal bumped_chest(id,dir)
signal moved()


func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()

	chests = tree.get_nodes_in_group("Chest")
	print(chests)
	
	for x in chests:
		print(x.connect("coin_awarded", self, "increase_coin_collected_count"))
	
	initial_position = position
	

func _physics_process(delta):
	if is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		move(delta)
	else:
		is_moving = false


func process_player_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		
	if input_direction != Vector2.ZERO:
		initial_position = position
		is_moving = true

func move(delta):
	
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	
	ray.cast_to = desired_step
	ray.force_raycast_update()
	if !ray.is_colliding(): # Check for collision before moving
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			anim_player.play("idle")
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			emit_signal("moved")
			
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
			anim_player.play("move")
	else:
		if ray.get_collider().is_in_group("Chest"):
			emit_signal("bumped_chest",ray.get_collider().name, input_direction)
			
		is_moving = false

func increase_coin_collected_count():
	coins_collected += 1
	print(coins_collected)
