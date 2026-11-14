extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.ai_enabled=false;g.paused=false;g.units.clear();g.resources.clear();g.buildings.clear();g.map_style='plains';g.nav_dirty=true
 var target=g.entity('Barracks',Vector2(750,550),1);g.buildings=[target]
 var sword=g.entity('Warrior',Vector2(480,550));g.units=[sword]
 for i in range(360):g._process(1.0/60)
 assert(target.hp<target.max and is_same(sword.target,target),'Nearby building boundary must trigger autonomous attack')
 target.hp=target.max
 var siege=g.entity('Catapult',Vector2(420,550));g.units=[siege]
 for i in range(240):g._process(1.0/60)
 assert(target.hp<target.max,'Idle catapult must acquire and damage building beyond old guard leash')
 assert(g.effects.any(func(f):return f.get('siege_impact',false)) or not g.shots.is_empty())
 g.shots.clear();g.fire(siege,target,24);assert(not g.shots.is_empty())
 var shot=g.shots[-1];assert(shot.end==target.p)
 assert(g.art.building_rect(target).has_point(shot.visual_end))
 assert(g.siege_visual_position(shot,1).is_equal_approx(shot.visual_end))
 print('BUILDING ATTACK PASS: autonomous melee damage, siege acquisition and damage, projectile terminates on visible building wall')
 quit()
