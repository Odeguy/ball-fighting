extends Ball

var burst: int
@export var burst_limit: int

func _ready() -> void:
	super()
	reset_burst_meter()
	$RigidBody2D/BurstGlow.process_material.set_emission_sphere_radius(float(radius))
	
func damage_effect(num: int) -> void:
	super(num)
	increase_burst_meter(num * 100)

func increase_burst_meter(num: int) -> void:
	if burst == burst_limit: return
	burst += num
	if burst > burst_limit: burst = burst_limit
	$AvgDmg/BurstMeter.scale.x = float(burst) / burst_limit
	if burst == burst_limit: burst_ready()

func reset_burst_meter() -> void:
	burst = 0
	$AvgDmg/BurstMeter.scale.x = 0
	$RigidBody2D/BurstGlow.hide()

func burst_ready() -> void:
	$RigidBody2D/BurstGlow.show()
	
