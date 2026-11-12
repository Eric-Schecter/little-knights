extends RefCounted
const CELL=20
var COLS=120
var ROWS=70
var g
var observer='--observe-match' in OS.get_cmdline_user_args()
var visible=[{},{}]
var explored=[{},{}]
var clock=0.0
var mask
var mask_texture
var alpha=PackedFloat32Array()
var coverage=PackedFloat32Array()
var explored_coverage=PackedFloat32Array()
var world_view
var mini_view
func _init(game):
 g=game
 COLS=int(g.WORLD.x/CELL);ROWS=int(g.WORLD.y/CELL);mask=Image.create(COLS,ROWS,false,Image.FORMAT_RGBAH)
 alpha.resize(COLS*ROWS);alpha.fill(1.0)
 coverage.resize(COLS*ROWS);explored_coverage.resize(COLS*ROWS)
 mask.fill(Color(0,0,0,1));mask_texture=ImageTexture.create_from_image(mask)
 var material=ShaderMaterial.new();material.shader=load('res://scripts/fog_soft.gdshader');material.set_shader_parameter('mask_texture',mask_texture)
 var clip=Control.new();clip.position=Vector2(0,72);clip.size=Vector2(1440,660);clip.clip_contents=true;clip.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.add_child(clip)
 world_view=TextureRect.new();world_view.texture=mask_texture;world_view.material=material;world_view.size=g.WORLD;world_view.mouse_filter=Control.MOUSE_FILTER_IGNORE;clip.add_child(world_view)
 mini_view=TextureRect.new();mini_view.texture=mask_texture;mini_view.material=material;mini_view.position=Vector2(23,755);mini_view.size=Vector2(200,125);mini_view.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.add_child(mini_view)
func animate(dt,instant=false):
 world_view.visible=not observer;mini_view.visible=not observer
 for y in range(ROWS):
  for x in range(COLS):
   var k=Vector2i(x,y);var i=y*COLS+x
   var target=lerp(1.0,0.48,explored_coverage[i])*(1.0-coverage[i])
   alpha[i]=target if instant else move_toward(alpha[i],target,dt/(0.22 if target<alpha[i] else 0.45))
   mask.set_pixel(x,y,Color(0,0,0,alpha[i]))
 mask_texture.update(mask)
 world_view.position=-g.cam-Vector2(0,72)
func reset():
 visible=[{},{}];explored=[{},{}];clock=0
 explored_coverage.fill(0.0)
 update();animate(0,true)
func key(p):return Vector2i(floor(p.x/CELL),floor(p.y/CELL))
func sees(team,p):return visible[team].has(key(p))
func render_sees(team,p):return observer or sees(team,p)
func render_known(team,p):return observer or known(team,p)
func known(team,p):return explored[team].has(key(p))
func tick(dt):
 clock-=dt
 if clock<=0:clock=0.1;update()
 animate(dt)
func update():
 visible=[{},{}];coverage.fill(0.0)
 for e in g.units+g.buildings:
  if e.hp<=0:continue
  var radius=300 if e.kind=='Pawn' else 340
  if g.contains_entity(g.buildings,e):radius=400 if e.kind in ['Castle','Tower'] and e.progress>=1 else 260
  if e.kind=='Tower' and e.progress>=1:radius=g.tower_upgrades.vision(e)
  var c=key(e.p);var n=int(ceil((radius+25)/float(CELL)))
  for y in range(max(0,c.y-n),min(ROWS,c.y+n+1)):
   for x in range(max(0,c.x-n),min(COLS,c.x+n+1)):
    var distance=(Vector2(x,y)*CELL+Vector2.ONE*CELL/2).distance_to(e.p)
    if e.team==0:
     var i=y*COLS+x
     var strength=1.0-smoothstep(radius-20.0,radius+20.0,distance)
     coverage[i]=max(coverage[i],strength)
     explored_coverage[i]=max(explored_coverage[i],strength)
    if distance<=radius:
     var k=Vector2i(x,y);visible[e.team][k]=true;explored[e.team][k]=true
func draw_world():
 # Hide camera overscroll outside the map using the same unexplored color.
 var color=Color(0.07,0.085,0.10)
 for rect in [Rect2(-500,-500,g.WORLD.x+1000,500),Rect2(-500,g.WORLD.y,g.WORLD.x+1000,500),Rect2(-500,0,500,g.WORLD.y),Rect2(g.WORLD.x,0,500,g.WORLD.y)]:g.draw_rect(rect,color)
 world_view.position=-g.cam-Vector2(0,72)
func draw_minimap():pass
