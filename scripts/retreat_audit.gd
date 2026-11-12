extends SceneTree
var g
var failures=[]
func _initialize():call_deferred('run')
func check(ok,label):
 if not ok:failures.append(label)
 print(('PASS ' if ok else 'FAIL ')+label)
func setup(enemy_count,enemy_x):
 g.reset();g.units.clear();g.resources.clear();g.ai_enabled=false
 for i in range(3):g.units.append(g.entity('Warrior',Vector2(1580,650+i*42),1))
 for i in range(enemy_count):g.units.append(g.entity('Warrior',Vector2(enemy_x+(i%2)*35,610+int(i/2)*38)))
 g.fog.update()
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false)
 setup(8,1390);g.opponent.retreat.tick(0.6)
 var red=g.units.filter(func(u):return u.team==1)
 check(red.all(func(u):return u.get('retreating',false) and u.mode=='move' and u.target==null),'Outnumbered army disengages toward safe home')
 g.opponent.defense.tick(0.5)
 check(red.all(func(u):return u.mode=='move' and u.target==null),'Defense does not override retreat')
 for i in range(120):g._process(1.0/60)
 check(red.all(func(u):return u.p.x>1580),'Retreat makes real progress')
 for u in red:u.p=Vector2(1900,850)
 g.time=20;g.opponent.retreat.tick(0.6)
 check(red.all(func(u):return not u.retreating and u.retreat_cooldown>g.time),'Safe return enters regroup cooldown')
 setup(3,1390);g.opponent.retreat.tick(0.6)
 check(g.opponent.retreat.retreats==0,'Equal strength holds position')
 setup(8,1750);g.opponent.retreat.tick(0.6)
 check(g.opponent.retreat.retreats==0,'Does not flee through stronger enemies blocking home')
 setup(8,1390);g.opponent.retreat.tick(0.6)
 var retreaters=g.units.filter(func(u):return u.team==1)
 var castle=g.buildings.filter(func(b):return b.team==1 and b.kind=='Castle')[0]
 var raider=g.entity('Warrior',castle.p+Vector2(-180,0));raider.target=castle;g.units.append(raider);g.fog.update()
 g.opponent.retreat.tick(0.6);g.opponent.defense.tick(0.5)
 check(g.opponent.retreat.emergency and retreaters.all(func(u):return not u.get('retreating',false) and u.target!=null),'Critical base intrusion overrides existing retreat despite losing odds')
 setup(8,1390);g.opponent.retreat.tick(0.6)
 castle=g.buildings.filter(func(b):return b.team==1 and b.kind=='Castle')[0];castle.hp=500
 raider=g.entity('Archer',castle.p+Vector2(-380,0));g.units.append(raider);g.fog.update()
 g.opponent.retreat.tick(0.6);g.opponent.defense.tick(0.5)
 check(g.opponent.retreat.emergency and g.opponent.defense.home_alert,'Low-health base expands urgent defense perimeter')
 g.reset();check(g.opponent.retreat.retreats==0 and not g.opponent.retreat.emergency,'Restart resets retreat state')
 print('RETREAT AUDIT failures=',failures);quit(0 if failures.is_empty() else 1)
