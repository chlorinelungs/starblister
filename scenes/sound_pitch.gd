extends AudioStreamPlayer2D


func play(from_position=0.0):

	pitch_scale = rand_range(0.8,0.12)
	.play(from_position)
