extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.paused=false;g.gold=0;g.wood=0
 var worker=g.units.filter(func(u):return u.kind=='Pawn' and u.team==0)[0]
 g.selected=[worker];g.refresh_commands()
 assert(g.commands.get_children().slice(1).all(func(b):return b.disabled))
 var button=g.commands.get_child(1)
 load('res://scripts/button_feedback.gd').animate(button,Color.WHITE)
 assert(button.self_modulate.r<.5 and button.disabled)
 g.wood=1000;g.icon_hud.update_training_buttons();assert(not button.disabled)
 for kind in ['Smith','Tower']:
  var building=g.entity(kind,Vector2(500,500));g.buildings.append(building);g.selected=[building];g.gold=0;g.wood=0;g.refresh_commands()
  assert(g.commands.get_children().all(func(b):return b.disabled))
  g.gold=1000;g.wood=1000;g.icon_hud.update_training_buttons()
  assert(g.commands.get_children().all(func(b):return not b.disabled))
 print('PURCHASE BUTTONS PASS: construction/research/tower affordability, live recovery and disabled hover styling')
 quit()
