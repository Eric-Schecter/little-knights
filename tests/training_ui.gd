extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.paused=true;g.ai_enabled=false
 var b=g.entity('Barracks',Vector2(600,600));g.buildings.append(b)
 g.selected=[b];g.refresh_commands()
 await process_frame
 g.icon_hud.update_training_buttons()
 var knight=g.commands.get_child(3)
 assert(knight.icon==g.icon_hud.icons.Cavalry)
 assert(knight.disabled and 'completed Blacksmith' in knight.tooltip_text)
 var smith=g.entity('Smith',Vector2(800,600));smith.progress=0.5;g.buildings.append(smith)
 g.icon_hud.update_training_buttons();assert(knight.disabled)
 smith.progress=1;g.gold=500;g.wood=500
 g.icon_hud.update_training_buttons();assert(not knight.disabled)
 g.gold=100;g.wood=0;g.icon_hud.update_training_buttons()
 assert(knight.disabled and '25 more gold' in knight.tooltip_text and '40 more wood' in knight.tooltip_text)
 assert(not g.economy.train('Cavalry',b))
 g.gold=500;g.wood=500;g.icon_hud.update_training_buttons()
 assert(g.economy.train('Cavalry',b))
 print('TRAINING UI PASS: knight icon, unfinished/completed prerequisite, live unlock, exact resource deficits, shared command validation')
 quit()
