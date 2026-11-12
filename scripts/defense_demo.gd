extends RefCounted
var g
var total=0.0
var phase=0
var miner
var intruders=[]
var banner
func _init(game):g=game
func soldier(kind,p,team):
 var u=g.entity(kind,p,team);u.mode='stop';g.units.append(u);return u
func scene(remote):
 g.reset();g.enemy_money=Vector2i.ZERO;g.units.clear();g.resources.clear();g.cam=Vector2(1000,250);intruders=[]
 var home=g.buildings[1]
 for i in range(4):soldier('Warrior' if i<3 else 'Archer',Vector2(1910+i*32,850),1)
 var patrol=soldier('Warrior',Vector2(1450,700),1)
 g.opponent.send_squad([patrol],false)
 var resource={'kind':'gold','p':Vector2(1470,410) if remote else Vector2(2200,970),'amount':400}
 g.resources.append(resource)
 miner=soldier('Pawn',resource.p+Vector2(0,30),1);g.issue_order([miner],resource.p,resource)
 if remote:
  g.cam=Vector2(1000,100)
  intruders.append(soldier('Warrior',Vector2(1370,410),0))
 else:
  for i in range(3):intruders.append(soldier('Warrior',Vector2(1720,650+i*32),0))
 for u in intruders:g.issue_order([u],miner.p if remote else home.p,miner if remote else home)
func setup():
 scene(false);banner=g.label_at('',Vector2(255,95),22)
func tick():
 total+=1.0/30
 if total>19 and phase==0:phase=1;scene(true)
 banner.text='01 / Base alarm: guards engage and expedition recalls' if phase==0 else '02 / Mine raid: workers flee, soldiers respond'
 g.message.text='AI DEFENSE | '+g.opponent.state+' | Recalled %d | Evacuated %d'%[g.opponent.defense.recalls,g.opponent.defense.evacuations]
 if total>43:g.get_tree().quit()
