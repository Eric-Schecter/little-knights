extends SceneTree
var g
var failures=[]
var checks=0
func _initialize():call_deferred('run')
func check(ok,description):
 checks+=1
 if not ok:failures.append(description);push_error(description)
func clean():
 g.units.clear();g.buildings.clear();g.resources.clear();g.selected.clear();g.shots.clear();g.formations.clear();g.combat_events.clear()
 g.nav_dirty=true;g.outcome='';g.paused=false;g.time=0;g.raid=999
func unit(kind,p,team=0):
 var u=g.entity(kind,p,team);u.mode='stop';g.units.append(u);return u
func step(seconds):
 for i in range(int(seconds*60)):g._process(1.0/60)
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 clean()
 var a=unit('Warrior',Vector2(300,400));var b=unit('Warrior',Vector2(335,400),1)
 check(not g.can_attack(a,b),'Sword must not hit at 35px center distance')
 b.p.x=334;check(g.can_attack(a,b),'Sword must reach at 34px')
 g.selected=[a];g.order(b.p,b);step(0.1)
 check(b.hp==b.max,'No damage before wind-up')
 step(0.2);check(b.hp<b.max,'Damage at melee impact')
 clean();a=unit('Warrior',Vector2(300,400));b=unit('Warrior',Vector2(333,400),1)
 g.selected=[a];g.order(b.p,b);step(0.1);b.p.x=420;step(0.2)
 check(b.hp==b.max,'Target escapes melee wind-up without remote hit')
 clean();a=unit('Warrior',Vector2(300,400));b=unit('Warrior',Vector2(333,400),1)
 g.selected=[a];g.order(b.p,b);step(0.1);g.order(Vector2(200,400),null);step(0.5)
 check(b.hp==b.max and a.target==null and a.p.x<300,'Retreat cancels pending melee hit')
 clean();a=unit('Archer',Vector2(300,400));b=unit('Warrior',Vector2(511,400),1)
 check(not g.can_attack(a,b),'Archer cannot fire at 211px')
 b.p.x=510;check(g.can_attack(a,b),'Archer can fire at 210px')
 g.fire(a,b,18);check(b.hp==b.max and g.shots.size()==1,'Arrow launch does not apply immediate damage')
 step(0.2);check(b.hp==b.max,'Arrow damage waits for flight')
 step(0.4);check(b.hp<b.max,'Arrow damages stationary target on arrival')
 clean();a=unit('Archer',Vector2(300,400));b=unit('Warrior',Vector2(500,400),1)
 g.fire(a,b,18);b.p=Vector2(500,520);step(1)
 check(b.hp==b.max and g.shots.is_empty(),'Arrow cannot home indefinitely on moving target')
 for kind in ['Barracks','Castle']:
  for direction in [Vector2.RIGHT,Vector2.DOWN,Vector2(-1,0),Vector2(0,-1)]:
   clean();var building=g.entity(kind,Vector2(700,600),1);g.buildings.append(building)
   var edge=g.footprint(building).x if direction.x!=0 else g.footprint(building).y
   a=unit('Warrior',building.p+direction*(edge+100));g.selected=[a];g.order(building.p,building);step(3)
   check(building.hp<building.max,kind+' reachable from '+str(direction))
   for event in g.combat_events:check(event.gap<=18.01,'Melee building hit limited to footprint edge')
 clean();a=unit('Warrior',Vector2(500,600));b=unit('Warrior',Vector2(650,600),1)
 g.buildings.append(g.entity('Barracks',Vector2(575,600)))
 check(not g.attack_clear(a,b),'Melee cannot attack through a building')
 a.kind='Archer';check(not g.can_attack(a,b),'Archer cannot fire through intervening building')
 clean();var tower=g.entity('Tower',Vector2(500,500));g.buildings.append(tower)
 b=unit('Warrior',Vector2(777,500),1);check(not g.can_attack(tower,b),'Tower respects outer range')
 b.p.x=776;check(g.can_attack(tower,b),'Tower reaches boundary')
 clean();a=unit('Warrior',Vector2(300,400));b=unit('Warrior',Vector2(420,400),1)
 g.selected=[a];g.order(Vector2(650,400),null);step(1)
 check(a.target==null and g.combat_events.is_empty(),'Ordinary move does not acquire enemies')
 g.order(Vector2(650,400),null,'attack_move');step(2)
 check(not g.combat_events.is_empty(),'Attack move acquires and fights enemy')
 g.stop_selected();var p=a.p;var hits=g.combat_events.size();step(1)
 check(a.p.distance_to(p)<1 and g.combat_events.size()==hits,'Stop cancels pursuit and attacks')
 clean();g.setup_review();g.review=false
 step(16)
 var crossed=0
 for u in g.selected:
  if u.p.x>1308:crossed+=1
 check(crossed==12,'All 12 units navigate barracks and bridge')
 g.order(Vector2(960,680),null);step(16)
 check(g.selected.all(func(u):return u.p.x<1092 and u.target==null),'Entire formation returns west bank')
 print('STAGE1 AUDIT: ',checks,' checks, failures=',failures)
 quit(0 if failures.is_empty() else 1)
