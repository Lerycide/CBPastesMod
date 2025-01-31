extends Reference

const DEFAULT_LOCALE = "en"
const EMPTY_STICKER = "<Empty Slot>"

enum EXPORT_FORMAT{PlainText,Markdown,HTML}

const Conversions = preload("res://mods/cbpastes/scripts/StringConversions.gd")

const COLORS = {
	"misc": "#777777",
	"air": "#206454",
	"astral": "#373f67",
	"beast": "#757157",
	"earth": "#6f3945",
	"fire": "#d04d2f",
	"glass": "#9dacc3",
	"glitter": "#c355c1",
	"ice": "#3471b2",
	"lightning": "#d98a30",
	"metal": "#78668a",
	"plant": "#308245",
	"plastic": "#b12031",
	"poison": "#7629db",
	"water": "#4648ce",	
	"typeless": "#000000",
	"common": "#000000",
	"uncommon": "#225d31",
	"rare": "#35379d",
}


const HTML_HEAD = """<!DOCTYPE html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tape Export</title>
<style>
	body {
		font-family: "Verdana", sans-serif;
	}
	table {
		width: auto;
		border-spacing: 0 0;
		margin: 0;
	}
	td {
		padding: 0;
		border: none;
		text-align: left;
	}
	td + td {
		padding-left: 40px;
	}
</style>
</head>
<body>"""

const HTML_FOOT = """
</body>
</html>
"""

const HTML_TAPE_SEPARATOR = "<br>\n"


# extracts info from the MonsterTape resource
# mainly used so _export_paste can be called without this entity
static func export_paste(tape: MonsterTape, args:Dictionary = {}) -> String:
	if not tape:
		return ""
	
	var form:MonsterForm = tape.form
	var type_default:ElementalType
	
	if tape._get_type_native().size() > 0:
		type_default = tape._get_type_native()[0]
	
	var type_override:ElementalType
	if tape.type_override.size() > 0:
		type_override = tape.type_override[0]
	var grade:int = 5
	if args.get("include_grade", true):
		grade = tape.grade

	var nickname:String = ""
	if args.get("include_nickname", true):
		nickname = tape.name_override

	var moves:Array = []
	for sticker in tape.stickers:
		if not sticker:
			moves.push_back(null)
		elif sticker is StickerItem:
			moves.push_back(sticker.get_modified_move())
		else:
			moves.push_back(sticker)
	return _export_paste(form, type_default, type_override, grade, nickname, moves, args)


static func _export_paste(form:MonsterForm, type_default:ElementalType, type_override:ElementalType,
	grade:int = 5, nickname:String = "", moves:Array = [], args:Dictionary = {}) -> String:

	if not form:
		push_error("Invalid monster form")
		return ""

	# sets paste export to be in english
	var locale = TranslationServer.get_locale()
	TranslationServer.set_locale(DEFAULT_LOCALE)
	
	var form_name:String = Strings.strip_diacritics(Loc.tr(form.name))
	var type_name:String = ""
	var output_strings:PoolStringArray = []

	if type_override:
		type_name = Loc.tr(type_override.name)

	output_strings.push_back(assign_header(form_name, type_name, args))

	if nickname != "":
		output_strings.push_back(assign_misc("Nickname", nickname, args))

	if grade < 5:
		output_strings.push_back(assign_misc("Grade", str(int(clamp(grade, 0, 5))), args))

	for move in moves:
		if not move:
			if not args.get("skip_empty", false):
				output_strings.push_back(fancy_format_move(move, null, args))
			continue
		var fallback_type = type_override if type_override else type_default
		output_strings.push_back(fancy_format_move(move, fallback_type, args))

	if args.get("include_attributes", true) and args.get("format", "") == "html":
		output_strings.push_back("<tr style='height: 19px;'><td colspan='2'> </td></tr>")
	elif args.get("format", "") == "html":
		output_strings.push_back("<br>\n")

	TranslationServer.set_locale(locale)
	return "\n".join(output_strings)


