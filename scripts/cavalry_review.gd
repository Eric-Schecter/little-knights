# Staged normal-speed review; one starting rider, one normally paid/trained rider.
extends SceneTree
var g
var elapsed=0.0
var stage=0
var rider
func _initialize():call_deferred('setup')
func setup():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.ai_enabled=false;g.gold=600;g.wood=400;g.cam=Vector2(0,200)
 g.resources=g.resources.filter(func(r):return r.p.x<500 or r.p.y<400)
 var barracks=g.entity('Barracks',Vector2(600,450));barracks.rally=Vector2(790,680)
 g.buildings.append_array([barracks,g.entity('Smith',Vector2(820,450)),g.entity('House1',Vector2(440,900)),g.entity('House1',Vector2(650,900))])
 rider=g.entity('Cavalry',Vector2(500,680));rider.mode='stop';g.units.append(rider)
 for i in range(3):
  var enemy=g.entity('Archer' if i<2 else 'Spearman',Vector2(1480+i*50,680),1);enemy.mode='guard';g.units.append(enemy)
 g.nav_dirty=true;g.train('Cavalry',barracks);g.selected=[barracks];g.refresh_commands()
func _process(dt):
 if g==null:return false
 elapsed+=dt
 if elapsed>3 and stage==0:
  stage=1;g.selected=[rider];g.refresh_commands();g.issue_order([rider],Vector2(860,650),null,'move')
 if elapsed>15 and stage==1:
  stage=2
  var squad=g.units.filter(func(u):return u.team==0 and u.kind=='Cavalry');g.selected=squad;g.refresh_commands();g.issue_order(squad,Vector2(1650,680),null,'attack_move')
 if elapsed>18:
  var living=g.units.filter(func(u):return u.team==0 and u.kind=='Cavalry' and u.hp>0)
  if not living.is_empty():g.cam=g.cam.lerp((living[0].p-Vector2(600,360)).clamp(Vector2(0,-72),Vector2(1080,740)),0.05)
 if elapsed>36:
  print('CAVALRY REVIEW trained=',g.trained,' attacks=',g.combat_events.filter(func(e):return e.unit=='Cavalry').size())
  quit()
 return false
