extends "res://menus/BaseMenu.gd"

const Parser = preload("res://mods/cbpastes/scripts/PasteParser.gd")

onready var formatting = find_node("FormattingInput")
onready var include_attributes = find_node("IncludeAttributesInput")
onready var include_nicknames = find_node("IncludeNicknamesInput")
onready var include_grade = find_node("IncludeGradeInput")
onready var skip_empty = find_node("SkipEmptyInput")

onready var input_container = find_node("InputContainer")
onready var progress_label = find_node("ProgressLabel")
onready var hint_label = find_node("HintLabel")
onready var paste_preview = find_node("PastePreview")


var running: bool = false
var is_snippet:bool = true
var tape:MonsterTape
var current_text:String = ""
var args:Dictionary = {}

func _ready():
	for control in input_container.get_children():
		control.connect("focus_entered", self, "_on_input_focus_entered", [control])
		control.connect("focus_exited", self, "_on_input_focus_exited", [control])
	update_display()

func grab_focus():
	.grab_focus()
	input_container.grab_focus()


func _on_input_focus_entered(control):
	if control.hint_tooltip != "":
		hint_label.text = control.hint_tooltip


func _on_input_focus_exited(control):
	if hint_label.text == control.hint_tooltip:
		hint_label.text = ""


func _on_AcceptButton_pressed():
	progress_label.text = ""
	progress_label.self_modulate = Color.white
	get_paste_text()
	
	if args.standalone:
		var path = generate_html_file_name(tape)
		Parser.export_to_html([current_text], path, true)
		progress_label.text = "CBPASTE_EXPORT_PROGRESS_DONE"
		OS.shell_open(ProjectSettings.globalize_path(path))
	else:	
		OS.set_clipboard(current_text)
		progress_label.text = "CBPASTE_EXPORT_CLIPBOARD"

	$AudioStreamPlayer.play()
	var tween = $Tween
	tween.stop(tween)
	tween.interpolate_property(progress_label, "self_modulate", Color.white, Color.transparent, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()


func generate_html_file_name(tape:MonsterTape, file_name:String = "") -> String:
	if file_name != "":
		return file_name	
	assert (tape != null)
	file_name = "user://pastes/"
	file_name += tape.form.resource_path.get_file().get_basename()
	if tape.type_override.size() > 0:
		file_name += "_%s" % tape.type_override[0].id
	file_name += "_%s.html" % get_time()
	return file_name

func get_time():
	var current_time = Time.get_datetime_dict_from_system()
	var year = str(current_time.year).substr(len(str(current_time.year)) - 2, 2)
	var month = str(current_time.month).pad_zeros(2)
	var day = str(current_time.day).pad_zeros(2)
	var hour = str(current_time.hour).pad_zeros(2)
	var minute = str(current_time.minute).pad_zeros(2)
	var second = str(current_time.second).pad_zeros(2)
	return "%s%s%s_%s%s%s" % [year, month, day, hour, minute, second]


func update_display():
	get_paste_text()
	if paste_preview:
		paste_preview.text = current_text


func get_paste_text():
	if running:
		return
	running = true

	current_text = Parser.export_paste(tape, args)
	if args.get("format", "") == "markdown":
		current_text = Parser._format_markdown([current_text])
	if args.get("format", "") == "html" and args.get("standalone", false):
		current_text = Parser._format_html_body([current_text])
	running = false


func _on_FormattingInput_value_changed(value, index):
	args.format = value
	# checks if it's meant to be a standalone html file
	if value == "html" and index == 3:
		args.standalone = true
	else:
		args.standalone = false
	update_display()


func _on_IncludeNicknamesInput_value_changed(value, index):
	args.include_nickname = value
	update_display()


func _on_IncludeGradeInput_value_changed(value, index):
	args.include_grade = value
	update_display()


func _on_SkipEmptyInput_value_changed(value, index):
	args.skip_empty = value
	update_display()


func _on_IncludeAttributesInput_value_changed(value, index):
	args.include_attributes = value
	update_display()
