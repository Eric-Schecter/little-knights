extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.paused=false
 for kind in g.NAMES:
  var stream=load('res://assets/audio/knights-mix/select_'+kind+'.wav')
  assert(stream!=null and stream.get_length()>0)
 var worker=g.entity('Pawn',Vector2(500,500));var knight=g.entity('Cavalry',Vector2(550,500))
 g.units=[worker,knight];g.selected=[worker,knight,worker]
 g.selection_tools.selected_sound();assert(g.selection_tools.replies==['Pawn','Cavalry'])
 var home=g.entity('Castle',Vector2(700,500));g.selected=[home];g.selection_tools.selected_sound();assert(g.selection_tools.replies==['Castle'])
 var bank=g.sfx.BANK
 assert(bank.wood!=bank.mine and bank.build!=bank.wood and bank.repair!=bank.build)
 for kind in ['wood','mine','build','repair']:assert(g.sfx.play(kind))
 print('INTERACTION AUDIO PASS: all types load, mixed selection deduplicates, buildings respond, four work sounds differ')
 quit()
