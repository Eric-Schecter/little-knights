extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.map_style='plains';g.buildings.clear();g.units.clear();g.resources.clear();g.nav_dirty=true
 var worker=g.entity('Pawn',Vector2(350,650));g.units=[worker];g.wood=9999
 var house=g.entity('House1',Vector2(500,500));g.buildings=[house]
 assert(g.economy.placement_reason('House1',Vector2(602,500),[worker])=='')
 assert(g.economy.placement_reason('House1',Vector2(590,500),[worker])=='Blocked by another building.')
 assert(g.economy.placement_reason('House1',Vector2(500,558),[worker])=='')
 assert(not g.walkable(Vector2(540,500)) and g.walkable(Vector2(550,500)))
 var other=g.entity('House1',Vector2(640,500));g.buildings.append(other);g.nav_dirty=true;g.rebuild_nav()
 assert(g.segment_clear(Vector2(570,400),Vector2(570,600)),'A visible 52px lane must remain navigable')
 assert(not g.segment_clear(Vector2(500,400),Vector2(500,600)),'Cannot walk through foundations')
 for kind in ['House1','Tower','Barracks','Smith','Workshop','Depot']:
  var b=g.entity(kind,Vector2(800,700));assert(g.footprint(b)==g.building_half_size(kind))
 print('BUILDING SPACING PASS: compact placement, overlap rejection, visual footprint consistency, lane traversal, solid foundations')
 quit()
