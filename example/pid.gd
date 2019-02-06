extends Node2D

const PIDController = preload("res://bin/pid_controller.gdns")
const PDController = preload("res://bin/pd_controller.gdns")

var x_controller: PIDController = PIDController.new()
var y_controller: PDController = PDController.new()
var child_velocity: Vector2 = Vector2(0, 0)

func _ready():
	x_controller.k_p = 0.5
	x_controller.k_d = 0.25
	y_controller.k_p = 0.4
	y_controller.k_d = 0.05
	
	set_process(true)

func _process(dt):
	var child_pos = $Child.global_position
	var mouse_pos = get_global_mouse_position()
	
	var velocity_change_x = x_controller.get_output(mouse_pos.x - child_pos.x, dt) * dt
	var velocity_change_y = y_controller.get_output(mouse_pos.y - child_pos.y, dt) * dt
	child_velocity += Vector2(velocity_change_x, velocity_change_y)
	$Child.global_position += child_velocity
