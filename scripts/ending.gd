extends Panel

func _ready():
	get_node("score").text = "Your score is %02d, well done" % [global.score]
