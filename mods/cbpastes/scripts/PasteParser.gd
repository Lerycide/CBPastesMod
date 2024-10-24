extends Reference

const DEFAULT_LOCALE = "en"
const EMPTY_STICKER = "<Empty Slot>"

enum EXPORT_FORMAT{PlainText,Markdown,HTML}

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
	"typeless": "#000000"
}

# converts them to a form matching resource names
const MOVE_NAME_CONVERSIONS: Dictionary = {
	"<empty_slot>": "_empty_slot",
	"empty_slot": "_empty_slot",
	"empty_slot_-": "_empty_slot",
	"empty_slot-": "_empty_slot",
	"<_empty_slot_>": "_empty_slot",
	"-empty_slot-": "_empty_slot",
	"-_empty_slot_-": "_empty_slot",
	"emptyslot": "_empty_slot",
	"be_random!": "be_random",
	"be_random!!": "be_random",
	"be_random!!!": "be_random",
	"bish_bash_bosh": "bishbashbosh",
	"bush_fire": "bushfire",
	"clock_work_mous": "clockwork_mouse",
	"cm": "critical_mass",
	"complement": "compliment",
	"copy_cat": "copycat",
	"copythat": "copy_that",
	"cottoned_on": "cotton_on",
	"crit_ap": "critical_ap",
	"criticise": "criticize",
	"cs": "custom_starter",
	"deja_vu": "dejavu",
	"de_ja_vu": "dejavu",
	"djinn_toxicate": "djinntoxicate",
	"echolocate": "echolocation",
	"gem_stone_wall": "gemstone_wall",
	"hypnotise": "hypnotize",
	"ionized_air": "ionised_air",
	"iron_fillings": "iron_filings",
	"jagged_edges": "jagged_edge",
	"jumpscare": "jump_scare",
	"life_absorb": "hp_absorb",
	"lift_off": "liftoff",
	"mc": "machine_curse",
	"mind-meld": "mind_meld",
	"multi_copy": "multicopy",
	"multi-shot": "multi_shot",
	"multishot": "multi_shot",
	"multi-smack": "multi_smack",
	"multismack": "multi_smack",
	"neutralize": "neutralise",
	"polevault_assault": "pole_vault_assault",
	"pre-emptive_strike": "preemptive_strike",
	"qs": "quick_smack",
	"rs": "random_starter",
	"rf": "rapid_fire",
	"sand_storm": "sandstorm",
	"self-assured": "self_assured",
	"self-destruct": "self_destruct",
	"selfdestruct": "self_destruct",
	"sharp_edge": "sharp_edges",
	"sheer_luck": "starter2_passive",
	"shear_luck": "starter2_passive",
	"spring_loaded": "spring_load",
	"sitd": "stab_in_the_dark",
	"status_res": "status_resistance",
	"bonbon_blast": "starter1_attack",
	"bon_bon_blast": "starter1_attack",
	"battering_ram": "starter2_attack",
	"sugar_rush": "starter1_passive",
	"super_heated_fist": "superheated_fist",
	"sturdy_armor": "sturdy_armour",
	"old_1-2": "the_old_1_2",
	"old_1_2": "the_old_1_2",
	"the_old_1-2": "the_old_1_2",
	"trapjaw": "trap_jaw",
	"trip_wire": "tripwire",
	"twoheads": "two_heads",
	"tower_defense": "tower_defence",
	"water_works": "waterworks",
	"wonderful_seven": "wonderful_7",
	"w7": "wonderful_7",
	"wood_cutter": "woodcutter",

	"air_camouflage"		: "camouflage_air",
	"air_camo"				: "camouflage_air",
	"astral_camouflage"		: "camouflage_astral",
	"astral_camo"			: "camouflage_astral",
	"beast_camouflage"		: "camouflage_beast",
	"beast_camo"			: "camouflage_beast",
	"earth_camouflage"		: "camouflage_earth",
	"earth_camo"			: "camouflage_earth",
	"fire_camouflage"		: "camouflage_fire",
	"fire_camo"				: "camouflage_fire",
	"glass_camouflage"		: "camouflage_glass",
	"glass_camo"			: "camouflage_glass",
	"ice_camouflage"		: "camouflage_ice",
	"ice_camo"				: "camouflage_ice",
	"lightning_camouflage"	: "camouflage_lightning",
	"lightning_camo"		: "camouflage_lightning",
	"metal_camouflage"		: "camouflage_metal",
	"metal_camo"			: "camouflage_metal",
	"plant_camouflage"		: "camouflage_plant",
	"plant_camo"			: "camouflage_plant",
	"plastic_camouflage"	: "camouflage_plastic",
	"plastic_camo"			: "camouflage_plastic",
	"poison_camouflage"		: "camouflage:poison",
	"poison_camo"			: "camouflage:poison",
	"water_camouflage"		: "camouflage:water",
	"water_camo"			: "camouflage:water",	

	"air_coating"		: "coating_air",
	"astral_coating"	: "coating_astral",
	"beast_coating"		: "coating_beast",
	"earth_coating"		: "coating_earth",
	"elemental_coating"	: "coating_elemental",
	"fire_coating"		: "coating_fire",
	"glass_coating"		: "coating_glass",
	"ice_coating"		: "coating_ice",
	"lightning_coating"	: "coating_lightning",
	"metal_coating"		: "coating_metal",
	"plant_coating"		: "coating_plant",
	"plastic_coating"	: "coating_plastic",
	"poison_coating"	: "coating_poison",
	"water_coating"		: "coating_water",

	"air_resistance"		: "resistance_air",
	"astral_resistance"		: "resistance_astral",
	"beast_resistance"		: "resistance_beast",
	"earth_resistance"		: "resistance_earth",
	"fire_resistance"		: "resistance_fire",
	"fireproof"				: "resistance_fire",
	"fire_proof"			: "resistance_fire",
	"glass_resistance"		: "resistance_glass",
	"glitter_resistance"	: "resistance_glitter",
	"ice_resistance"		: "resistance_ice",
	"lightning_resistance"	: "resistance_lightning",
	"grounded"				: "resistance_lightning",
	"plant_resistance"		: "resistance_plant",
	"plastic_resistance"	: "resistance_plastic",
	"poison_resistance"		: "resistance_poison",
	"water_resistance"		: "resistance_water",
	"waterproof"			: "resistance_water",
	"water_proof"			: "resistance_water",
}

