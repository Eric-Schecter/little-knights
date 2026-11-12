extends RefCounted
var g
var squad=[]
var elapsed=0.0
var phase=0
var previous=[]
var banner
func _init(game):g=game
func setup():
 g.reset();g.ai_enabled=false;g.units.clear();g.resources.clear();g.cam=Vector2(1000,300);g.time=6
 for i in range(6):
  var u=g.entity('Warrior',Vector2(1700+(i%3)*45,600+int(i/3)*45),1);g.units.append(u);squad.append(u)
 g.opponent.defense.defenders=squad.duplicate();g.opponent.defense.active=true;g.opponent.defense.last_seen=-10
 g.opponent.defense.tick(0.3)
 g.selected=squad.duplicate();g.refresh_commands();previous=squad.map(func(u):return u.p)
 banner=g.label_at('',Vector2(255,95),22)
func tick():
 elapsed+=1.0/30
 if elapsed>13 and phase==0:phase=1;g.issue_order(squad,Vector2(1600,900),null,'move')
 if elapsed>22:phase=2
 var drift=0.0
 for i in range(squad.size()):drift=max(drift,squad[i].p.distance_to(previous[i]))
 previous=squad.map(func(u):return u.p)
 g.stats.text='ARRIVAL REVIEW    /    Normal speed'
 banner.text=['01 / Return to formation, then hold position','02 / New move order: immediate response','03 / Arrived: no creeping or walking in place'][phase]
 g.message.text='ARRIVAL TEST | Moving %d / 6 | Largest frame displacement %.3f px'%[squad.filter(func(u):return u.moving).size(),drift]
 if elapsed>29:g.get_tree().quit()
