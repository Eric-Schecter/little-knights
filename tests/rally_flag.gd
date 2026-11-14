extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.ai_enabled=false;g.paused=false
 var home=g.buildings.filter(func(b):return b.team==0 and b.kind=='Castle')[0]
 g.selected=[home]
 var point=Vector2(800,600)
 g.order(point,null)
 assert(home.rally.distance_to(point)>8,'Exercise the old snap-distance duplication')
 assert(not g.effects.any(func(f):return f.get('command_flag',false)))
 assert(home.rally_set_at==g.time and not home.rally_disabled)
 var leader=g.units.filter(func(u):return u.team==0)[0]
 g.order(leader.p,leader);leader.p+=Vector2(40,0);g.economy.update_unit_rally(home)
 assert(home.rally==leader.p and not g.effects.any(func(f):return f.get('command_flag',false)))
 g.selected=[leader];g.order(Vector2(700,600),null)
 assert(g.effects.filter(func(f):return f.get('command_flag',false)).size()==1)
 g.selected=[home];g.order(point,null)
 assert(not g.effects.any(func(f):return f.get('command_flag',false)))
 print('RALLY FLAG PASS: snapped ground and moving leader use persistent flag only, unit movement retains one temporary flag, old feedback cleared')
 quit()
