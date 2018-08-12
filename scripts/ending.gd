extends Panel

func _ready():
	print("It really is")
	get_node("score").text = "Your score is %02d, well done" % [global.score]
