extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false)
 var first=-1.0
 for i in range(18000):
  g._process(1.0/30)
  if first<0 and g.opponent.attacks>0:first=g.time;print('FIRST SORTIE ',first)
  if g.outcome!='':break
 print('IDLE RESULT time=',g.time,' result=',g.outcome,' first=',first,' delivered=',g.enemy_gathered,' trained=',g.enemy_trained)
 quit()
