extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false;g.units.clear();g.resources.clear()
 var planner=g.supply.planner;var rally=planner.staging(1);var ours=[]
 for i in range(3):
  var u=g.entity('Warrior',rally+Vector2(i*35,0),1);g.units.append(u);ours.append(u)
 planner.plan(1);assert(planner.launches.is_empty(),'Three reserves must not trickle out')
 var fourth=g.entity('Warrior',rally+Vector2(0,35),1);g.units.append(fourth);ours.append(fourth)
 g.fog.visible[1][g.fog.key(g.supply.points[0].p)]=true
 g.fog.visible[1][g.fog.key(g.supply.points[1].p)]=true
 for p in g.supply.points:
  for i in range(8):
   var enemy=g.entity('Warrior',p.p+Vector2(i*10,0),0);g.units.append(enemy);g.fog.visible[1][g.fog.key(enemy.p)]=true
 planner.plan(1);assert(planner.launches.is_empty(),'Known superior forces block a suicidal attack')
 g.units=ours.duplicate();planner.teams[1].threat=[0.0,0.0]
 planner.plan(1);assert(planner.launches.size()==1 and planner.launches[0].count==4)
 var late=g.entity('Warrior',rally,1);g.units.append(late);planner.plan(1)
 assert(planner.launches.size()==1 and late.mode!='attack_move','One reinforcement waits')
 for i in range(9):
  var enemy=g.entity('Warrior',rally+Vector2(i*12,70),0);g.units.append(enemy);g.fog.visible[1][g.fog.key(enemy.p)]=true
 planner.plan(1);assert(planner.withdrawals==1 and ours.all(func(u):return u.mode=='move'),'Whole group withdraws from overwhelming contact')
 planner.reset();g.units=[late];g.supply.scores=[170.0,0.0];g.supply.points[0].owner=0
 planner.plan(1);assert(planner.launches.is_empty(),'Removed score victory cannot force suicidal emergency attack')
 planner.reset();g.units=[];g.supply.points[0].owner=1
 var assault=[]
 for i in range(6):
  var u=g.entity('Warrior',rally+Vector2(i*25,0),1);g.units.append(u);assault.append(u)
 planner.teams[1].members=assault.duplicate();planner.plan(1)
 assert(planner.teams[1].assault and assault.all(func(u):return u.mode=='attack_move' and u.goal.distance_to(planner.assault_destination(1))<200),'Army advances toward enemy base after securing camp')
 planner.reset();g.supply.scores=[0.0,0.0];g.supply.points[0].owner=0;g.supply.points[1].owner=0
 g.units=[];var front=[]
 for i in range(3):
  var u=g.entity('Warrior',g.supply.points[0].p+Vector2(200,i*25),1);g.units.append(u);front.append(u)
 planner.teams[1].members=front.duplicate()
 for i in range(4):g.units.append(g.entity('Warrior',rally+Vector2(i*25,0),1))
 g.fog.visible[1].clear();planner.teams[1].threat=[6.0,20.0];planner.teams[1].seen=[g.time,g.time]
 planner.plan(1)
 assert(planner.launches.size()==1 and planner.launches[0].count==7,'Uncaptured objective must accept a batch and evaluate combined strength')
 planner.reset();g.units=[];g.opponent.defense.active=true
 var guard=g.entity('Warrior',rally,1);g.units.append(guard);g.opponent.defense.defenders=[guard]
 for i in range(4):g.units.append(g.entity('Warrior',rally+Vector2(i*25,35),1))
 planner.plan(1)
 assert(planner.launches.size()==1 and planner.launches[0].count==4 and not planner.teams[1].members.has(guard),'Local guard stays assigned while field army launches')
 print('ARMY PLAN PASS: batching, known losing fights, late reserves, whole-group withdrawal, defender separation and base assault')
 quit()
