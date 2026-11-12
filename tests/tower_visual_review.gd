extends SceneTree
func _initialize():call_deferred('run')
func run():
 DirAccess.make_dir_recursive_absolute("res://captures")
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.paused=false;g.ai_enabled=false;g.cam=Vector2.ZERO
 g.units.clear();g.buildings.clear();g.resources.clear();g.fog.observer=true
 for team in range(2):
  for col in range(3):
   var b=g.entity('Tower',Vector2(420+col*230,370+team*240),team)
   if col>0:b['tower_branch']=['arrow','cannon'][col-1];b['tower_level']=1
   g.buildings.append(b)
 g.selected=[g.buildings[0]];g.refresh_commands()
 g.fog.update();g.fog.animate(1,true);g.queue_redraw()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png('res://captures/tower-branches-review.png')
 print('TOWER VISUAL: base / arrow / cannon, blue / red; branch icons shown')
 quit()
