# Original generated atlases; runtime slicing and foot alignment only.
extends RefCounted
var g
var frames={}
var motions={}
var grass
var cloth
var bridge
var shadows_enabled=true
var shadow_pass=false
var ground_stone=StyleBoxFlat.new()
func _init(game):
 g=game
 ground_stone.bg_color=Color(0.60,0.55,0.39,0.78)
 ground_stone.set_corner_radius_all(2)
 var units=source_image('res://assets/knights/units.png')
 var props=source_image('res://assets/knights/buildings.png')
 var materials=source_image('res://assets/knights/terrain.png')
 bridge=extract(source_image('res://assets/knights/bridge.png'),0,0,1,1)
 var half=materials.get_width()/2
 grass=ImageTexture.create_from_image(materials.get_region(Rect2i(0,0,half,materials.get_height())))
 cloth=ImageTexture.create_from_image(materials.get_region(Rect2i(half,0,half,materials.get_height())))
 for row in range(6):
  var prefix=('Blue_' if row<3 else 'Red_')+['Pawn','Warrior','Archer'][row%3]
  var cells=[];var height=0
  for col in range(4):
   var cell=extract(units,col,row,4,6);cells.append(cell);height=max(height,cell.bounds.size.y)
  for cell in cells:cell['scale']=54.0/height
  frames[prefix]=cells
 for row in range(2):
  for col in range(4):
   var key=('Blue_' if row==0 else 'Red_')+['Castle','Barracks','House1','Tower'][col]
   var cell=extract(props,col,row,4,2)
   var target=[Vector2(205,180),Vector2(145,132),Vector2(105,100),Vector2(92,148)][col]
   cell['scale']=min(target.x/cell.bounds.size.x,target.y/cell.bounds.size.y)
   frames[key]=[cell]
 var nature=source_image('res://assets/knights/props.png')
 for i in range(4):
  var cell=extract(nature,i%2,i/2,2,2)
  cell['scale']=[116.0,96.0,50.0,44.0][i]/cell.bounds.size.y
  cell['hit_image']=cell.texture.get_image()
  frames[['Tree3','TreeSmall','Gold Stone 1','Logs'][i]]=[cell]
 # Six-frame role-specific walks and actions; stable scale is based on the walk row.
 for spec in [['Pawn','worker-motion'],['Warrior','knight-motion'],['Archer','crossbow-motion'],['Spearman','spearman-motion'],['Cavalry','cavalry-motion']]:
  var sheet=source_image('res://assets/knights/'+spec[1]+'.png')
  for team in range(2):
   var key=('Blue_' if team==0 else 'Red_')+spec[0]
   var walk=[];var action=[];var height=0.0
   for col in range(6):
    var cell=extract(sheet,col,team*2,6,4);walk.append(cell);height=maxf(height,cell.bounds.size.y)
    action.append(extract(sheet,col,team*2+1,6,4))
   for cell in walk+action:
    cell['scale']=(72.0 if spec[0]=='Cavalry' else 54.0)/height
    cell['anchor']=cell.bounds.get_center().x if spec[0]=='Cavalry' else foot_anchor(cell)
    if spec[0]=='Cavalry':cell['ground_shadow']=make_ground_shadow(cell,key)
   motions[key]={'walk':walk,'action':action}
   if spec[0]=='Cavalry':frames[key]=[action[0]]
 var expansion=source_image('res://assets/knights/expansion.png')
 for row in range(2):
  for col in range(4):
   var kind=['Smith','Workshop','Spearman','Catapult'][col]
   var cell=extract(expansion,col,row,4,2)
   var target=[Vector2(145,145),Vector2(160,140),Vector2(62,60),Vector2(80,65)][col]
   cell['scale']=minf(target.x/cell.bounds.size.x,target.y/cell.bounds.size.y)
   frames[('Blue_' if row==0 else 'Red_')+kind]=[cell]
 var depot=source_image('res://assets/knights/depot.png')
 for team in range(2):
  var cell=extract(depot,team,0,2,1);cell['scale']=minf(125.0/cell.bounds.size.x,105.0/cell.bounds.size.y)
  frames[('Blue_' if team==0 else 'Red_')+'Depot']=[cell]
 var tower_sheet=source_image('res://assets/knights/towers-distinct-v4.png')
 for team in range(2):
  for col in range(2):
   var tile=tower_sheet.get_region(Rect2i(col*int(tower_sheet.get_width()/2),team*int(tower_sheet.get_height()/2),int(tower_sheet.get_width()/2),int(tower_sheet.get_height()/2)))
   var cell=extract(tile,0,0,1,1)
   cell['scale']=minf((110.0 if col==0 else 138.0)/cell.bounds.size.x,(156.0 if col==0 else 140.0)/cell.bounds.size.y)
   frames[('Blue_' if team==0 else 'Red_')+'Tower_'+['arrow','cannon'][col]]=[cell]
 # Cache neutral alpha shadows at display resolution, not colored sprite copies.
 for key in frames:
  for cell in frames[key]:
   cell['ground_shadow']=make_ground_shadow(cell,key)
   if '--contact-review' in OS.get_cmdline_user_args():cell['legacy_shadow']=make_legacy_ground_shadow(cell,key)