const HTML_HEAD = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tape Export</title>
<style>body {font-family: "Verdana", sans-serif;}</style>
</head>
</body>"""

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
				return "<div>%s</div>" % sanitize_to_html(output)
			_:
				return output

	output = "- " + Strings.strip_diacritics(Loc.tr(move.name))

	var id:String = "typeless"
	if move.elemental_types.size() > 0:
		id = move.elemental_types[0].id
	elif type:
		id = type.id
	
	match args.get("format", ""):
		"bbcode":
			return "[color=%s]%s[/color]" % [COLORS[id], output]
		"html":
			return "<div style='color: %s;'>%s</div>" % [COLORS[id], output]
		_:
			pass
	return output


# used for formattng the header (species name + bootleg type)
static func assign_header(species_name:String, type_name:String, args:Dictionary = {}) -> String:
	var output:String = species_name
	if type_name != "":
		match args.get("format", ""):
			"bbcode":
				output = "%s ([color=%s]%s[/color])" % [output, COLORS[type_name.to_lower()], type_name]
			"html":
				output = "<div>%s (<span style='color: %s;'>%s</span>)</div>" % [output, COLORS[type_name.to_lower()], type_name]
			_:
				output = "%s (%s)" % [output, type_name]
	elif type_name == "" and args.get("format", "") == "html":
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
	#name_regex.compile("^(\\w[\\w _-]*?(?!\\w*:)?) *(?:\\((\\w+?)\\))? *$")
	#name_regex.compile("^(.*?)\\s*(?:\\((.+?)\\))?\\s*$")
	name_regex.compile("^(\\w[\\w _-]*?) *(?:\\((\\w*?)\\))? *$")
	var name_result = name_regex.search(name_string)
	if not name_result:
		push_error("No species recognized in the first line of the paste. Check if this is a formatting error.")
		return null
	
	var species_name = name_result.strings[1].replace(" ", "_").to_lower()
	var form = MonsterForms.get_from_key(species_name, false)
	if not form:
		push_error("No species recognized in the first line of the paste. Check if this is a formatting error.")
		return null
	tape.form = form
	if name_result.strings.size() > 2:
		var type_id:String = name_result.strings[2].to_lower()
		var types = Datatables.load("res://data/elemental_types/").table
		if type_id != "" and not types.has(type_id):
			push_warning("Invalid bootleg type %s" % name_result.strings[2])
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


	# sets the tape's moves
	var moves_regex = RegEx.new()
	moves_regex.compile("(?m)^(?:- *)(.*?)(?:\\s*)$")
	var moves_results = moves_regex.search_all(paste)
	if moves_results:
		tape.stickers = generate_movesets(moves_results, tape, check_legality)
	return tape


static func generate_movesets(moves_match_array:Array, tape:MonsterTape, check_legality:bool)->Array:
	if not tape:
		return []
	
	var moves_override_list = []
	var max_slots:int = tape.get_stat("move_slots", false)
	
	for move_match in moves_match_array:
		if not move_match is RegExMatch:
			continue
		var move_name = format_move(move_match.strings[1])
		if move_name == "_empty_slot":
			if check_legality and moves_override_list.size() >= max_slots:
				push_warning("Move %s cannot be added as it exceeds the sticker slot limit" % move_name)
				continue
			else:
				moves_override_list.push_back(null)
		
		if not move_name in BattleMoves.by_id:
			push_warning("Move %s does not match any move" % move_name)
			continue
		var move = BattleMoves.by_id[move_name]
		if not BattleMoves.can_be_sticker(move):
			continue
		if check_legality:
			if not BattleMoves.is_compatible(tape, move):
				push_warning("Move %s is not compatible with tape" % move_name)
				continue
			if moves_override_list.size() >= max_slots:
				push_warning("Move %s cannot be added as it exceeds the sticker slot limit" % move_name)
				continue
		var sticker = StickerItem.new()
		sticker.battle_move = move
		moves_override_list.push_back(sticker)
	
	return moves_override_list
		

static func format_move(move_name:String):
	# properly formats the move into a usable key string
	move_name = Strings.strip_diacritics(move_name)
	move_name = move_name.replace(" ", "_").to_lower()
	if move_name in MOVE_NAME_CONVERSIONS:
		return MOVE_NAME_CONVERSIONS[move_name]
	return move_name

static func sanitize_to_html(text:String) -> String:
	return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&apos;")


static func _format_html_body(contents:Array) -> String:
	return HTML_HEAD + "\n" + _format_html_separator(contents) + HTML_FOOT


static func _format_html_separator(contents:Array) -> String:
	return HTML_TAPE_SEPARATOR.join(contents)


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
