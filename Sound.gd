extends Node

var rng = RandomNumberGenerator.new()
var soundTimer = 0.0
var node_path = NodePath("position:x")
var backgroundRadiation = false
var soundTimerMaxValue = 20.0

@onready var geigerSound = get_node("../Geiger")
@onready var soundTimerLabel = get_node("../CanvasLayer/Control/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/SoundTimerLabel")
@onready var radLevelSlider = get_node("../CanvasLayer/Control/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RadLevel")
@onready var radLevelColor = get_node("../CanvasLayer/Control/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/RadLevelColor")
@onready var backGroundRadiationCheckbox = get_node("../CanvasLayer/Control/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/BackgroundRadiation")

func setSoundTimer():
	soundTimer = rng.randf_range(0.0, soundTimerMaxValue)

func setRadLevelColor():
	var red = Color(1.0, 0.0, 0.0)
	var green = Color(0, 1.0, 0.0)
	var yellow = Color(1.0, 1.0, 0.0)
	if soundTimerMaxValue < (radLevelSlider.max_value * 0.011):
		radLevelColor.color = red
	elif soundTimerMaxValue < (radLevelSlider.max_value * 0.13):
		radLevelColor.color = yellow
	else:
		radLevelColor.color = green


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	setRadLevelColor()
	setSoundTimer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if backgroundRadiation:
		soundTimerLabel.text = str(snappedf(soundTimer,0.01))
		if soundTimer <= 0:
			geigerSound.play()
			setRadLevelColor()
			setSoundTimer()
		soundTimer = soundTimer - delta
	if Input.is_action_pressed("ui_select") and not geigerSound.playing:
		geigerSound.play()

func _on_button_pressed():
	geigerSound.play()

func _on_background_radiation_toggled(button_pressed):
	backgroundRadiation = button_pressed
	if backgroundRadiation:
		soundTimerMaxValue = radLevelSlider.max_value
		radLevelSlider.value = 0.1
		setRadLevelColor()
		setSoundTimer()

func _on_rad_level_value_changed(value):
	if value == 0.0:
		backGroundRadiationCheckbox.set_pressed_no_signal(false)
		backgroundRadiation = false
	else:
		backGroundRadiationCheckbox.set_pressed_no_signal(true)
		backgroundRadiation = true
		soundTimerMaxValue = radLevelSlider.max_value - (tanh(value/6) * radLevelSlider.max_value)
		setRadLevelColor()
		setSoundTimer()