func blur_mask(source,radius):
 var w=source.get_width();var h=source.get_height()
 var temp=Image.create(w,h,false,Image.FORMAT_RGBA8)
 var result=Image.create(w,h,false,Image.FORMAT_RGBA8)
 for y in range(h):
  for x in range(w):
   var a=0.0
   for d in range(-radius,radius+1):a+=source.get_pixel(clampi(x+d,0,w-1),y).a
   temp.set_pixel(x,y,Color(1,1,1,a/(radius*2+1)))
 for y in range(h):
  for x in range(w):
   var a=0.0
   for d in range(-radius,radius+1):a+=temp.get_pixel(x,clampi(y+d,0,h-1)).a
   result.set_pixel(x,y,Color(1,1,1,a/(radius*2+1)))
 return result
func make_ground_shadow(cell,key):
 var source=cell.texture.get_image()
 var size=Vector2i(Vector2(cell.bounds.size)*cell.scale)
 var silhouette=source.get_region(cell.bounds)
 silhouette.resize(maxi(1,size.x),maxi(1,size.y),Image.INTERPOLATE_BILINEAR)
 var pad=24;var width=size.x+size.y/3+pad*2;var height=112
 var cast=Image.create(width,height,false,Image.FORMAT_RGBA8)
 var contact=Image.create(width,height,false,Image.FORMAT_RGBA8)
 var unit=key.ends_with('Pawn') or key.ends_with('Warrior') or key.ends_with('Archer') or key.ends_with('Spearman') or key.ends_with('Catapult') or key.ends_with('Cavalry')
 var tree=key in ['Tree3','TreeSmall']
 for x in range(size.x):
  var bottom=-1
  for y in range(size.y):
   if silhouette.get_pixel(x,y).a>0.5:bottom=y
  var touches=bottom>=size.y-int(size.y*(0.24 if tree else 0.28))
  var foot=bottom if touches else size.y-1
  for y in range(size.y):
   var a=silhouette.get_pixel(x,y).a
   if a<0.1:continue
   var elevation=maxi(0,foot-y)
   var sx=pad+x+int(elevation*0.23)
   var sy=40+(foot-size.y+1)+int(elevation*0.18)
   cast.set_pixel(sx,clampi(sy,0,height-1),Color(1,1,1,maxf(cast.get_pixel(sx,clampi(sy,0,height-1)).a,a)))
  # Only low silhouette surfaces touch the floor; roofs/treetops do not.
  if touches:
   var sy=40+bottom-size.y+1
   for dy in range(-1,3):
    contact.set_pixel(pad+x,clampi(sy+dy,0,height-1),Color.WHITE)
 cast=blur_mask(blur_mask(cast,3),2)
 contact=blur_mask(contact,1)
 return {'cast':ImageTexture.create_from_image(cast),'contact':ImageTexture.create_from_image(contact),'offset':Vector2(-size.x/2.0-pad,-40),'size':Vector2(width,height)}