# to be used for formatting moves
static func fancy_format_move(move:BattleMove, type:ElementalType, args:Dictionary = {}):
	var output:String = ""

	if not move:
		output = "- " + EMPTY_STICKER	
		match args.get("format", ""):
			"bbcode":
				return output
			"html":
				if args.get("include_attributes", true):
					return "<tr><td>%s</td></tr>" % sanitize_to_html(output)
				return "<div>%s</div>" % sanitize_to_html(output)
			_:
				return output

	output = "- " + Strings.strip_diacritics(Loc.tr(move.name))
	var attributes_text:String = ""

	if args.get("include_attributes", true) and move.attributes.size() > 0:
		attributes_text = fancy_format_attributes(move, args)

	var id:String = "typeless"
	if move.elemental_types.size() > 0:
		id = move.elemental_types[0].id
	elif type:
		id = type.id
	
	if args.get("include_attributes", true):
		match args.get("format", ""):
			"bbcode":
				return "[color=%s]%s[/color]\n    %s" % [COLORS[id], output, attributes_text]
			"markdown":
				return "%s\n\t%s" % [output, attributes_text]
			"html":
				return "<tr><td style='color: %s;'>%s</td><td>%s</td></tr>" % [COLORS[id], output, attributes_text]
			_:
				return "%s %s" % [output, attributes_text]
	else:
		match args.get("format", ""):
			"bbcode":
				return "[color=%s]%s[/color]" % [COLORS[id], output]
			"html":
				return "<div style='color: %s;'>%s</div>" % [COLORS[id], output]
			_:
				pass
	return output


static func fancy_format_attributes(move:BattleMove, args:Dictionary, output := "") -> String:
	if move.attributes.size() == 0:
		return ""
	output = "["
	for attribute in move.attributes:
		var data:Dictionary = create_data_from_attribute(attribute)
		var attr_string:String = string_format_attribute(data)
		match args.get("format", ""):
			"bbcode":
				attr_string = "[color=%s]%s[/color]" % [COLORS[data.rarity], attr_string]
			"html":
				attr_string = "<span style='color: %s;'>%s</span>" % [COLORS[data.rarity], attr_string]
			_:
				pass
		output += "%s | " % attr_string
	output = output.trim_suffix(" | ") + "]"
	return output


static func string_format_attribute(attr_data:Dictionary, output := ""):
	assert ("key" in attr_data)
	assert (attr_data.key != "")
	
	output = "%s %s %s" % [
		attr_data.key,
		attr_data.get("modifier", ""),
		string_format_attr_value(attr_data.get("value", -1), attr_data.get("is_empty", false))
	]
	output = reduce_spaces(output).strip_edges(false, true)
	return output


static func string_format_attr_value(value:int, is_empty:bool) -> String:
	if value < 0:
		return ""
	if is_empty:
		return "%s+" % value	
	return str(value)


static func create_data_from_attribute(attribute:StickerAttribute) -> Dictionary:
	var internal_name:String = Datatables.get_db_key(attribute.template_path)
	var is_empty:bool = false
	if internal_name.begins_with("specialization_"):
		is_empty = true
		internal_name = internal_name.trim_prefix("specialization_") 
	elif internal_name.begins_with("stat_"):
		internal_name = internal_name.trim_prefix("stat_") 
	if not (internal_name in Conversions.ATTRIBUTE_TO_KEYS):
		print("ERROR WITH %s" % internal_name)
		assert (true == false)
	var data:Dictionary = Conversions.ATTRIBUTE_TO_KEYS[internal_name].duplicate()

	if data.key == "Buff":
		data.modifier = get_status_name(attribute.buff)
	elif data.key == "Debuff":
		data.modifier = get_status_name(attribute.debuff)

	data.is_empty = is_empty
	data.value = get_value_attribute(attribute)
	match attribute.rarity:
		1:
			data.rarity = "uncommon"
		2:
			data.rarity = "rare"
		_:
			data.rarity = "common"
	return data


static func get_status_name(status:StatusEffect) -> String:
	var status_name:String = Strings.strip_diacritics(Loc.tr(status.get_name()))
	if status_name in Conversions.STATUS_CONTRACTIONS:
		status_name = Conversions.STATUS_CONTRACTIONS[status_name]
	status_name = status_name.replace("-", "").replace(" ", "")
	return status_name


