extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.ai_enabled=false;g.paused=false
 assert(g.supply.enabled and not g.supply.camps_enabled and g.supply.map_buttons.is_empty())
 var income=g.enemy_money;var squad=[]
 for i in range(4):squad.append(g.entity('Warrior',g.supply.points[0].p+Vector2(i*15,0),1))
 g.units=squad
 for i in range(60):g.supply.tick(1)
 assert(g.enemy_money==income and g.supply.points[0].owner==-1)
 g.time=g.opponent.profile().first_attack
 g.supply.planner.teams[1].members=squad.duplicate()
 g.supply.planner.plan(1)
 assert(g.supply.planner.teams[1].assault and squad.all(func(u):return u.mode=='attack_move'))
 assert(squad[0].goal.distance_to(g.supply.planner.assault_destination(1))<200)
 print('NO CAMPS PASS: no markers or income; army proceeds through waypoint to enemy base')
 quit()
