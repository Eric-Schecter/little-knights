extends RefCounted
var g
var elapsed=0.0
var phase=0
var banner
var squad=[]
func _init(game):g=game
func setup():
 g.reset();g.ai_enabled=false;g.units.clear();g.buildings.clear();g.resources.clear();g.nav_dirty=true
 g.cam=Vector2(150,160)
 for i in range(2):
  var u=g.entity('Warrior',Vector2(500+i*20,500));u.goal=Vector2(600,500);u.mode='move';g.units.append(u);squad.append(u)
 g.selected=squad.duplicate();g.fog.reset()
 banner=g.label_at('01 / Shared destination: arrive and rest',Vector2(260,100),22)
func tick():
 elapsed+=1.0/30
 if elapsed>8 and phase==0:
  phase=1;g.issue_order(squad,Vector2(960,510),null,'move');banner.text='02 / Scout forward: soft reveal and fading vision'
 if elapsed>15 and phase==1:
  phase=2;g.issue_order(squad,Vector2(500,510),null,'move')
 if elapsed>23 and phase==2:
  phase=3;g.reset();g.units.clear();g.resources.clear();g.ai_enabled=false;g.cam=Vector2(1000,300)
  squad.clear()
  for i in range(3):
   var u=g.entity('Warrior',Vector2(1580,650+i*42),1);u.mode='stop';g.units.append(u);squad.append(u)
  for i in range(8):
   var u=g.entity('Warrior',Vector2(1390+(i%2)*35,610+int(i/2)*38));u.mode='stop';g.units.append(u)
  var scout=g.entity('Pawn',Vector2(1870,1030));scout.mode='stop';g.units.append(scout)
  g.fog.reset();g.selected=[]
  banner.text='03 / Red 3 vs Blue 8: retreat through an open route'
 if elapsed>32 and phase==3:
  phase=4
  var raiders=g.units.filter(func(u):return u.team==0 and u.kind=='Warrior')
  var home=g.buildings.filter(func(b):return b.team==1 and b.kind=='Castle')[0]
  for i in range(raiders.size()):raiders[i].p=Vector2(1860+(i%2)*40,660+int(i/2)*40)
  g.fog.update();g.issue_order(raiders,home.p,home,'attack')
  banner.text='04 / Base emergency: red cancels retreat and fights'
 if phase>=3:
  g.opponent.retreat.tick(1.0/30)
  if phase==4:g.opponent.defense.tick(1.0/30)
 g.stats.text='MOVEMENT / FOG / RETREAT     Normal speed'
 g.message.text='Staged scenario | Emergency: %s | Red retreats: %d | Moving: %d / %d'%[str(g.opponent.retreat.emergency),g.opponent.retreat.retreats,squad.filter(func(u):return u.moving).size(),squad.size()]
 if elapsed>44:g.get_tree().quit()
