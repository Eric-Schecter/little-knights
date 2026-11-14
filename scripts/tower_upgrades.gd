extends RefCounted
var g
const NAMES={'arrow':'Arrow Tower','cannon':'Cannon Tower'}
const ICONS={'arrow':'Archer','cannon':'Catapult'}
func _init(game):g=game
func branch(b):return b.get('tower_branch','')
func level(b):return int(b.get('tower_level',0))
func price(b,key):
 return Vector2i(140,100) if level(b)==1 else {'arrow':Vector2i(90,70),'cannon':Vector2i(120,90)}[key]
func duration(b):return 20.0 if level(b)==1 else 15.0
func upgrade(b,key):
 if g.outcome!='' or b.kind!='Tower' or b.hp<=0 or b.progress<1 or key not in NAMES:return false
 if b.get('tower_pending','')!='' or level(b)>=2 or (branch(b)!='' and branch(b)!=key):return false
 var cost=price(b,key);var money=g.economy.balance(b.team)
 if money.x<cost.x or money.y<cost.y:g.economy.notify(b.team,'Need %d gold and %d wood.'%[cost.x,cost.y]);return false
 g.economy.credit(b.team,-cost);b['tower_pending']=key;b['tower_clock']=0.0;b['burst_target']=null
 if b.team==0:g.refresh_commands()
 return true
func attack(b):return {'arrow':14.0,'cannon':42.0}.get(branch(b),24.0)
func interval(b):return {'arrow':0.65,'cannon':2.3}.get(branch(b),1.2)
func reach(b):return {'arrow':245.0,'cannon':300.0}.get(branch(b),260.0)
func vision(_b):return 400.0
func splash(b):return 60.0 if level(b)==2 else 42.0
func tick(b,dt):
 if b.hp<=0 or b.progress<1:return
 if b.get('tower_pending','')!='':
  b['tower_clock']+=dt
  if b.tower_clock>=duration(b):
   b['tower_branch']=b.tower_pending;b['tower_level']=level(b)+1;b['tower_pending']='';b.cool=0.3
   if b.team==0:g.sfx.play('complete');g.refresh_commands()
  return # Upgrade construction temporarily suspends fire; HP ratio never changes.
 if b.get('burst_target',null)!=null:
  b['burst_delay']-=dt
  if b.burst_delay<=0:
   var target=b.burst_target;b.burst_target=null
   if target.hp>0 and g.can_attack(b,target):g.fire(b,target,attack(b))
 if b.cool>0:return
 var targets=g.units.filter(func(u):return u.team!=b.team and g.can_attack(b,u))
 if targets.is_empty():return
 targets.sort_custom(func(a,c):return priority(b,a)<priority(b,c))
 var target=targets[0];g.fire(b,target,attack(b));b.cool=interval(b)
 if branch(b)=='arrow' and level(b)==2:b['burst_target']=target;b['burst_delay']=0.16
func priority(b,u):
 var bonus=0.0
 if branch(b)=='arrow' and u.kind in ['Archer','Spearman']:bonus=-500
 if branch(b)=='cannon' and u.kind in ['Cavalry','Catapult']:bonus=-500
 return b.p.distance_to(u.p)+bonus
func commands(b):
 var keys=NAMES.keys() if branch(b)=='' else [branch(b)]
 for key in keys:
  var cost=price(b,key)
  var button=g.cmd('%s %d\n%d gold %d wood · %.0fs'%[NAMES[key],level(b)+1,cost.x,cost.y,duration(b)],func():upgrade(b,key))
  g.icon_hud.decorate(button,'Tower_'+key,button.tooltip_text)
  button.disabled=level(b)>=2 or b.get('tower_pending','')!=''
  button.tooltip_text=NAMES[key]+' · '+('MAX LEVEL' if level(b)>=2 else '%d gold / %d wood · %.0fs'%[cost.x,cost.y,duration(b)])+'\n'+{'arrow':'Fast fire, prefers light infantry. Level 2: two-shot burst.','cannon':'Slow cannonball, area damage. Level 2: larger blast radius.'}[key]+'\nPermanent branch choice. Cannot fire during upgrade.'
  g.icon_hud.purchase_button(button,cost,'Maximum level' if level(b)>=2 else ('Upgrade in progress' if b.get('tower_pending','')!='' else ''))
func draw(b):
 if branch(b)=='':return
 var top=b.p+Vector2(0,-g.art.building_rect(b).size.y*0.65)
 var flash=clampf(1.0-(g.time-b.get('shot_at',-100.0))/0.22,0,1)
 if flash>0:
  if branch(b)=='cannon':
   g.draw_circle(top,5+(1-flash)*13,Color(1,0.7,0.25,flash*0.8))
   for i in range(3):g.draw_circle(top+Vector2(i*5,-(1-flash)*20),5+(1-flash)*8,Color(0.7,0.65,0.54,flash*0.35))
  else:g.draw_line(top+Vector2(-5,0),top+Vector2(5,-8),Color(1,0.9,0.6,flash),2,true)
 for i in range(level(b)):g.draw_circle(b.p+Vector2(-5+i*10,-38),3,Color('#f3d278'))
func draw_projectile(s):
 var dir=(s.end-s.start).normalized()
 var ratio=clampf(s.start.distance_to(s.p)/maxf(1,s.start.distance_to(s.end)),0,1)
 var head=s.p-Vector2(0,lerpf(s.get('muzzle_height',25.0),25.0,ratio))
 if s.tower_branch=='cannon':
  head.y-=sin(ratio*PI)*45
  g.draw_circle(head,6,Color('#363b3b'));g.draw_circle(head+Vector2(-2,-2),2,Color('#9aa3a0'))
  for i in range(3):g.draw_circle(head-dir*(8+i*7),3+i,Color(0.65,0.61,0.51,0.20-i*0.05))
 else:
  g.draw_line(head-dir*24,head,Color('#f9dd89'),2,true)
  g.draw_colored_polygon(PackedVector2Array([head+dir*5,head-dir*3+dir.orthogonal()*3,head-dir*3-dir.orthogonal()*3]),Color('#e1e8db'))
func draw_impact(fx):
 var ratio=1.0-fx.life/0.4;var p=fx.p-Vector2(0,15)
 if fx.tower_hit=='cannon':
  g.draw_circle(p,6+ratio*23,Color(0.93,0.62,0.24,(1-ratio)*0.6))
  for i in range(7):
   var dir=Vector2.from_angle(i*2.4)
   g.draw_circle(p+dir*ratio*35,4+ratio*6,Color(0.55,0.49,0.39,(1-ratio)*0.55))
   g.draw_line(p+dir*ratio*12,p+dir*(9+ratio*28),Color(1,0.8,0.44,1-ratio),2,true)
 else:
  for i in range(3):
   var dir=Vector2.from_angle(i*2.4)
   g.draw_line(p+dir*3,p+dir*(8+ratio*8),Color(0.9,0.76,0.48,1-ratio),1.5,true)
