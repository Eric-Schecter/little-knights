extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false)
 var driver=load('res://scripts/match_driver.gd').new(g)
 for i in range(9000):
  driver.tick(0.1);g._process(0.1)
  if i%600==0:print('SUPPLY PROGRESS ',int(g.time),' score=',g.supply.scores,' army=',g.units.filter(func(u):return u.kind!='Pawn').size(),' owner=',g.supply.points[0].owner)
  if g.outcome!='':break
 print('SUPPLY MATCH ',driver.report())
 quit()
