extends SceneTree
var g
var failures=[]
func _initialize():call_deferred('run')
func check(ok,text):
 if not ok:failures.append(text);push_error(text)
 else:print('PASS: '+text)
func measure(group,seconds,tail):
 var travel=0.0;var toggles=0;var last={}
 for frame in range(int(seconds*60)):
  var before=group.map(func(u):return u.p)
  g._process(1.0/60)
  for i in range(group.size()):
   if frame>=int((seconds-tail)*60):
    travel+=before[i].distance_to(group[i].p)
    if last.has(i) and last[i]!=group[i].moving:toggles+=1
   last[i]=group[i].moving
 return {'travel':travel,'toggles':toggles}
func add(p):
 var u=g.entity('Warrior',p,1);g.units.append(u);return u
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 g.units.clear();g.resources.clear()
 var squad=[]
 for i in range(6):squad.append(add(Vector2(1700+(i%3)*45,600+int(i/3)*45)))
 g.opponent.defense.defenders=squad.duplicate();g.opponent.defense.active=true;g.opponent.defense.last_seen=-10;g.time=6
 g.opponent.defense.tick(0.3)
 var result=measure(squad,20,5)
 print('RETURN ARRIVAL ',result)
 check(result.travel<0.1 and result.toggles==0,'Returning defenders settle without pushing and walking in place')
 var before=squad.map(func(u):return u.p)
 g.issue_order(squad,Vector2(1600,900),null,'move');measure(squad,3,0)
 check(squad.all(func(u):return u.moving),'A fresh command wakes the entire settled group')
 result=measure(squad,10,3);check(result.travel<0.1 and result.toggles==0,'Second destination also settles')
 # A final stationary slot should stop within one frame at a small arrival error.
 var u=squad[0];u.target=null;u.job=null;u.formation=999;u.slot_velocity=Vector2.ZERO
 var origin=u.p;g.move_unit(u,origin+Vector2(3,0),1.0/60)
 check(u.p==origin and not u.moving,'Final slot does not creep through the last three pixels')
 print('ARRIVAL AUDIT failures=',failures);quit(0 if failures.is_empty() else 1)