func make_legacy_ground_shadow(cell,key):
 var source=cell.texture.get_image()
 var size=Vector2i(Vector2(cell.bounds.size)*cell.scale)
 var silhouette=source.get_region(cell.bounds)
 silhouette.resize(maxi(1,size.x),maxi(1,size.y),Image.INTERPOLATE_BILINEAR)
 var pad=24;var width=size.x+size.y/3+pad*2;var height=80
 var cast=Image.create(width,height,false,Image.FORMAT_RGBA8)
 var contact=Image.create(width,height,false,Image.FORMAT_RGBA8)
 var unit=key.ends_with('Pawn') or key.ends_with('Warrior') or key.ends_with('Archer') or key.ends_with('Spearman') or key.ends_with('Catapult') or key.ends_with('Cavalry')
 var tree=key in ['Tree3','TreeSmall']
 for x in range(size.x):
  var bottom=-1
  for y in range(size.y):
   var a=silhouette.get_pixel(x,y).a
   if a<0.1:continue
   bottom=y
   var elevation=size.y-1-y
   var sx=pad+x+int(elevation*0.23)
   var sy=24+int(elevation*0.12)
   cast.set_pixel(sx,sy,Color(1,1,1,maxf(cast.get_pixel(sx,sy).a,a)))
  # Only low silhouette surfaces touch the floor; roofs/treetops do not.
  if bottom>=size.y-int(size.y*(0.12 if tree else 0.20)):
   var sy=24+bottom-size.y+1
   for dy in range(-2,3):
    contact.set_pixel(pad+x,clampi(sy+dy,0,height-1),Color.WHITE)
 cast=blur_mask(blur_mask(cast,3),2)
 contact=blur_mask(contact,2 if unit else 3)
 return {'cast':ImageTexture.create_from_image(cast),'contact':ImageTexture.create_from_image(contact),'offset':Vector2(-size.x/2.0-pad,-24),'size':Vector2(width,height)}
func extract(atlas,col,row,cols,rows):
 var width=atlas.get_width()/cols;var height=atlas.get_height()/rows
 var region=Rect2i(col*width,row*height,width,height)
 if cols==2 and rows==2 and row==0:
  var split=720
  region=Rect2i(0 if col==0 else split,0,split if col==0 else atlas.get_width()-split,height)
  width=region.size.x
 var cell=atlas.get_region(region)
 var lo=Vector2i(width,height);var hi=Vector2i.ZERO
 for y in range(height):
  for x in range(width):
   if cell.get_pixel(x,y).a>0.5:lo=lo.min(Vector2i(x,y));hi=hi.max(Vector2i(x,y))
 var bounds=Rect2i(lo,hi-lo+Vector2i.ONE)
 return {'texture':ImageTexture.create_from_image(cell),'bounds':bounds,'size':Vector2(width,height)}
func foot_anchor(cell):
 var im=cell.texture.get_image();var weighted=0.0;var total=0.0
 for y in range(int(cell.bounds.end.y-cell.bounds.size.y*0.18),cell.bounds.end.y):
  for x in range(cell.bounds.position.x,cell.bounds.end.x):
   var alpha=im.get_pixel(x,y).a
   if alpha>0.5:weighted+=x*alpha;total+=alpha
 return weighted/total if total>0 else cell.bounds.get_center().x
func draw_building_selection(b):
 # Ground-plane corner markers, sized to the art, drawn behind the building.
 var width={'Castle':218.0,'Barracks':158.0,'House1':118.0,'Tower':104.0,'Smith':158.0,'Workshop':172.0,'Depot':138.0}.get(b.kind,130.0)
 if b.kind=='Tower':width=building_rect(b).size.x+12
 var center=b.p+Vector2(0,-12)
 var corners=[center+Vector2(-width/2,0),center+Vector2(0,-32),center+Vector2(width/2,0),center+Vector2(0,25)]
 for i in range(4):
  var corner=corners[i]
  var points=PackedVector2Array([corner.lerp(corners[(i+3)%4],0.22),corner,corner.lerp(corners[(i+1)%4],0.22)])
  g.draw_polyline(points,Color(0.12,0.24,0.20,0.28),4.0,true)
  g.draw_polyline(points,Color(0.77,0.88,0.67,0.82),1.6,true)