# used for formattng the header (species name + bootleg type)
static func assign_header(species_name:String, type_name:String, args:Dictionary = {}) -> String:
	var output:String = species_name
	if type_name != "":
		match args.get("format", ""):
			"bbcode":
				output = "%s ([color=%s]%s[/color])" % [output, COLORS[type_name.to_lower()], type_name]
			"html":
				if args.get("include_attributes", true):
					output = "<tr><td colspan='2'>%s (<span style='color: %s;'>%s</span>)</td></tr>" % [output, COLORS[type_name.to_lower()], type_name]
				else:
					output = "<div>%s (<span style='color: %s;'>%s</span>)</div>" % [output, COLORS[type_name.to_lower()], type_name]
			_:
				output = "%s (%s)" % [output, type_name]
	elif type_name == "" and args.get("format", "") == "html":
		if args.get("include_attributes", true):
			output = "<tr><td colspan='2'>%s</td></tr>" % output
		else:
			output = "<div>%s</div>" % output
	return output


# assigns color to identifiers
static func assign_misc(identifier:String, text:String, args:Dictionary = {}, output := "") -> String:
	assert (identifier != "")
	output = "%s: %s" % [identifier, text]
	match args.get("format", ""):
		"bbcode":
			output = "[color=%s]%s[/color]"	% [COLORS["misc"], output]
		"html":
			if args.get("include_attributes", true):
				output = "<tr><td colspan='2' style='color: %s;'>%s</td></tr>" % [COLORS["misc"], output]
			else:
				output = "<div style='color: %s;'>%s</div>" % [COLORS["misc"], output]
	return output


static func import_pastes(paste:String, check_legality:bool = true) -> Array:
	var header_regex = RegEx.new()
	header_regex.compile("(?m)^\\w[^:\\n]*$")
	var header_result = header_regex.search_all(paste)
	if not header_result:
		push_error("No headers recognized.")
		return []

	var tapes:Array = []
	var header_indices:Array = []
	for result in header_result:
		header_indices.push_back(result.get_start())
	header_indices.push_back(len(paste))
	
	for i in range(len(header_result)):
		var subpaste = paste.substr(header_indices[i], header_indices[i+1] - header_indices[i])
		var tape = import_paste(subpaste, check_legality)
		if tape:
			tapes.push_back(tape)
	return tapes


