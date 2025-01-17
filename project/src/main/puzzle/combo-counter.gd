class_name ComboCounter
extends Node2D
## A combo indicator which appears when the player clears a line in puzzle mode.
##
## The indicator includes some colorful stylized text with an accent shape behind it.

## When the combo exceeds these values, the indicator changes its appearance
const COMBO_THRESHOLD_0 := 5
const COMBO_THRESHOLD_1 := 10
const COMBO_THRESHOLD_2 := 20
const COMBO_THRESHOLD_3 := 30
const COMBO_THRESHOLD_4 := 50

export (Vector2) var velocity: Vector2

## The combo to display. This controls our text, color and particle properties.
var combo: int setget set_combo

## Colors to use; these are automatically assigned based on the combo value
var _font_color: Color
var _accent_color: Color # darker version of the font color
var _particle_color: Color # lighter version of the font color

## particles which explode from the center of the combo
onready var _particles: Particles2D = $Particles2D
onready var _particles_material: ParticlesMaterial = $Particles2D.process_material

## text showing the current combo, like '12x'
onready var _label: Label = $Label

## colorful shape which goes behind the text
onready var _accent: PackedSprite = $Accent

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	_particles.emitting = true
	_refresh_combo()


func _physics_process(delta: float) -> void:
	position += velocity * delta


func set_combo(new_combo: int) -> void:
	combo = new_combo
	_refresh_combo()


func _refresh_combo() -> void:
	if not is_inside_tree():
		return

	_calculate_colors()
	_refresh_label()
	_refresh_accent()
	_refresh_particles()


func _calculate_colors() -> void:
	var outline_darkness := 0.2
	_font_color = Color("4eff49")
	if combo < COMBO_THRESHOLD_0:
		_font_color.h = 0.5889 # blue
	elif combo < COMBO_THRESHOLD_1:
		_font_color.h = 0.4667 # cyan
	elif combo <= COMBO_THRESHOLD_2:
		_font_color.h = 0.2861 # green
	elif combo <= COMBO_THRESHOLD_3:
		_font_color.h = 0.1250 # yellow
	elif combo <= COMBO_THRESHOLD_4:
		_font_color.h = 0.1250 # bright yellow
		_font_color.s = 0.4444
		outline_darkness = 0.16
	else:
		_font_color.h = 0.1250 # near-white
		_font_color.s = 0.0600
		outline_darkness = 0.12
	_accent_color = _font_color
	_accent_color.s += outline_darkness
	_accent_color.v -= outline_darkness * 2
	_particle_color = _font_color
	_particle_color.s -= 0.3


func _refresh_label() -> void:
	_label.set("custom_colors/font_color", _font_color)
	var font: DynamicFont = _label.get("custom_fonts/font")
	font.outline_color = _accent_color
	if combo < COMBO_THRESHOLD_0:
		font.size = 20
	elif combo < COMBO_THRESHOLD_1:
		font.size = 22
	elif combo <= COMBO_THRESHOLD_2:
		font.size = 24
	elif combo <= COMBO_THRESHOLD_3:
		font.size = 26
	elif combo <= COMBO_THRESHOLD_4:
		font.size = 28
	else:
		font.size = 30
	if combo > 99:
		_label.text = "?!"
	else:
		_label.text = "%s×" % combo


func _refresh_accent() -> void:
	if combo < COMBO_THRESHOLD_1:
		_accent.frame = 0
	elif combo <= COMBO_THRESHOLD_2:
		_accent.frame = 4
	elif combo <= COMBO_THRESHOLD_4:
		_accent.frame = 8
	else:
		_accent.frame = 12
	_accent.frame += randi() % 4 # randomly select between four different similar accents
	_accent.modulate = _accent_color


func _refresh_particles() -> void:
	_particles_material.scale = 5
	if combo < COMBO_THRESHOLD_0:
		_particles.amount = 6
		_particles_material.initial_velocity = 200
	elif combo < COMBO_THRESHOLD_1:
		_particles.amount = 8
		_particles_material.initial_velocity = 280
	elif combo <= COMBO_THRESHOLD_2:
		_particles.amount = 10
		_particles_material.initial_velocity = 400
	elif combo <= COMBO_THRESHOLD_3:
		_particles.amount = 12
		_particles_material.initial_velocity = 600
	elif combo <= COMBO_THRESHOLD_4:
		_particles.amount = 12
		_particles_material.initial_velocity = 800
	else:
		_particles.amount = 12
		_particles_material.scale = 6
		_particles_material.initial_velocity = 1200
	_particles_material.color_ramp.gradient.colors[0] = _font_color
	_particles_material.color_ramp.gradient.colors[1] = Utils.to_transparent(_font_color)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if not Engine.is_editor_hint():
		queue_free()
