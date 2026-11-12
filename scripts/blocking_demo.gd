extends RefCounted
var g
var army=[]
var guards=[]
var phase=0
var castle
var banner
func _init(game):g=game
func setup():
 g.ai_enabled=false;g.units.clear();g.buildings.clear();g.resources.clear();g.nav_dirty=true;g.cam=Vector2(200,100)
 castle=g.entity('Castle',Vector2(990,490),1);g.buildings.append(castle)
 for i in range(6):
  var a=g.entity('Warrior',Vector2(540+(i%2)*42,430+int(i/2)*42));a.mode='stop';g.units.append(a);army.append(a)
 for i in range(11):
  var b=g.entity('Warrior',Vector2(850,340+i*24),1);b.mode='stop';g.units.append(b);guards.append(b)
 g.selected=army.duplicate();g.refresh_commands();banner=g.label_at('',Vector2(260,100),21)
 g.issue_order(army,castle.p,castle)
func tick():
 g.stats.text='BLOCKING REVIEW    /    Normal speed'
 banner.text='01 / Focus base: enemy bodies stop the approach' if phase==0 else ('02 / New order: fight the defenders' if phase==1 else '03 / Retreat: orders remain responsive')
 g.message.text='Contact test: defenders initially hold still to isolate blocking; no collision damage'
 if g.time>9 and phase==0:
  phase=1
  g.issue_order(army,Vector2(900,490),null,'attack_move')
  for u in guards:u.mode='guard'
 if g.time>19 and phase==1:
  phase=2;g.issue_order(army.filter(func(u):return u.hp>0),Vector2(550,490),null,'move')
 if g.time>27:
  print('BLOCKING VIDEO castle_hp=',castle.hp,' survivors=',army.filter(func(u):return u.hp>0).size())
  g.get_tree().quit()
