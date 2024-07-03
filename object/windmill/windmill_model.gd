class_name WindmillModel extends Model

@onready var energy_particles: GPUParticles3D = $EnergyParticles


func start_energy_particles() -> void:
	energy_particles.emitting = true


func stop_energy_particles() -> void:
	energy_particles.emitting = false


func set_energy_particles_speed(speed: float) -> void:
	energy_particles.speed_scale = speed