# use this for directly generating the tape
static func import_paste(paste:String, check_legality:bool = true) -> MonsterTape:
	var tape = MonsterTape.new()

	# reads off header for monster name, type (optional)
	var name_regex = RegEx.new()
	var name_string = paste.split("\n")[0]
	name_regex.compile("^(\\w[\\w _-]*?)\\s*(?:\\((\\w*?)\\))? *$")
	var name_result = name_regex.search(name_string)
	if not name_result:
		push_error("No species recognized in the first line of the paste %s" % name_string)
		report_import_error()
		return null
	
	var species_name = reduce_spaces(name_result.strings[1])
	species_name = species_name.replace(" ", "_").to_lower()
	
	var form = MonsterForms.get_from_key(species_name, false)
	if not form:
		push_error("No species recognized in the first line of the paste %s" % name_string)
		report_import_error()
		return null

	tape.form = form
	if name_result.strings.size() > 2:
		var type_id:String = name_result.strings[2].to_lower()
		var types = Datatables.load("res://data/elemental_types/").table
		if type_id != "" and not types.has(type_id):
			push_warning("Invalid bootleg type %s" % name_result.strings[2])
			report_import_error()
		if types.has(type_id):
			tape.type_override = [types[type_id]]

	# sets the tape's nickname
	var alias_regex = RegEx.new()
	alias_regex.compile("(?mi)^Nickname\\s*:(?: *)?(.*)$")
	var alias_result = alias_regex.search(paste)
	if alias_result:
		var alias:String = alias_result.strings[-1]
		tape.set_name_override(alias)

	# sets the tape's grade	if declared, defaults to 5
	var grade_regex = RegEx.new()
	grade_regex.compile("(?mi)^Grade\\s*:(?: *)?([0-9])")
	var grade_result = grade_regex.search(paste)
	if grade_result:
		var grade:int = int(clamp(int(grade_result.strings[-1]), 0, 5))
		tape.upgrade_to(grade, null, true)
	else:
		tape.upgrade_to(5, null, true)
	tape.stickers = []

	# sets the tape's moves
	var moves_regex = RegEx.new()
	moves_regex.compile("(?m)^(?:- *)(\\w[\\w-]+(?: +\\w+)*)\\s*(?:\\[\\s*([\\w+][^|]*?)(?: *?\\|\\s*?([\\w+][^|]*?)(?: *?\\|\\s*?([\\w+][^|]*?)\\s*?)?)?\\])?$")
	var moves_results = moves_regex.search_all(paste)
	if moves_results:
		tape.stickers = generate_movesets(moves_results, tape, check_legality)
	if check_legality:
		var imported_stickers_size = tape.stickers.size()
		tape.fix_slot_overflow(true)
		if imported_stickers_size > tape.stickers.size():
			push_warning("Some stickers were removed from tape %s for exceeding the slot limit" % [Loc.tr(tape.get_name())])
			report_import_error()
		for j in range(tape.stickers.size()):
			var move = tape.get_move(j)
			if move and not BattleMoves.is_compatible(tape, move):
				tape.peel_sticker(j)
				push_warning("Sticker %s is not compatible with tape %s" % [Loc.tr(tape.get_name()), Loc.tr(move.get_name())])
				report_import_error()
	return tape


static func generate_movesets(moves_match_array:Array, tape:MonsterTape, check_legality:bool)->Array:
	if not tape:
		return []
	
	var moves_override_list = []
	
	for move_match in moves_match_array:
		if not move_match is RegExMatch:
			continue
		var move_name = format_move(move_match.strings[1])
		if move_name == "_empty_slot":
			moves_override_list.push_back(null)
			continue
		if not move_name in BattleMoves.by_id:
			push_warning("Move %s does not match any move" % move_name)
			report_import_error()
			continue
		var move = BattleMoves.by_id[move_name]
		if not BattleMoves.can_be_sticker(move):
			push_warning("Move %s cannot exist as a sticker" % move_name)
			report_import_error()
			continue
		var sticker = StickerItem.new()
		sticker.battle_move = move
		
		if move_match.strings.size() > 2:
			var attributes:Array = move_match.strings.slice(2, move_match.strings.size() - 1)
			var attributes_list:Array = []
			for attribute in attributes:
				var attr = generate_attribute(move, attribute, check_legality)
				if attr != null:
					attributes_list.push_back(attr)
			sticker.attributes = attributes_list
		moves_override_list.push_back(sticker)
	
	return moves_override_list


