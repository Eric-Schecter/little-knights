extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.ai_enabled=false;g.paused=false;g.units.clear();g.resources.clear();g.nav_dirty=true
 var home=g.entity('Castle',Vector2(500,500));g.buildings=[home]
 var leader=g.entity('Warrior',Vector2(900,650));g.units=[leader]
 g.issue_order([home],leader.p,leader);leader.hp=0
 home.queue=['Pawn'];home.train=5;g.economy.tick_training(home,.01)
 var recruit=g.units[-1]
 assert(home.rally_unit==null and home.rally_disabled)
 assert(recruit.p==recruit.goal and recruit.mode=='guard' and recruit.p.distance_to(home.p)<130)
 g.issue_order([home],Vector2(800,650),null);assert(not home.rally_disabled)
 home.queue=['Pawn'];home.train=5;g.economy.tick_training(home,.01)
 assert(g.units[-1].goal.distance_to(Vector2(800,650))<100 and g.units[-1].mode=='move')
 leader=g.entity('Warrior',Vector2(1000,650));g.units.append(leader)
 g.issue_order([home],leader.p,leader);g.units.erase(leader);g.economy.update_unit_rally(home)
 assert(home.rally_disabled and home.rally_unit==null)
 print('DEAD RALLY PASS: death before spawn, removed leader, idle at doorway, explicit rally restores movement')
 quit()
