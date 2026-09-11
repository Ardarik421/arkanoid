extends Node2D

var age: float = 0.0
var lifetime: float = 0.48
var particles: Array[Dictionary] = []
var flash_color: Color = Color(0.35, 0.78, 1.0)
var flash_radius: float = 14.0
var burst_variant: int = 0

func setup(effect_color: Color):
	flash_color = effect_color
	burst_variant = randi_range(0, 2)

	for i in range(9):
		var direction = _get_direction(i, burst_variant).normalized()
		particles.append({
			"offset": Vector2(randf_range(-7.0, 7.0), randf_range(-4.0, 4.0)),
			"velocity": direction * _get_speed(burst_variant),
			"size": randf_range(2.2, 5.0),
			"rotation": randf_range(0.0, TAU),
			"spin": randf_range(-8.0, 8.0)
		})

	queue_redraw()

func _get_direction(index: int, variant: int) -> Vector2:
	match variant:
		0:
			var directions = [
				Vector2(-1.0, -0.45), Vector2(-0.72, 0.15), Vector2(-0.45, 0.72),
				Vector2(0.0, -0.9), Vector2(0.28, 0.78), Vector2(0.62, -0.55),
				Vector2(0.88, 0.18), Vector2(1.0, 0.62), Vector2(-0.95, 0.58)
			]
			return directions[index]

		1:
			var x_values = [-1.0, -0.78, -0.55, -0.28, 0.0, 0.28, 0.55, 0.78, 1.0]
			var x = float(x_values[index])
			return Vector2(x, randf_range(-1.25, -0.55))

		2:
			var side = -1.0 if index < 4 else 1.0
			if index == 4:
				return Vector2(randf_range(-0.18, 0.18), -1.0)
			var spread_index = index if index < 4 else index - 5
			var y_values = [-0.82, -0.28, 0.22, 0.72]
			return Vector2(side * randf_range(0.82, 1.18), float(y_values[spread_index]))

	return Vector2.UP

func _get_speed(variant: int) -> float:
	match variant:
		0:
			return randf_range(75.0, 165.0)
		1:
			return randf_range(95.0, 180.0)
		2:
			return randf_range(90.0, 175.0)
	return 120.0

func _process(delta):
	age += delta

	for particle in particles:
		var velocity: Vector2 = particle["velocity"]
		var offset: Vector2 = particle["offset"]
		var rotation: float = particle["rotation"]
		velocity.y += 145.0 * delta
		offset += velocity * delta
		rotation += float(particle["spin"]) * delta
		particle["velocity"] = velocity
		particle["offset"] = offset
		particle["rotation"] = rotation

	if age >= lifetime:
		queue_free()
		return

	queue_redraw()

func _draw():
	var t = clamp(age / lifetime, 0.0, 1.0)
	var fade = 1.0 - t
	var flash_fade = max(0.0, 1.0 - t * 4.0)

	if flash_fade > 0.0:
		for i in range(4):
			var radius = flash_radius + float(i) * 8.0 + age * 90.0
			draw_circle(Vector2.ZERO, radius, Color(flash_color, flash_fade * (0.12 - float(i) * 0.02)))
		draw_circle(Vector2.ZERO, 8.0 + age * 38.0, Color(1.0, 0.95, 0.82, flash_fade * 0.72))

	for i in range(particles.size()):
		var particle = particles[i]
		var offset: Vector2 = particle["offset"]
		var size: float = particle["size"] * (0.65 + fade * 0.35)
		var rotation: float = particle["rotation"]
		var axis = Vector2(cos(rotation), sin(rotation))
		var normal = Vector2(-axis.y, axis.x)
		var shard = PackedVector2Array([
			offset + axis * size * 1.7,
			offset + normal * size * 0.72,
			offset - axis * size * 1.15,
			offset - normal * size * 0.72
		])
		draw_colored_polygon(shard, Color(flash_color, fade * 0.88))
		draw_polyline(PackedVector2Array([shard[0], shard[1], shard[2], shard[3], shard[0]]), Color(0.82, 0.95, 1.0, fade * 0.75), 0.9, true)

		if i % 2 == 0:
			var velocity: Vector2 = particle["velocity"]
			var trail = offset - velocity.normalized() * (9.0 + size * 2.0)
			draw_line(offset, trail, Color(flash_color, fade * 0.48), 1.2, true)