func draw_unit(u):
 var anim='Run' if u.moving else 'Idle'
 var clock=u.swing_time
 if u.target!=null and clock>=0 and not u.moving:anim='Shoot' if u.kind=='Archer' else 'Attack1'
 if u.kind=='Pawn' and not u.moving and u.work_state in ['Mining','Chopping','Building','Repairing']:
  anim='Work';clock=u.work_clock
 var key=('Blue_' if u.team==0 else 'Red_')+u.kind+'_'+anim
 sprite(key,u.p-Vector2(0,23),0.62,true,u.face,Color.WHITE,clock,u)
func sprite(key,p,scale_factor,animated,flip,mod,anim_clock,actor={}):
 var parts=key.split('_');var base=key;var frame=0;var unit=false
 var anim='Idle'
 if parts.size()==3 and parts[1]!='Tower':
  base=parts[0]+'_'+parts[1];unit=true;anim=parts[2]
 if not frames.has(base):return
 var cell=frames[base][frame]
 var phase=0.0
 if unit and not shadow_pass and not motions.has(base):
  phase=fposmod(actor.get('stride',0.0),1.0) if anim=='Run' else clampf(anim_clock/0.60,0,1)
 if unit and motions.has(base) and (not shadow_pass or base.ends_with('Cavalry')):
  cell=motions[base].action[0]
  if anim=='Run':
   phase=fposmod(actor.get('stride',0.0),1.0)
   cell=motions[base].walk[mini(5,int(phase*6))]
  elif anim in ['Attack1','Shoot','Work']:
   phase=clampf(anim_clock/0.60,0,0.999)
   if anim=='Work':phase=fposmod(anim_clock+0.22,0.55)/0.55
   var pose=0 if phase<0.16 else (1 if phase<0.40 else (2 if phase<0.53 else (3 if phase<0.68 else (4 if phase<0.85 else 5))))
   if base.ends_with('Cavalry'):
    pose=0 if phase<0.16 else (1 if phase<0.30 else (2 if phase<0.40 else (3 if phase<0.68 else (4 if phase<0.85 else 5))))
   cell=motions[base].action[pose]
 var factor=cell.scale
 var ground=p+Vector2(0,23 if unit else (40 if base in ['Tree3','TreeSmall'] else (12 if base=='Gold Stone 1' else 45)))
 if not unit and base=='Gold Stone 1':factor*=scale_factor/0.8
 var anchor=cell.get('anchor',cell.bounds.position.x+cell.bounds.size.x/2.0)
 var offset=Vector2(-anchor,-cell.bounds.end.y)*factor
 if shadow_pass:
  var shadow=cell.ground_shadow
  # Constant world light direction, independent of the soldier's facing.
  g.draw_set_transform(ground-g.cam)
  var rect=Rect2(shadow.offset,shadow.size)
  g.draw_texture_rect(shadow.cast,rect,false,Color(0.12,0.15,0.13,0.20*mod.a))
  g.draw_set_transform(ground-g.cam,0,Vector2(flip,1))
  g.draw_texture_rect(shadow.contact,rect,false,Color(0.10,0.12,0.09,0.68*mod.a))
  g.draw_set_transform(-g.cam)
  return
 if not shadows_enabled:
  g.draw_set_transform(ground-g.cam,0,Vector2(1,0.32))
  g.draw_circle(Vector2.ZERO,17 if unit else min(48,cell.bounds.size.x*factor*0.35),Color(0.13,0.2,0.12,0.16*mod.a))
 var displacement=Vector2.ZERO;var tilt=0.0
 if unit:
  if anim=='Run':displacement.y=-abs(sin(phase*TAU))*0.65
  elif anim in ['Attack1','Work']:
   var strike=sin(clampf((phase-0.20)/0.65,0,1)*PI)
   displacement.x=strike*2.0*flip;tilt=strike*0.025*flip
  var hurt=clampf(actor.get('hurt_time',0.0)/0.16,0,1)
  displacement.x-=hurt*1.4*flip
  if hurt>0:mod=mod.lerp(Color(1,0.83,0.75,mod.a),hurt*0.45)
 if actor.get('kind','')=='Tower':displacement.y+=maxf(0,1-(g.time-actor.get('shot_at',-100.0))/0.18)*(2.5 if actor.get('tower_branch','')=='cannon' else 1.0)
 g.draw_set_transform(ground-g.cam+displacement,tilt,Vector2(flip,1))
 g.draw_texture_rect(cell.texture,Rect2(offset,cell.size*factor),false,mod)
 g.draw_set_transform(-g.cam)
