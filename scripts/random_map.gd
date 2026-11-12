# Symmetric strategic maps with protected expansion pads and independent seed RNG.
extends RefCounted
var g
var expansions=[]
var home_position=Vector2(380,990)
func _init(game):g=game
func mirror(p):return Vector2(g.WORLD.x-p.x,p.y)
func apply(seed_value):
 var rng=RandomNumberGenerator.new();rng.seed=seed_value
 var sx=g.WORLD.x/2400.0;var sy=g.WORLD.y/1400.0
 g.map_variant=int(seed_value%3);g.map_style=['river','three_bridges','plains'][g.map_variant]
 var main=rng.randf_range(610,790)*sy;var north=rng.randf_range(240,370)*sy
 g.CROSSINGS=[Vector2(main-80,main+80),Vector2(north-70,north+70)]
 # Three-bridge maps add a southern crossing; two-bridge maps reward longer flank routes.
 if g.map_style=='three_bridges':
  var south=rng.randf_range(1100,1190)*sy;g.CROSSINGS.append(Vector2(south-70,south+70))
 var home_y=g.WORLD.y*rng.randf_range(0.37,0.53);var home_x=rng.randf_range(360,460) if sx>1 else 360.0
 home_position=Vector2(home_x,home_y)
 g.cam=Vector2(0,maxf(0,home_y-380))
 for b in g.buildings:
  if b.kind=='Castle':
   b.p=Vector2(home_x if b.team==0 else g.WORLD.x-home_x,home_y);b.goal=b.p;b.rally=b.p+Vector2(110 if b.team==0 else -110,100)
 for team in range(2):
  var workers=g.units.filter(func(u):return u.team==team and u.kind=='Pawn')
  for i in range(workers.size()):
   var p=Vector2(home_x-80+i*48,home_y+120);workers[i].p=p if team==0 else mirror(p);workers[i].goal=workers[i].p
 g.resources.clear();expansions=[]
 var mine_offsets=[Vector2(-190,80),Vector2(-150,270),Vector2(50,320)]
 var mine_offset=mine_offsets[rng.randi_range(0,2)]+Vector2(rng.randf_range(-20,20),rng.randf_range(-20,20))
 add_pair('gold',home_position+mine_offset,1200,'HOME')
 # Two natural expansions, one remote safer pocket, two exposed rich mines per side.
 for spec in [
  [Vector2(540,360),2200,'NATURAL'],[Vector2(650,930),2200,'NATURAL'],
  [Vector2(210,1160),3000,'REMOTE'],[Vector2(995,270),4000,'RICH'],[Vector2(995,1080),4000,'RICH']]:
  var p=Vector2(spec[0].x*sx+rng.randf_range(-90,90),spec[0].y*sy+rng.randf_range(-115,115))
  var camp=p+Vector2(140 if p.x<400 else -140,80)
  add_pair('gold',p,spec[1],spec[2])
  for team in range(2):expansions.append({'team':team,'p':p if team==0 else mirror(p),'camp':camp if team==0 else mirror(camp),'zone':spec[2]})
 # Starter lumber and expansion lumber share identical quantities on both sides.
 var forest_center=home_position+Vector2(rng.randf_range(-100,130),-rng.randf_range(310,390))
 for i in range(8):
  var p=forest_center+Vector2((i%4-1.5)*65,int(i/4)*65)+Vector2(rng.randf_range(-9,9),rng.randf_range(-9,9))
  add_pair('wood',p,350)
 for site in expansions:
  if site.team!=0:continue
  for i in range(4):
   var p=site.p+Vector2(-90+i*55,-120)
   if p.x>110 and p.x<g.WORLD.x/2-120:add_pair('wood',p,350)
 for forest in range(24):
  var center=Vector2(rng.randf_range(140,g.WORLD.x/2-180),rng.randf_range(170,g.WORLD.y-180))
  for tree in range(6):
   var p=center+Vector2(rng.randf_range(-110,110),rng.randf_range(-100,100))
   if valid_tree(p,home_y):add_pair('wood',p,350)
 g.nav_dirty=true
func add_pair(kind,p,amount,zone=''):
 for pos in [p,mirror(p)]:
  var r={'kind':kind,'p':pos,'amount':amount}
  if zone!='':r['zone']=zone
  g.resources.append(r)
func valid_tree(p,home_y):
 if p.x<120 or p.x>g.WORLD.x/2-150 or p.y<155 or p.y>g.WORLD.y-150:return false
 if Rect2(170,home_y-240,700,540).has_point(p):return false
 if p.x>g.WORLD.x/2-470 and g.CROSSINGS.any(func(span):return p.y>span.x-100 and p.y<span.y+100):return false
 if expansions.any(func(site):return site.team==0 and (site.camp.distance_to(p)<135 or site.p.distance_to(p)<110)):return false
 if g.resources.any(func(r):return r.p.distance_to(p)<70):return false
 return true
func route_centers():return g.CROSSINGS.map(func(span):return (span.x+span.y)/2.0)
