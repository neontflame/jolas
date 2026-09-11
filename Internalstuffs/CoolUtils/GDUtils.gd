extends Node
class_name GDUtils

# scratch coiso
static func wait_until(condition:bool):
	while not condition:
		await Engine.get_main_loop().process_frame