func terrain():
 g.draw_texture_rect(cloth,Rect2(Vector2.ZERO,g.WORLD),false)
 for bounds in ([Rect2(64,96,g.WORLD.x-128,g.WORLD.y-184)] if g.map_style=='plains' else [Rect2(64,96,g.WORLD.x/2-160,g.WORLD.y-184),Rect2(g.WORLD.x/2+96,96,g.WORLD.x/2-160,g.WORLD.y-184)]):
  g.draw_rect(bounds.grow(7),Color('#a79f73'))
  g.draw_texture_rect(grass,bounds,false)
 var main_y=(g.CROSSINGS[0].x+g.CROSSINGS[0].y)/2
 var north_y=(g.CROSSINGS[1].x+g.CROSSINGS[1].y)/2
 # Mirrored trails connect home areas to every available crossing.
 var home_y=g.random_map.home_position.y+35 if g.random_map_enabled else 565.0
 var left_home=Vector2(g.random_map.home_position.x if g.random_map_enabled else 360,home_y)
 var right_home=Vector2(g.WORLD.x-g.random_map.home_position.x,home_y) if g.random_map_enabled else Vector2(2050,765)
 for span in g.CROSSINGS:
  var y=(span.x+span.y)/2.0
  for team in range(2):
   var home=left_home if team==0 else right_home
   var end=Vector2(g.WORLD.x/2+(-103 if team==0 else 103),y)
   var bend=Vector2(lerpf(home.x,end.x,0.48),lerpf(home.y,y,0.7))
   for layer in range(3):g.draw_polyline(PackedVector2Array([home,bend,end]),Color(0.68,0.60,0.39,0.16),46-layer*9,true)
 if g.map_style=='plains':
  for y in [main_y,north_y]:g.draw_polyline(PackedVector2Array([Vector2(g.WORLD.x/2-250,y),Vector2(g.WORLD.x/2+250,y)]),Color(0.68,0.60,0.39,0.22),36,true)
  return
 # Small shoreline rocks stay inside the impassable river margin.
 for side in [g.WORLD.x/2-89,g.WORLD.x/2+89]:
  for y in range(112,int(g.WORLD.y-100),38):
   if g.CROSSINGS.any(func(span):return y>span.x-40 and y<span.y+40):continue
   var p=Vector2(side+sin(y*0.31)*4,y)
   var r=8+fmod(y*0.37,6)
   g.draw_set_transform(p-g.cam,0,Vector2(1,0.65))
   g.draw_circle(Vector2(2,4),r,Color(0.15,0.23,0.19,0.17))
   g.draw_colored_polygon(PackedVector2Array([Vector2(-r,1),Vector2(-r*0.65,-r*0.70),Vector2(r*0.35,-r),Vector2(r,-2),Vector2(r*0.75,r*0.6),Vector2(-r*0.5,r*0.7)]),Color('#9b9b86'))
   g.draw_line(Vector2(-r*0.65,-r*0.70),Vector2(r*0.35,-r),Color('#c1c1a6'),2,true)
   g.draw_set_transform(-g.cam)
 for i in range(16):
  var p=Vector2(g.WORLD.x/2-70+fmod(i*41.0,140),110+fmod(i*79.0+g.time*5,g.WORLD.y-220))
  if g.CROSSINGS.any(func(span):return p.y>span.x-25 and p.y<span.y+25):continue
  g.draw_line(p,p+Vector2(14,1),Color(0.75,0.89,0.83,0.22),1.5,true)
 for span in g.CROSSINGS:
  var scale_x=244.0/bridge.bounds.size.x
  var top_height=(330-bridge.bounds.position.y)*scale_x
  var bottom_height=(bridge.bounds.end.y-560)*scale_x
  g.draw_rect(Rect2(g.WORLD.x/2-115,span.x+8,244,span.y-span.x+bottom_height),Color(0.11,0.19,0.17,0.20))
  # Stretch only the deck to match the existing walkable crossing; rails keep their proportions.
  g.draw_texture_rect_region(bridge.texture,Rect2(g.WORLD.x/2-122,span.x-top_height,244,top_height),Rect2(bridge.bounds.position.x,bridge.bounds.position.y,bridge.bounds.size.x,330-bridge.bounds.position.y))
  g.draw_texture_rect_region(bridge.texture,Rect2(g.WORLD.x/2-122,span.x,244,span.y-span.x),Rect2(bridge.bounds.position.x,330,bridge.bounds.size.x,230))
  g.draw_texture_rect_region(bridge.texture,Rect2(g.WORLD.x/2-122,span.y,244,bottom_height),Rect2(bridge.bounds.position.x,560,bridge.bounds.size.x,bridge.bounds.end.y-560))
