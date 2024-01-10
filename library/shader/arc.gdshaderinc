
// Returns 1 if it's within the arc band, 0 otherwise.
float in_arc(vec2 _position, float _inner_radius, float _outer_radius, float _smoothness) {
	float inner = smoothstep(_inner_radius, _inner_radius + _smoothness, length(_position));
	float outer = smoothstep(_outer_radius, _outer_radius - _smoothness, length(_position));
	return inner * outer;
}

// Returns 1 if it's within the angle, 0 otherwise.
// _start_angle & _end_angle is to be given in radians.
float in_angle(vec2 _position, float _start_angle, float _end_angle, float _smoothness) {
	_start_angle *= PI;
	_end_angle *= PI;
	
	float angle = atan(_position.y, _position.x) + PI;
	float start_edge = smoothstep(angle, angle - _smoothness, _start_angle);
	float end_edge = smoothstep(angle, angle + _smoothness, _end_angle);
	return start_edge * end_edge;
}
