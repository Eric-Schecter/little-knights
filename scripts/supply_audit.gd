extends SceneTree
var g
var checks=0
var failures=[]
func check(ok,text):
 checks+=1
 if not ok:failures.append(text);push_error(text)
func _initialize():call_deferred('run')
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 check(g.supply.enabled,'Default game enables economic camps')
 check(g.population(0)==8 and g.population(1)==8 and g.capacity()==15,'Equal starting armies and population')
 check(g.buildings.filter(func(b):return b.kind=='Barracks').size()==2,'Both teams start with production')
 g.rebuild_nav()
 for team in range(2):
  var soldier=g.units.filter(func(u):return u.team==team and u.kind=='Warrior')[0]
  for point in g.supply.points:check(not g.nav.get_point_path(g.nearest_cell(soldier.p),g.nearest_cell(point.p)).is_empty(),'Both routes reachable')
 var key=InputEventKey.new();key.pressed=true;key.keycode=KEY_T;g._unhandled_input(key)
 check(g.selected.all(func(u):return u.mode=='attack_move' and u.goal.distance_to(g.supply.points[0].p)<160),'T issues main objective attack move')
 key.keycode=KEY_Y;g._unhandled_input(key)
 check(g.selected.all(func(u):return u.mode=='attack_move' and u.goal.distance_to(g.supply.points[1].p)<160),'Y issues north objective attack move')
 g.units.clear()
 var p=g.supply.points[0];var u=g.entity('Warrior',p.p);g.units.append(u)
 g.supply.tick(4);check(p.owner==-1 and p.progress==4,'Capture takes time')
 var enemy=g.entity('Warrior',p.p+Vector2(40,0),1);g.units.append(enemy)
 g.supply.tick(5);check(p.owner==-1 and p.progress==4 and p.contested,'Contested capture freezes')
 enemy.p=Vector2(2100,1000);g.supply.tick(4)
 check(p.owner==0,'Unopposed soldiers capture camp')
 var before=g.gold;g.supply.tick(10);check(g.gold==before+12,'Owned camp grants resources')
 enemy.p=p.p;g.supply.tick(10);check(g.gold==before+12,'Enemy presence immediately stops income')
 u.p=Vector2(300,500);g.supply.tick(8);check(p.owner==-1,'Enemy first neutralizes')
 g.supply.tick(8);check(p.owner==1,'Enemy then captures')
 p.owner=-1
 var north=g.supply.points[1];enemy.p=north.p
 g.supply.tick(8);var money=g.enemy_money;g.supply.tick(10)
 check(g.enemy_money-money==Vector2i(12,6),'North pays exact resource pulse')
 u.p=north.p;money=g.enemy_money;g.supply.tick(10);check(g.enemy_money==money,'Contested north pays nothing')
 g.units.clear();north.owner=-1;north.progress=0;north.claim=-1
 g.units.append(g.entity('Pawn',north.p));g.supply.tick(20);check(north.owner==-1,'Workers cannot capture')
 var dead=g.entity('Warrior',north.p);dead.hp=0;g.units.append(dead);g.supply.tick(20);check(north.owner==-1,'Dead soldiers cannot capture')
 g.supply.scores=[179.0,0.0];p.owner=0;g.supply.tick(600)
 check(g.outcome=='' and g.match_results.snapshot.is_empty(),'Holding a camp beyond the old victory threshold never ends the game')
 g.reset();check(g.outcome=='' and g.supply.scores==[0.0,0.0] and g.supply.points[0].owner==-1,'Restart clears objective state')
 g.paused=true;g.supply.points[0].owner=0;g._process(1);check(g.supply.scores[0]==0,'Pause freezes scoring')
 g.reset();g.paused=false
 g.buildings.filter(func(b):return b.team==1 and b.kind=='Castle')[0].hp=0
 g._process(0.1)
 check(g.outcome=='VICTORY' and g.match_results.snapshot.reason=='Town Center destroyed','Only base destruction produces victory')
 print('SUPPLY AUDIT ', 'PASS ' if failures.is_empty() else 'FAIL ',checks, ' ',failures);quit(0 if failures.is_empty() else 1)
