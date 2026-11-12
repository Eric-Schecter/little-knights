extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false;g.supply.enabled=false;g.units=[];g.resources=[];g.gold=2000;g.wood=2000
 var up=g.tower_upgrades;assert(up.NAMES.size()==2)
 var t=g.entity('Tower',Vector2(650,550));g.buildings.append(t);t.hp=350
 assert(not up.upgrade(t,'watch') and not up.upgrade(t,'heavy'))
 assert(up.upgrade(t,'arrow') and g.gold==1910 and g.wood==1930)
 assert(not up.upgrade(t,'cannon'))
 up.tick(t,15);assert(up.level(t)==1 and t.hp==350)
 assert(up.upgrade(t,'arrow'));up.tick(t,20);assert(up.level(t)==2 and not up.upgrade(t,'arrow'))
 var enemy=g.entity('Spearman',Vector2(750,550),1);g.units.append(enemy);g.fog.update()
 t.cool=0;up.tick(t,0.01);up.tick(t,0.2);assert(g.shots.size()==2)
 g.shots=[];g.buildings.erase(t)
 var cannon=g.entity('Tower',Vector2(650,550));g.buildings.append(cannon)
 assert(up.upgrade(cannon,'cannon'));up.tick(cannon,15);assert(up.splash(cannon)==42)
 assert(up.upgrade(cannon,'cannon'));up.tick(cannon,20);assert(up.splash(cannon)==60)
 var nearby=g.entity('Warrior',Vector2(780,550),1);g.units.append(nearby)
 var far=g.entity('Warrior',Vector2(850,550),1);g.units.append(far)
 var friendly=g.entity('Warrior',Vector2(755,550));g.units.append(friendly)
 for u in g.units:u.mode='stop';u.goal=u.p
 g.fog.update();g.fire(cannon,enemy,g.base_attack(cannon));assert(g.shots[0].tower_branch=='cannon')
 assert(g.sfx.counts.get('tower_cannon',0)>0)
 cannon.cool=999
 for i in range(20):g._process(1.0/30)
 assert(enemy.hp<enemy.max and nearby.hp<nearby.max and far.hp==far.max and friendly.hp==friendly.max,'Blast damages nearby enemies only')
 assert(not enemy.has('slow_until'))
 assert(g.sfx.counts.get('tower_cannon_hit',0)>0)
 print('TOWER AUDIT PASS: exactly two branches, costs, lock, HP, double arrow, cannon radius, real splash, no friendly damage and audio');quit()
