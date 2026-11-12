extends RefCounted
var g
var elapsed=0.0
var phase=0
var ended=-1.0
var attack_sent=false
func _init(game):g=game
func setup():
 g.ai_enabled=false;g.reset();g.ai_enabled=false;g.cam=Vector2(0,80)
 g.resources.clear()
 var blue=g.buildings[0];var red=g.buildings[1]
 blue.p=Vector2(350,500);red.p=Vector2(900,500)
 # Short review fixture; attacks and all economy events still use normal rules.
 blue.hp=40;red.hp=40
 for team in range(2):
  var home=blue if team==0 else red
  home.rally=home.p+Vector2(-90,180)
  g.buildings.append(g.entity('House1',Vector2(200 if team==0 else 950,300),team))
  var barracks=g.entity('Barracks',Vector2(250 if team==0 else 900,760),team)
  barracks.rally=Vector2(430 if team==0 else 840,720);g.buildings.append(barracks)
  var workers=g.units.filter(func(u):return u.team==team)
  for i in range(workers.size()):workers[i].p=Vector2(260 if team==0 else 830,580)+Vector2(i*30,0);workers[i].goal=workers[i].p
  var r={'kind':'gold' if team==0 else 'wood','p':Vector2(210 if team==0 else 1010,650),'amount':500}
  g.resources.append(r);g.issue_order([workers[0],workers[1]],r.p,r)
  g.train('Pawn',home);g.train('Warrior',barracks);g.train('Archer',barracks)
 g.nav_dirty=true;attack_sent=false;ended=-1
func tick():
 elapsed+=1.0/30
 if phase in [0,4] and g.outcome=='' and g.time>18 and not attack_sent:
  var team=0 if phase==0 else 1
  var army=g.units.filter(func(u):return u.team==team and u.kind!='Pawn')
  var target=g.buildings.filter(func(b):return b.kind=='Castle' and b.team!=team)[0]
  g.issue_order(army,target.p,target);attack_sent=true
 if g.outcome!='' and ended<0:ended=elapsed
 if phase==0 and ended>=0 and elapsed-ended>6:
  for child in g.match_results.overlay.get_children():
   if child is Button and child.text=='Review battlefield':child.pressed.emit()
  phase=1;ended=elapsed
 elif phase==1 and elapsed-ended>2:g.match_results.reopen.pressed.emit();phase=2;ended=elapsed
 elif phase==2 and elapsed-ended>2:g.match_results.replay.pressed.emit();phase=3;ended=elapsed
 elif phase==3 and elapsed-ended>3:phase=4;setup()
 elif phase==4 and ended>=0 and elapsed-ended>6:g.match_results.replay.pressed.emit();phase=5;ended=elapsed
 elif phase==5 and elapsed-ended>3:g.get_tree().quit()
 if g.outcome=='':g.message.text='RESULTS REVIEW | Fresh match: counters cleared, normal starting resources' if phase in [3,5] else 'RESULTS REVIEW | Short fixture: 40 HP bases | Real collection, training and combat'
