# Godot MLP Models: Frame time graph display control
#
# Copyright © 2017-2021 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends Panel

# Stores positions for drawing the frame time graph
var points = PackedVector2Array()

# Stores dynamically-adjusted colors for drawing the frame time graph
var colors = PackedColorArray()

# The number of frames drawn since the application started
var frames_drawn = 0

# The X position to draw the current frame's bar on the graph
var frame_position = 0

# The color of the current frame
var frame_color = Color(0.0, 1.0, 0.0)

# The current frame's timestamp in milliseconds
var now = 0

# The timestamp in milliseconds of the "previous" frame
var previous = 0

# Time between the current and previous frame in milliseconds
var frame_time = 0

# The color gradient used for coloring the frame time bars
var gradient = Gradient.new()

func _ready() -> void:
	# Green-yellow-red gradient
	gradient.set_color(0, Color(0.0, 1.0, 0.0))
	gradient.add_point(0.5, Color(1.0, 1.0, 0.0))
	gradient.set_color(1, Color(1.0, 0.0, 0.0))

	# Pre-allocate the `points` and `colors` arrays
	# This makes it possible to use `PoolVector2Array.set()` directly on them
	points.resize(rect_size.x + 1)
	colors.resize(rect_size.x + 1)

func _process(delta: float) -> void:
	frames_drawn = Engine.get_frames_drawn()
	now = Time.get_ticks_usec()
	frame_time = (now - previous) * 0.001

	# Color the previous frame bar depending on the frame time
	colors.set(frame_position, frame_color)
	colors.set(frame_position + 1, frame_color)

	frame_position = wrapi(frames_drawn*2, 0, int(rect_size.x))
	frame_color = gradient.interpolate(min(frame_time/50.0, 1.0))

	# Every frame is represented as a bar that is ms × 5 pixels high
	# Every line is a pair of two points, so every frame has two points defined
	points.set(
		frame_position,
		Vector2(frame_position, int(rect_size.y))
	)
	points.set(
		frame_position + 1,
		Vector2(frame_position + 1, int(rect_size.y) - frame_time*6)
	)

	# Color the current frame in white
	colors.set(frame_position, Color(1.0, 1.0, 1.0, 1.0))
	colors.set(frame_position + 1, Color(1.0, 1.0, 1.0, 1.0))

	previous = Time.get_ticks_usec()

	update()


func _draw() -> void:
	draw_multiline_colors(points, colors)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_frame_time_graph"):
		visible = !visible


func _on_resized() -> void:
	# Resize the arrays when resizing the control to avoid setting
	# nonexistent indices once the window has been resized
	points.resize(rect_size.x + 1)
	colors.resize(rect_size.x + 1)
