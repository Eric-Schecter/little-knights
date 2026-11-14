extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.ai_enabled=false;g.paused=false;g.units.clear();g.resources.clear();g.formations.clear();g.nav_dirty=true
 assert(g.difficulty=='easy')
 for setting in ['easy','normal','hard']:
  g.difficulty=setting;g.supply.planner.reset()
  var config=g.opponent.profile();var squad=[]
  for i in range(6):squad.append(g.entity('Warrior',g.supply.planner.staging(1)+Vector2(i*20,0),1))
  g.units=squad;g.time=config.first_attack-1
  g.supply.planner.plan(1);assert(g.supply.planner.launches.is_empty())
  g.time=config.first_attack;g.supply.planner.plan(1);assert(g.supply.planner.launches.size()==1)
  var more=[]
  for i in range(4):more.append(g.entity('Warrior',g.supply.planner.staging(1)+Vector2(i*20,60),1))
  g.units.append_array(more);g.time+=1;g.supply.planner.plan(1);assert(g.supply.planner.launches.size()==1)
  g.time=config.first_attack+config.attack_gap;g.supply.planner.plan(1);assert(g.supply.planner.launches.size()==2)
  var b=g.entity('Barracks',Vector2(1000,800),1)
  var cap=[]
  for i in range(config.army_cap):cap.append(g.entity('Warrior',Vector2.ZERO,1))
  assert(not g.opponent.can_train(b,cap))
  b['ai_train_after']=g.time+1;assert(not g.opponent.can_train(b,[]));g.time+=1;assert(g.opponent.can_train(b,[]))
  var blue=g.entity('Warrior',Vector2.ZERO);var red=g.entity('Warrior',Vector2.ZERO,1)
  assert(blue.hp==red.hp and g.base_attack(blue)==g.base_attack(red))
 g.difficulty='hard';g.reset();assert(g.difficulty=='hard')
 print('DIFFICULTY PASS: default easy, timed launches and reinforcement gaps in all modes, army limits, training delay, equal stats, restart preserves difficulty')
 quit()
