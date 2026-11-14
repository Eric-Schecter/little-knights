extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.map_style='plains';g.units.clear();g.buildings.clear();g.resources.clear();g.nav_dirty=true;g.rebuild_nav()
 for i in range(35):g.buildings.append(g.entity('House1',Vector2(300+(i%10)*240,300+int(i/10)*300)))
 g.nav_dirty=true;g.rebuild_nav()
 var b=g.entity('Barracks',Vector2(980,950));g.buildings.append(b)
 var affected=g.entity('Warrior',Vector2(900,1100));affected.path=PackedVector2Array([b.p])
 var distant=g.entity('Warrior',Vector2(1500,1100));distant.path=PackedVector2Array([Vector2(1500,1200)])
 g.units=[affected,distant]
 var start=Time.get_ticks_usec();g.invalidate_building_nav(b);g.rebuild_nav();var add_ms=(Time.get_ticks_usec()-start)/1000.0
 assert(affected.path.is_empty() and not distant.path.is_empty(),'Only paths crossing changed footprint should be invalidated')
 assert(g.nav.is_point_solid(Vector2i(b.p/20)))
 var snapshot=[]
 for y in range(g.nav.region.size.y):
  for x in range(g.nav.region.size.x):snapshot.append(g.nav.is_point_solid(Vector2i(x,y)))
 start=Time.get_ticks_usec();g.nav_dirty=true;g.rebuild_nav();var full_ms=(Time.get_ticks_usec()-start)/1000.0
 var index=0
 for y in range(g.nav.region.size.y):
  for x in range(g.nav.region.size.x):
   assert(snapshot[index]==g.nav.is_point_solid(Vector2i(x,y)));index+=1
 start=Time.get_ticks_usec();g.damage(b,99999);g.rebuild_nav();var remove_ms=(Time.get_ticks_usec()-start)/1000.0
 assert(not g.nav.is_point_solid(Vector2i(b.p/20)))
 assert(add_ms<full_ms and remove_ms<full_ms)
 print('INCREMENTAL NAV PASS: exact full-grid equivalence, destroyed footprint reopened; add %.2f ms, remove %.2f ms, full %.2f ms'%[add_ms,remove_ms,full_ms])
 quit()
