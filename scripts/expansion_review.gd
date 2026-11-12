# Staged normal-speed content review; standard paid research and training.
extends SceneTree
var g
var elapsed=0.0
var stage=0
var forge
var factory
var barracks
var target
func _initialize():call_deferred('setup')
func setup():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.ai_enabled=false;g.gold=1200;g.wood=1200;g.cam=Vector2(0,180)
 g.resources=g.resources.filter(func(r):return r.p.distance_to(Vector2(700,500))>260 and r.p.distance_to(Vector2(800,770))>220)
 forge=g.entity('Smith',Vector2(610,460));factory=g.entity('Workshop',Vector2(830,460));barracks=g.entity('Barracks',Vector2(580,850))
 g.buildings.append_array([forge,factory,barracks,g.entity('House1',Vector2(390,910)),g.entity('House1',Vector2(400,320))])
 target=g.entity('Tower',Vector2(1000,790),1);g.buildings.append(target)
 g.nav_dirty=true;factory.rally=Vector2(680,720);barracks.rally=Vector2(650,850)
 g.technology.research(forge,'attack');g.train('Catapult',factory);g.train('Spearman',barracks);g.train('Spearman',barracks)
 g.selected=[forge];g.refresh_commands()
func _process(dt):
 if g==null:return false
 elapsed+=dt
 if elapsed>8 and stage==0:stage=1;g.selected=[factory];g.refresh_commands()
 if elapsed>21 and stage==1:
  stage=2;g.selected=[forge];g.refresh_commands();g.technology.research(forge,'armor')
 if elapsed>25 and stage==2:
  stage=3
  var army=g.units.filter(func(u):return u.team==0 and u.kind in ['Spearman','Catapult'])
  g.selected=army;g.refresh_commands();g.issue_order(army,target.p,target)
 if elapsed>32 and stage==3:
  stage=4
  var siege=g.units.filter(func(u):return u.team==0 and u.kind=='Catapult')
  if not siege.is_empty():g.selected=[siege[0]];g.refresh_commands()
 if elapsed>46:
  print('EXPANSION REVIEW research=',g.technology.levels,' siege shots=',g.combat_events.filter(func(e):return e.unit=='Catapult').size(),' target HP=',target.hp)
  quit()
 return false
