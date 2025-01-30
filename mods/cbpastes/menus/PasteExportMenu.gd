extends "res://menus/BaseMenu.gd"

const Parser = preload("res://mods/cbpastes/scripts/PasteParser.gd")

onready var export_type = find_node("ExportTypeInput")
onready var formatting = find_node("FormattingInput")
onready var include_attributes = find_node("IncludeAttributesInput")
onready var include_nicknames = find_node("IncludeNicknamesInput")
onready var include_grade = find_node("IncludeGradeInput")
onready var skip_empty = find_node("SkipEmptyInput")

onready var input_container = find_node("InputContainer")
onready var progress_label = find_node("ProgressLabel")
onready var hint_label = find_node("HintLabel")

var running: bool = false
var characters:Array

func _ready():
	for control in input_container.get_children():
		control.connect("focus_entered", self, "_on_input_focus_entered", [control])
		control.connect("focus_exited", self, "_on_input_focus_exited", [control])

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
	if running:
		return
	running = true
	progress_label.text = ""
	progress_label.self_modulate = Color.white
	
	var args:Dictionary = {}
	args.export_party = export_type.selected_value
	args.format = formatting.selected_value
	args.include_attributes = include_attributes.selected_value
	args.include_nickname = include_nicknames.selected_value
	args.include_grade = include_grade.selected_value
	args.skip_empty = skip_empty.selected_value

	var tapes:Array = []
	if args.export_party:
		assert (characters.size() > 0)
		tapes = characters[0].tapes.duplicate()
		#tapes = SaveState.party.player.tapes.duplicate()
		# puts current partner tape as second in the list
		if characters.size() > 1:
			tapes.insert(1, characters[1].tapes[0])
		#tapes.insert(1, SaveState.party.partner.tapes[0])
	else:
		tapes = SaveState.tape_collection.tapes_by_name.duplicate()
		var sorter = Sorter.new()
		sorter.include_grades = args.include_grade
		sorter.include_nicknames = args.include_nickname
		tapes.sort_custom(sorter, "_cmp_sort_tapes")
	
	var paste_array:Array = []
	
	
	var i = 0
	for tape in tapes:
		paste_array.push_back(Parser.export_paste(tape, args))
		i += 1
		if i % 10 == 0:
			yield (Co.wait_frames(1), "completed")
			progress_label.text = Loc.tr("CBPASTE_EXPORT_PROGRESS_EXPORTING") + " %s / %s" % [i, tapes.size()]

	var path:String = "user://pastes/" + generate_file_name(args)

	match args.format:
		"html":
			Parser.export_to_html(paste_array, path)
			progress_label.text = "CBPASTE_EXPORT_PROGRESS_DONE"
			OS.shell_open(ProjectSettings.globalize_path(path))
		"markdown":
			if args.export_party:
				var md_output = Parser._format_markdown(paste_array)
				progress_label.text = "CBPASTE_EXPORT_CLIPBOARD"
				OS.set_clipboard(md_output)
			else:
				Parser.export_to_markdown(paste_array, path)
				progress_label.text = "CBPASTE_EXPORT_PROGRESS_DONE"
				OS.shell_open(ProjectSettings.globalize_path(path))
		_:
			if args.export_party:
				var text_output = "\n\n".join(paste_array)
				progress_label.text = "CBPASTE_EXPORT_CLIPBOARD"
				OS.set_clipboard(text_output)
			else:
				Parser.export_to_text(paste_array, path)
				progress_label.text = "CBPASTE_EXPORT_PROGRESS_DONE"
				OS.shell_open(ProjectSettings.globalize_path(path))
	running = false
	$AudioStreamPlayer.play()
	var tween = $Tween
	tween.stop(tween)
	
	var duration:float = 1.0
	if not args.get("export_party", true):
		duration = 10.0
	
	tween.interpolate_property(progress_label, "self_modulate", Color.white, Color.transparent, duration, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()


func generate_file_name(args:Dictionary, file_name:String = "") -> String:
	file_name += SaveSystem.save_path.get_file().get_basename()
	
	if args.get("export_party", false):
		file_name += "_party"
	else:
		file_name += "_storage"
	file_name += "_%s" % get_time()
	
	match args.get("format", ""):
		"markdown":
			file_name += ".md"
		"html":
			file_name += ".html"
		"bbcode":
			file_name += "_bbcode.txt"
		_:
			file_name += ".txt"
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


class Sorter:
	var include_nicknames:bool
	var include_grades:bool

	func _cmp_sort_tapes(a:MonsterTape, b:MonsterTape) -> bool:
		if a.form != b.form:
			return tr(a.form.name) < tr(b.form.name)
		if include_nicknames:
			return tr(a.get_name()) < tr(b.get_name())	
		if a.type_override.size() != b.type_override.size():
			return a.type_override.size() < b.type_override.size()
		if a.type_override.size() > 0 and b.type_override.size() > 0:
			return a.type_override[0].id < b.type_override[0].id
		if include_grades:
			return a.grade < b.grade
		return tr(a.get_name()) < tr(b.get_name())