func building_rect(b):
 var cell=frames[entity_key(b)][0]
 var size=Vector2(cell.bounds.size)*cell.scale
 return Rect2(b.p-Vector2(size.x/2,size.y),size+Vector2(0,10))

func building_ground(e):
 # A shallow worn footprint bridges the sprite and the terrain plane.
 var cell=frames[entity_key(e)][0]
 var width=cell.bounds.size.x*cell.scale
 var center=e.p+Vector2(0,-7)
 for layer in range(4):
  var points=PackedVector2Array()
  var spread=1.0+layer*0.11
  for i in range(24):
   var angle=TAU*i/24.0
   var rough=1.0+sin(i*7.0+e.p.x)*0.045
   points.append(center+Vector2(cos(angle)*width*0.49,sin(angle)*maxf(12,width*0.13))*spread*rough)
  g.draw_colored_polygon(points,Color(0.39,0.34,0.21,0.10*e.progress))
 # Worn entrance stones establish the ground's perspective and scale.
 if e.kind!='Tower':
  for i in range(3):
   var pos=e.p+Vector2((i%2)*3-2,5+i*7)
   g.draw_style_box(ground_stone,Rect2(pos-Vector2(8,2),Vector2(16,5)))
func shadow_entity(e):
 if not shadows_enabled:return
 shadow_pass=true
 if e.has('amount'):
  if e.kind=='wood':sprite('Tree3' if int(e.p.x)%3==0 else 'TreeSmall',e.p-Vector2(0,40),0.64,false,1,Color.WHITE,-1)
  else:sprite('Gold Stone 1',e.p-Vector2(0,12),0.8,false,1,Color.WHITE,-1)
 else:
  var key=entity_key(e)
  if g.contains_entity(g.units,e):draw_unit(e)
  else:sprite(key,e.p-Vector2(0,45),0.8,false,1,Color(1,1,1,e.progress),-1)
 shadow_pass=false

func entity_key(e):
 var key=('Blue_' if e.team==0 else 'Red_')+e.kind
 if e.kind=='Tower' and e.get('tower_branch','')!='':key+='_'+e.tower_branch
 return key

func source_image(path):
 var texture=load(path) as Texture2D
 assert(texture!=null,"Missing texture: "+path)
 var image=texture.get_image()
 if image.is_compressed():image.decompress()
 return image

func tree_hit(resource,point):
 var cell=frames['Tree3' if int(resource.p.x)%3==0 else 'TreeSmall'][0]
 var anchor=cell.get('anchor',cell.bounds.position.x+cell.bounds.size.x/2.0)
 var pixel=(point-resource.p)/cell.scale+Vector2(anchor,cell.bounds.end.y)
 var image=cell.hit_image
 # Small tolerance around the visible silhouette, never the transparent rectangle.
 for offset in [Vector2.ZERO,Vector2(3,0),Vector2(-3,0),Vector2(0,3),Vector2(0,-3)]:
  var sample=Vector2i(pixel+offset/cell.scale)
  if sample.x>=0 and sample.y>=0 and sample.x<image.get_width() and sample.y<image.get_height() and image.get_pixelv(sample).a>0.25:return true
 return false
