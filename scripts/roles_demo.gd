extends RefCounted
var g
var elapsed=0.0
var phase=0
var banner
var blue=[]
var red=[]
func _init(game):g=game
func add(kind,p,team):
 var u=g.entity(kind,p,team)
 if kind=='Tower':g.buildings.append(u)
 else:g.units.append(u)
 if team==0:blue.append(u)
 else:red.append(u)
 return u
func scene(index):
 g.units.clear();g.buildings.clear();g.resources.clear();g.selected.clear();g.shots.clear();g.effects.clear();g.formations.clear();g.nav_dirty=true;g.outcome='';g.time=0;g.cam=Vector2(0,80)
 blue=[];red=[]
 if index<2:
  if index==0:
   for i in range(4):add('Archer',Vector2(440,360+i*65),0)
  else:
   for y in [410,510]:add('Warrior',Vector2(540,y),0);add('Archer',Vector2(420,y),0)
  for y in [380,460,540]:add('Warrior',Vector2(770,y),1)
  for u in blue:g.issue_order([u],Vector2(800,u.p.y),null,'attack_move')
  for u in red:g.issue_order([u],Vector2(400,u.p.y),null,'attack_move')
 else:
  for y in [330,650]:add('Tower',Vector2(800,y),1)
  for i in range(3):
   var sword=add('Warrior',Vector2(430-i*25,300+i*30),0)
   var archer=add('Archer',Vector2(430-i*25,620+i*30),0)
   g.issue_order([sword],red[0].p,red[0]);g.issue_order([archer],red[1].p,red[1])
 g.selected=blue.duplicate();g.refresh_commands()
func setup():
 banner=g.label_at('',Vector2(260,100),22)
 scene(0)
func tick():
 elapsed+=1.0/30
 if elapsed>=20 and phase==0:phase=1;scene(1)
 if elapsed>=40 and phase==1:phase=2;scene(2)
 var title=['01 / Exposed archers vs swordsmen','02 / Swordsmen protect the archers','03 / Towers: melee assault above, arrows below'][phase]
 banner.text=title
 g.stats.text='COMBAT LAB    /    Normal combat rules'
 g.details.text=['4 ARCHERS\nvs 3 swordsmen\nExposed ranged units','2 SWORDS + 2 ARCHERS\nvs 3 swordsmen\nFront line and ranged support','3 SWORDS / 3 ARCHERS\nvs identical towers\nCompare structure damage'][phase]
 g.message.text='ROLE TEST | Blue alive: %d | Red alive: %d | Equal unit counts in tests 1 and 2'%[blue.filter(func(u):return u.hp>0).size(),red.filter(func(u):return u.hp>0).size()]
 if phase==2:g.message.text='TOWER TEST | vs swords: %d HP | vs archers: %d HP'%[max(0,red[0].hp),max(0,red[1].hp)]
 if elapsed>60:g.get_tree().quit()
