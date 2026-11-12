extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 g.units.clear();g.buildings.append(g.entity('House1',Vector2(620,480)));g.nav_dirty=true
 var u=g.entity('Warrior',Vector2(452.0052,489.0472));g.units.append(u)
 g.issue_order([u],Vector2(730,490),null)
 for i in range(300):g._process(1.0/30)
 print('EDGE ',u.p,' goal=',u.goal,' path=',u.path)
 quit(0 if u.p.distance_to(u.goal)<10 else 1)
