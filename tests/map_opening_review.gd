extends SceneTree
func _initialize():call_deferred('run')
func run():
 DirAccess.make_dir_recursive_absolute("res://captures")
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.ai_enabled=false
 for seed_value in [101,202]:
  g.requested_map_seed=seed_value;g.reset();g.paused=false
  g.fog.update();g.fog.animate(1,true);g.icon_hud.update();g.queue_redraw()
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png('res://captures/map-opening-'+str(seed_value)+'.png')
 quit()
