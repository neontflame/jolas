extends Node
class_name QuestUtils

static var assignedQuests:Array = []
static var clearedQuests:Array = []

static func clear_all():
	assignedQuests = []
	clearedQuests = []

static func assign(questName:StringName):
	# voce nao pode refazer uma quest que voce ja completou!!
	if assignedQuests.has(questName) or clearedQuests.has(questName): return
	assignedQuests.append(questName)

static func abandon(questName:StringName):
	if not assignedQuests.has(questName): return
	assignedQuests.erase(questName)

static func conclude(questName:StringName, additionalPerks:Callable = func():pass):
	if not assignedQuests.has(questName): return
	assignedQuests.erase(questName)
	clearedQuests.append(questName)
	GPStats.xp += get_info(questName)['xpReward']
	if get_info(questName).has("unlocksChar"):
		UnlockUtils.unlock_char(get_info(questName)["unlocksChar"])
	additionalPerks.call()

static func get_info(questName:StringName):
	var queStuff = "res://Gamestuffs/Quests/%s.json" % questName
	var questInfo = '' 
	if !ResourceLoader.exists(queStuff):
		questInfo = '{
	"name": "Placeholder",
	"icon": "question mark",
	"xpReward": 0,
	"desc": "o que essa quest sequer [wave]faz ?[/wave]"
	}'
	else:
		questInfo = FileUtils.get_text_file_content(queStuff)
	var questGotten = JSON.parse_string(questInfo)
	return questGotten
