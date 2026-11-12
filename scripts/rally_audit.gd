extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 g.units.clear();g.buildings.clear();g.resources.clear();g.nav_dirty=true
 for i in range(2):
  var u=g.entity('Warrior',Vector2(500+i*20,500));u.goal=Vector2(600,500);u.mode='move';g.units.append(u)
 var walk=0;var travel=0.0
 for frame in range(600):
  var old=g.units.map(func(u):return u.p)
  g._process(1.0/60)
  if frame>480:
   for i in range(2):
    if g.units[i].motion_hold>0:walk+=1
    travel+=old[i].distance_to(g.units[i].p)
 print('RALLY walking frames=',walk,' final travel=',travel)
 quit(0 if walk==0 and travel<0.1 else 1)
