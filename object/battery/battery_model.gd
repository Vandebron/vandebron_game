extends Model
class_name BatteryModel

@export var charge_percentage: float:
	set(value):
		charge_percentage = value
		(%Gauge.get_active_material(0) as ShaderMaterial)\
			.set_shader_parameter("charge_percentage", charge_percentage)