static func generate_attribute(move:BattleMove, attribute_string:String, check_legality:bool):
	# parses the given: AttributeKey Modifier Number
	# assumes that the regex match has already been sliced
	var attr_string_array:Array = attribute_string.split(" ", false)
	if attr_string_array.size() == 0:
		return null
	var data:Dictionary = create_attribute_data(attr_string_array)
	if not data.attribute_name in Conversions.ATTRIBUTES:
		push_warning("Invalid attribute name %s" % data.attribute_name)
		report_import_error()
		return null

	var result = Conversions.ATTRIBUTES[data.attribute_name]
	var attribute:StickerAttribute

	if result is StickerAttribute:
		attribute = result.instance()
		if not attribute.is_applicable_to(move):
			push_warning("Attribute %s is not compatible with move" % [data.attribute_name, Loc.tr(move.get_name())])
			report_import_error()
			return null
		set_value_attribute(attribute, data.get("value", 0), check_legality)

		# special case handling for buff and debuff attributes
		if attribute.get("buffs") != null:
			if data.get("modifier_name", "") == "":
				push_warning("Failed to generate attribute for %s: buff user attribute has no specified status effect" % Loc.tr(move.get_name()))
				report_import_error()
				return null
			var buff_name:String = data.modifier_name
			if buff_name in Conversions.STATUS_CONVERSIONS:
				buff_name = Conversions.STATUS_CONVERSIONS[buff_name]
			if not buff_name in Conversions.STATUSES:
				push_warning("Failed to generate attribute for %s: invalid status effect name %s" % [Loc.tr(move.get_name()), buff_name])
				report_import_error()
				return null
			var status:StatusEffect = Conversions.STATUSES[buff_name]
			if not status in attribute.buffs:
				push_warning("Failed to generate attribute for %s: specified status effect %s is not valid" % [Loc.tr(move.get_name()), buff_name])
				report_import_error()
				return null
			var buff_index = attribute.buffs.find(status)
			if buff_index < attribute.varied_amounts.size() and buff_index >= 0:
				attribute.amount = attribute.varied_amounts[buff_index]
			else:
				attribute.amount = attribute.default_amount
		elif attribute.get("debuffs"):
			if data.get("modifier_name", "") == "":
				push_warning("Failed to generate attribute for %s: debuff target attribute has no specified status effect" % Loc.tr(move.get_name()))
				report_import_error()
				return null
			var debuff_name:String = data.modifier_name
			if debuff_name in Conversions.STATUS_CONVERSIONS:
				debuff_name = Conversions.STATUS_CONVERSIONS[debuff_name]
			if not debuff_name in Conversions.STATUSES:
				push_warning("Failed to generate attribute for %s: invalid status effect name %s" % [Loc.tr(move.get_name()), debuff_name])
				report_import_error()
				return null
			var status:StatusEffect = Conversions.STATUSES[debuff_name]
			if not status in attribute.debuffs:
				push_warning("Failed to generate attribute for %s: specified status effect %s is not valid" % [Loc.tr(move.get_name()), debuff_name])
				report_import_error()
				return null
			var debuff_index = attribute.debuffs.find(status)
			if debuff_index < attribute.varied_amounts.size() and debuff_index >= 0:
				attribute.amount = attribute.varied_amounts[debuff_index]
			else:
				attribute.amount = attribute.default_amount
		return attribute

	elif result is Dictionary:
		# no modifier means it's a regular vs per empty
		# so excludes alt attack, auto-use, and passive stats
		if data.get("modifier_name", "") == "":
			if not "regular" in result:
				push_warning("Something went wrong generating attributes for %s: %s" % [Loc.tr(move.get_name()), attribute_string])
				report_import_error()
				return null			
			attribute = result["empty"].instance() if data.is_empty else result["regular"].instance()
			if not attribute.is_applicable_to(move):
				push_warning("Attribute %s is not compatible with move" % [data.attribute_name, Loc.tr(move.get_name())])
				report_import_error()
				return null
			set_value_attribute(attribute, data.get("value", 0), check_legality)
			return attribute

		result = result[data.modifier_name]		
		# only true for passive stat attributes
		if result is Dictionary:
			if not "regular" in result:
				push_warning("Something went wrong generating attributes for %s: %s" % [Loc.tr(move.get_name()), attribute_string])
				report_import_error()
				return null
			attribute = result["empty"].instance() if data.is_empty else result["regular"].instance()
			if not attribute.is_applicable_to(move):
				push_warning("Attribute %s is not compatible with move" % [data.attribute_name, Loc.tr(move.get_name())])
				report_import_error()
				return null
			set_value_attribute(attribute, data.get("value", 0), check_legality)
			return attribute
		elif result is StickerAttribute:
			attribute = result.instance()
			if not attribute.is_applicable_to(move):
				push_warning("Attribute %s is not compatible with move" % [data.attribute_name, Loc.tr(move.get_name())])
				report_import_error()
				return null
			set_value_attribute(attribute, data.get("value", 0), check_legality)
			return attribute
	return attribute


