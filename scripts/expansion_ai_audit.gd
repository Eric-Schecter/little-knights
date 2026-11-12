extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.time=200;g.enemy_money=Vector2i(4000,4000);g.resources.clear()
 g.buildings.append(g.entity('Barracks',Vector2(1770,700),1))
 for p in [Vector2(2200,350),Vector2(2200,500),Vector2(2200,1150),Vector2(1900,1150)]:g.buildings.append(g.entity('House1',p,1))
 g.nav_dirty=true
 for frame in range(5400):g._process(1.0/60)
 var smith=g.opponent.owned('Smith');var workshop=g.opponent.owned('Workshop')
 assert(not smith.is_empty() and smith[0].progress>=1,'AI builds and completes blacksmith')
 assert(not workshop.is_empty() and workshop[0].progress>=1,'AI builds and completes workshop')
 assert(g.technology.levels[1].attack>=1,'AI pays for and completes research')
 assert(g.units.any(func(u):return u.team==1 and u.kind=='Spearman'),'AI trains spearmen')
 assert(g.units.any(func(u):return u.team==1 and u.kind=='Catapult'),'AI trains siege')
 assert(g.units.any(func(u):return u.team==1 and u.kind=='Cavalry'),'AI trains mounted knights after forge completion')
 print('EXPANSION AI PASS: funded AI legally constructs, researches and trains both new units; levels=',g.technology.levels[1])
 quit()
