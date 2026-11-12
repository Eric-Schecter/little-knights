extends SceneTree
var g
var failures=[]
func _initialize():call_deferred('run')
func check(ok,text):
 if not ok:failures.append(text);push_error(text)
 else:print('PASS: '+text)
func clean():
 g.reset();g.ai_enabled=false;g.units.clear();g.buildings.clear();g.resources.clear();g.nav_dirty=true
func add(p,team):
 var u=g.entity('Warrior',p,team);u.mode='stop';g.units.append(u);return u
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);clean()
 var a=add(Vector2(400,400),0);var b=add(Vector2(500,400),1)
 g.issue_order([a],Vector2(700,400),null)
 var min_gap=INF;var switches=0;var last=false;var tail=[]
 for i in range(600):
  g._process(1.0/60)
  min_gap=min(min_gap,a.p.distance_to(b.p))
  if i>180:
   if a.moving!=last:switches+=1
   tail.append(a.p)
  last=a.moving
 check(min_gap>=23.99 and a.p.x<500,'Head-on movement cannot pass through stationary enemy')
 check(switches==0 and tail.all(func(p):return p.distance_to(tail[0])<0.05),'Resting contact stays still without move/idle jitter')
 g.blocking.move(a,Vector2(800,400))
 check(a.p.x<500,'Swept collision prevents tunneling on large movement steps')
 g.issue_order([a],Vector2(450,300),null)
 for i in range(120):g._process(1.0/60)
 g.issue_order([a],Vector2(650,300),null)
 for i in range(240):g._process(1.0/60)
 check(a.p.x>550,'Explicit flank route gets around opponent')
 clean();a=add(Vector2(400,400),0);b=add(Vector2(600,400),1)
 g.issue_order([a],Vector2(700,400),null);g.issue_order([b],Vector2(300,400),null)
 for i in range(180):g._process(1.0/60)
 check(a.p.distance_to(b.p)>=23.99 and a.p.x<b.p.x,'Opposing moving units cannot swap through each other')
 clean();a=add(Vector2(476,400),0);b=add(Vector2(500,400),1)
 for i in range(5):add(Vector2(465,400+i*2),0)
 for i in range(180):g._process(1.0/60)
 check(g.units.filter(func(u):return u.team==0).all(func(u):return u.p.distance_to(b.p)>=23.99),'Friendly separation cannot push units through enemy')
 clean();a=add(Vector2(400,400),0);b=add(Vector2(500,400),1)
 var castle=g.entity('Castle',Vector2(750,400),1);g.buildings.append(castle);g.nav_dirty=true
 g.issue_order([a],castle.p,castle)
 for i in range(180):g._process(1.0/60)
 check(castle.hp==castle.max and a.p.x<500,'Direct base focus remains blocked by its defender')
 g.issue_order([a],b.p,b)
 for i in range(600):g._process(1.0/60)
 check(b.hp<=0,'Attacker can fight the blocking defender')
 g.issue_order([a],castle.p,castle)
 for i in range(360):g._process(1.0/60)
 check(castle.hp<castle.max,'After defender dies the route opens to the base')
 clean();var producer=g.entity('Barracks',Vector2(700,400));g.buildings.append(producer)
 b=add(Vector2(710,470),1);g.gold=300;g.train('Warrior',producer)
 for i in range(270):g._process(1.0/30)
 check(producer.queue.size()==1 and g.units.size()==1,'Blocked production exit waits without spawning inside enemy')
 b.hp=0
 for i in range(2):g._process(1.0/30)
 check(producer.queue.is_empty() and g.units.any(func(u):return u.team==0),'Production resumes after exit clears')
 print('BLOCKING AUDIT failures=',failures);quit(0 if failures.is_empty() else 1)
