extends RefCounted
var g
var driver
var elapsed=0.0
var phase=0
var army=[]
var banner
func _init(game):g=game;driver=load('res://scripts/match_driver.gd').new(g)
func setup():
 g.reset();g.units.clear();g.resources.clear();g.ai_enabled=false;g.time=438;g.cam=Vector2(200,250)
 for i in range(12):
  var u=g.entity('Warrior' if i<8 else 'Archer',Vector2(720+(i%3)*46,590+int(i/3)*46));g.units.append(u);army.append(u)
 var bait=g.entity('Warrior',Vector2(980,680),1);bait.hp=800;bait.max=800;bait.goal=Vector2(1700,680);bait.mode='move';g.units.append(bait)
 g.fog.reset();driver.tick(1);g.selected=army.duplicate();g.refresh_commands()
 banner=g.label_at('01 / Local defense: do not chase across the map',Vector2(255,100),22)
func tick():
 elapsed+=1.0/30
 if elapsed>8 and phase==0:
  phase=1;g.time=450;driver.tick(1.1)
  banner.text='02 / Attack order: all 12 soldiers commit together'
 if elapsed>21 and phase==1:
  phase=2
  var raider=g.entity('Warrior',Vector2(800,850),1);raider.mode='stop';g.units.append(raider)
  driver.tick(1.1)
  banner.text='03 / A home threat does not cancel the attack order'
 if phase>0:
  var center=Vector2.ZERO
  for u in army:center+=u.p
  center/=army.size()
  g.cam=g.cam.lerp((center-Vector2(650,360)).clamp(Vector2(0,-72),Vector2(1080,740)),0.04)
 g.stats.text='BLUE ORDERS REVIEW / Normal speed'
 g.message.text='Staged scenario | Committed attackers: %d / 12 | Script assaults: %d'%[army.filter(func(u):return u.get('review_assault',false)).size(),driver.assaults]
 if elapsed>35:g.get_tree().quit()
