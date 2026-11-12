extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 g.units.clear();g.buildings.clear();g.resources.clear();g.nav_dirty=true
 var army=[]
 for i in range(12):
  var u=g.entity('Warrior',Vector2(300+(i%3)*42,350+int(i/3)*42));u.mode='stop';g.units.append(u);army.append(u)
 for i in range(18):
  var u=g.entity('Warrior',Vector2(600,200+i*24),1);u.mode='stop';g.units.append(u)
 g.issue_order(army,Vector2(850,420),null)
 var flips=0;var moves=0;var min_gap=1000.0;var max_step=0.0;var velocities={};var states={}
 for frame in range(1200):
  var before=army.map(func(u):return u.p)
  g._process(1.0/60)
  for i in range(army.size()):
   var delta=army[i].p-before[i]
   for enemy in g.units:
    if enemy.team==1:min_gap=min(min_gap,army[i].p.distance_to(enemy.p))
   if frame>900:
    max_step=max(max_step,delta.length())
    if velocities.has(i) and delta.length()>0.1 and velocities[i].length()>0.1 and delta.dot(velocities[i])<0:flips+=1
    if states.has(i) and states[i]!=army[i].moving:moves+=1
   velocities[i]=delta;states[i]=army[i].moving
 print('CROWD: reversals=',flips,' moving toggles=',moves,' max_step=',max_step,' min_enemy_gap=',min_gap)
 quit(0 if flips==0 and moves==0 and min_gap>=23.99 else 1)
