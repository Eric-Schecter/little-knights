extends RefCounted
var g
var levels=[]
func _init(game):g=game;reset()
func reset():levels=[{'attack':0,'armor':0},{'attack':0,'armor':0}]
func bonus(u,key):return levels[u.team][key]*(3 if key=='attack' else 2) if u.kind in ['Warrior','Archer','Spearman','Catapult','Cavalry'] else 0
func price(team,key):return Vector2i(100+75*levels[team][key],80+50*levels[team][key])
func duration(team,key):return 20.0+10.0*levels[team][key]
func research(b,key):
 if g.outcome!='' or b.kind!='Smith' or b.hp<=0 or b.progress<1 or key not in ['attack','armor']:return false
 if b.research!='' or levels[b.team][key]>=2:return false
 if g.buildings.any(func(other):return other.hp>0 and other.team==b.team and other.research==key):return false
 var cost=price(b.team,key);var money=g.economy.balance(b.team)
 if money.x<cost.x or money.y<cost.y:g.economy.notify(b.team,'Need %d gold and %d wood.'%[cost.x,cost.y]);return false
 g.economy.credit(b.team,-cost);b.research=key;b.research_time=0.0
 if b.team==0:g.refresh_commands()
 return true
func tick(b,dt):
 if b.hp<=0 or b.progress<1 or b.research=='':return
 b.research_time+=dt
 if b.research_time>=duration(b.team,b.research):
  levels[b.team][b.research]+=1;b.research='';b.research_time=0.0
  if b.team==0:g.sfx.play('complete');g.refresh_commands()