static func create_attribute_data(string_array:Array, output := {}) -> Dictionary:
	assert (string_array.size() > 0)
	output.attribute_name = format_attribute(string_array[0].to_lower())

	if string_array.size() == 1:
		return output
			
	if is_modifier_key(string_array[1]):
		output.modifier_name = string_array[1].to_lower()
		if output.modifier_name in Conversions.MODIFIER_CONVERSIONS:
			output.modifier_name = Conversions.MODIFIER_CONVERSIONS[output.modifier_name]
	
	elif string_get_attribute_value(string_array[1]) > 0:
		output.is_empty = is_empty_slot_scaling(string_array[1])
		output.value = string_get_attribute_value(string_array[1])
		return output

	if string_array.size() > 2 and string_get_attribute_value(string_array[2]) > 0:
		output.is_empty = is_empty_slot_scaling(string_array[2])
		output.value = string_get_attribute_value(string_array[2])
	
	return output


static func set_value_attribute(attribute:StickerAttribute, value:int, check_legality:bool):
	if "stat_value" in attribute:
		if value == 0:
			attribute.stat_value = attribute.stat_value_max
		elif check_legality:
			attribute.stat_value = int(clamp(value, attribute.stat_value_min, attribute.stat_value_max ))
		else:
			attribute.stat_value = value
	elif "chance" in attribute:
		if value == 0:
			attribute.chance = attribute.chance_max
		elif check_legality:
			attribute.chance = int(clamp(value, attribute.chance_min, attribute.chance_max))
		else:
			attribute.chance = value


static func get_value_attribute(attribute:StickerAttribute) -> int:
	if "stat_value" in attribute:
		return attribute.stat_value
	elif "chance" in attribute:
		return attribute.chance
	return -1


static func is_modifier_key(value:String) -> bool:
	# returns false if it's a number-type argument like 20 or 20+
	if "+" in value or "%" in value:
		return false
	return value.to_int() == 0


static func is_empty_slot_scaling(value:String) -> bool:
	# returns true if it's the per empty slot variant
	if is_modifier_key(value):
		return false
	return "+" in value


static func string_get_attribute_value(string_value:String) -> int:
	# returns the raw value of the number-type argument itself
	if is_modifier_key(string_value):
		return -1
	string_value = string_value.replace("%", "").trim_suffix("+")
	return string_value.to_int()


static func reduce_spaces(name:String) -> String:
	while "  " in name:
		name = name.replace("  ", " ")
	return name


static func format_move(move_name:String) -> String:
	# properly formats the move into a usable key string
	move_name = reduce_spaces(Strings.strip_diacritics(move_name))
	move_name = move_name.replace(" ", "_").replace("-", "_").to_lower()
	if move_name in Conversions.MOVE_NAME_CONVERSIONS:
		return Conversions.MOVE_NAME_CONVERSIONS[move_name]
	return move_name


static func format_attribute(attr_name:String):
	if attr_name in Conversions.ATTRIBUTE_NAME_CONVERSIONS:
		attr_name = Conversions.ATTRIBUTE_NAME_CONVERSIONS[attr_name]
	return attr_name


static func sanitize_to_html(text:String) -> String:
	return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&apos;")


static func _format_html_body(contents:Array) -> String:
	return HTML_HEAD + "\n" + _format_html_separator(contents) + HTML_FOOT


static func _format_html_separator(contents:Array) -> String:
	return "\n".join(contents)
	#return HTML_TAPE_SEPARATOR.join(contents)


static func _format_markdown(contents:Array) -> String:
	return "```\n" + "\n\n".join(contents) + "\n```"


static func export_to_html(contents:Array, path:String = "user://tape_export.html", is_formatted:bool = false):
	var file = File.new()
	file.open(path, File.WRITE)
	if is_formatted:
		file.store_string(HTML_TAPE_SEPARATOR.join(contents))
	else:
		file.store_string(_format_html_body(contents))
	file.close()
	return


static func export_to_markdown(contents:Array, path:String = "user://tape_export.md"):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(_format_markdown(contents))
	file.close()
	return


static func export_to_text(contents:Array, path:String = "user://tape_export.md"):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string("\n\n".join(contents))
	file.close()
	return


static func report_import_error():
	# keeps tally of importing errors to inform the user later on
	DLC.mods_by_id["cb_pastes"].import_errors += 1
