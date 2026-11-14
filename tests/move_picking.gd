extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.units.clear();g.buildings.clear();g.resources.clear();g.paused=false;g.nav_dirty=true
 var a=g.entity('Warrior',Vector2(400,500));var b=g.entity('Warrior',Vector2(440,500));var worker=g.entity('Pawn',Vector2(600,500))
 g.units=[a,b,worker];g.selected=[a,b]
 assert(g.pick_order(worker.p-Vector2(0,18))==null)
 g.order(worker.p,worker);assert(a.formation>=0 and a.formation==b.formation)
 g.issue_order([a],Vector2(700,500),null);assert(a.goal==Vector2(700,500))
 var home=g.entity('Castle',Vector2(300,300));g.buildings=[home];g.selected=[home]
 assert(is_same(g.pick_order(worker.p-Vector2(0,18)),worker))
 g.order(worker.p,worker);assert(is_same(home.rally_unit,worker))
 var enemy=g.entity('Warrior',Vector2(700,500),1);g.units.append(enemy);g.fog.observer=true;g.fog.update();g.fog.animate(1,true)
 g.selected=[a];assert(is_same(g.pick_order(enemy.p-Vector2(0,18)),enemy))
 g.order(enemy.p,null);assert(a.target==null and a.mode=='move' and a.goal==enemy.p)
 print('MOVE PICKING PASS: friendly click-through, formation on occupied ground, exact single destination, unit rally preserved, enemy attack picking and explicit ground orders')
 quit()
