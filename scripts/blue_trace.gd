extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false)
 var driver=load('res://scripts/match_driver.gd').new(g)
 var changes=0
 for frame in range(10500):
  driver.tick(1.0/30)
  var blue=g.units.filter(func(u):return u.team==0 and u.kind!='Pawn')
  var before=blue.map(func(u):return {'p':u.p,'target':u.target,'goal':u.goal})
  g._process(1.0/30)
  for i in range(blue.size()):
   var u=blue[i]
   if before[i].target!=null and u.target==null and u.p.x>1100 and u.goal.x<u.p.x-100 and changes<8:
    print('BLUE TURNBACK time=',g.time,' position=',u.p,' mode=',u.mode,' formation=',u.formation,' retained_goal=',u.goal,' old_target_hp=',before[i].target.hp);changes+=1
 print('TRACE END turns=',changes,' assaults=',driver.assaults);quit()
