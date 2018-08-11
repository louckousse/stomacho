extends KinematicBody2D

# Member variables
const MOTION_SPEED = 160 # Pixels/second
var score = 0
var speed = 1

var timer
var time_now
var time_start

const STOMACH_CAPACITY = 1000
var stomach_filling = 0.0 #TODO passer à 0
var puke_coeff = 2

# Fast food variables
const REFILL_TIMEOUT = 30

var tramway_timeout = 30
var macdalle_timeout = 30
var captainchiken_timeout = 30
var magicbeaugosse_timeout = 30
var langlebediewurst_timeout = 30
var ofatos_timeout = 30

var tramway_feed = 10
var macdalle_feed = 20
var captainchicken_feed = 30
var magicbeaugosse_feed = 40
var langlebediewurst_feed = 50
var ofatos_feed = 100


func _ready():
	timer = Timer.new()
	timer.wait_time = 1
	timer.connect("timeout",self,"_on_timer_timeout") 
	#timeout is what says in docs, in signals
	#self is who respond to the callback
	#_on_timer_timeout is the callback, can have any name
	add_child(timer) #to process
	timer.start() #to start
	time_start = OS.get_unix_time()
    
func _on_timer_timeout():
	increment_timeout()
	has_puke()
	display_time()
	stomach_filling -= speed

func _physics_process(delta):
	var motion = Vector2()
	
	handle_anim()
	
	if Input.is_action_pressed("move_up"):
		motion += Vector2(0, -1)
	elif Input.is_action_pressed("move_bottom"):
		motion += Vector2(0, 1)
	elif Input.is_action_pressed("move_left"):
		motion += Vector2(-1, 0)
	elif Input.is_action_pressed("move_right"):
		motion += Vector2(1, 0)
	else:
		get_node("Sprite/AnimationPlayer").stop()
	
	motion = motion.normalized() * MOTION_SPEED * speed
	move_and_slide(motion)

func change_way(dir):
	var way = ""
	if dir == "move_right": way = "walk_right"
	if dir == "move_left": way = "walk_left"
	if dir == "move_up": way = "walk_up"
	if dir == "move_bottom": way = "walk_bottom"
	get_node("Sprite/AnimationPlayer").play(way)

func handle_anim():
	if Input.is_action_just_pressed("move_up"):
		if speed == 0: speed = 1
		change_way("move_up")
		get_node("Sprite").set_flip_h(false)
	if Input.is_action_just_pressed("move_bottom"):	
		if speed == 0: speed = 1
		change_way("move_bottom")
		get_node("Sprite").set_flip_h(false)
	if Input.is_action_just_pressed("move_left"):
		if speed == 0: speed = 1
		change_way("move_left")
		get_node("Sprite").set_flip_h(false)
	if Input.is_action_just_pressed("move_right"):
		if speed == 0: speed = 1
		change_way("move_right")
		get_node("Sprite").set_flip_h(true)
	if Input.is_action_just_pressed("run"):
		speed = 1.5
		puke_coeff = 1
	if Input.is_action_just_released("run"):
		speed = 1
		puke_coeff = 2

func display_time():
	time_now = OS.get_unix_time()
	var remaining = 300 - (time_now - time_start)
	var minutes = remaining / 60
	var seconds = remaining % 60
	var str_remaining = "%02d : %02d\n %2d\n %2d" % [minutes, seconds, stomach_filling, score]
	get_node("../Information/Container/timeleft/time").text = str_remaining
	
func feed(quantity, timeout):
	if stomach_filling + quantity > STOMACH_CAPACITY:
		get_node("Sprite/AnimationPlayer").stop()
		get_node("Sprite").frame = 10
	elif timeout >= REFILL_TIMEOUT:
		stomach_filling += quantity
		score += quantity
		return true
	return false

func has_puke():
	if rand_range(0,20) < puke_probability():
		get_node("Sprite/AnimationPlayer").stop()
		get_node("Sprite").frame = 9
		speed = 0
		score = score - 200 if score > 200 else 0
		stomach_filling = stomach_filling - 200 if stomach_filling > 200 else 0
	
func puke_probability():
	if stomach_filling > 200:
		return (((stomach_filling*stomach_filling) / puke_coeff) / STOMACH_CAPACITY) / STOMACH_CAPACITY
	return 0

func increment_timeout():
	tramway_timeout += 1
	macdalle_timeout += 1
	captainchiken_timeout += 1
	magicbeaugosse_timeout += 1
	langlebediewurst_timeout += 1
	ofatos_timeout += 1

func _on_TramWay_entered(body):
	if body.get_name() == "lucas":
		if feed(tramway_feed, tramway_timeout):
			tramway_timeout = 0
		display_time()


func _on_MacDalle_entered(body):
	if body.get_name() == "lucas":
		if feed(macdalle_feed, macdalle_timeout):
			macdalle_timeout = 0
		display_time()


func _on_CaptainChicken_entered(body):
	if body.get_name() == "lucas":
		if feed(captainchicken_feed, captainchiken_timeout):
			captainchiken_timeout = 0
		display_time()


func _on_MagicBeauGosse_entered(body):
	if body.get_name() == "lucas":
		if feed(magicbeaugosse_feed, magicbeaugosse_timeout):
			magicbeaugosse_timeout = 0
		display_time()


func _on_LangLebeDieWurst_entered(body):
	if body.get_name() == "lucas":
		if feed(langlebediewurst_feed, langlebediewurst_timeout):
			langlebediewurst_timeout = 0
		display_time()


func _on_OFatos_entered(body):
	if body.get_name() == "lucas":
		if feed(ofatos_feed, ofatos_timeout):
			ofatos_feed = 0
		display_time()
