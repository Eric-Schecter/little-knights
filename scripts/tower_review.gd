extends SceneTree
var g
var towers=[]
var elapsed=0.0
var phase=0
var branches=['arrow','cannon']
func _initialize():call_deferred('setup')
func setup():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.ai_enabled=false;g.supply.enabled=false
 g.units=[];g.resources=[];g.gold=1000;g.wood=1000;g.cam=Vector2(0,100)
 for i in range(2):
  var t=g.entity('Tower',Vector2(440+i*500,620));g.buildings.append(t);towers.append(t)
  g.label_at(g.tower_upgrades.NAMES[branches[i]],Vector2(360+i*500,170),22)
 g.nav_dirty=true;g.selected=[towers[0]];g.refresh_commands()
func _process(dt):
 if g==null:return false
 elapsed+=dt
 if elapsed>2 and phase==0:
  phase=1
  for i in range(2):assert(g.tower_upgrades.upgrade(towers[i],branches[i]))
 if elapsed>19 and phase==1:
  phase=2
  for i in range(2):
   for j in range(4):
    var enemy=g.entity('Warrior' if j<3 else 'Archer',Vector2(400+i*500+j*24,300),1);g.units.append(enemy)
    g.issue_order([enemy],towers[i].p,null,'attack_move')
 g.selected=[towers[int(elapsed/7)%2]]
 if elapsed>38:
  print('TWO TOWER REVIEW attacks=',g.combat_events.size(),' hp=',towers.map(func(t):return t.hp));quit()
 g.queue_redraw();RenderingServer.force_draw(false)
 return false
