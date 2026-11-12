extends SceneTree
var g
func _initialize():call_deferred('run')
func step(seconds):
 for i in range(int(seconds*60)):g._process(1.0/60)
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false;g.resources.clear();g.gold=2000;g.wood=2000
 for kind in ['Smith','Workshop','Spearman','Catapult']:
  assert(g.art.frames.has('Blue_'+kind) and g.icon_hud.icons.has(kind))
 var im=Image.load_from_file('res://assets/knights/spearman-motion.png');assert(im.get_pixel(0,0).a<0.05)
 var worker=g.units[0]
 var forge=g.economy.place('Smith',Vector2(620,480),[worker]);assert(forge!=null)
 assert(not g.technology.research(forge,'attack'))
 step(25);assert(forge.progress>=1)
 var knight=g.entity('Warrior',Vector2(700,750));g.units.append(knight)
 var money=g.gold;assert(g.technology.research(forge,'attack'));assert(g.gold==money-100)
 assert(not g.technology.research(forge,'attack'));assert(g.base_attack(knight)==23)
 step(21);assert(g.base_attack(knight)==26 and g.technology.levels[1].attack==0)
 assert(g.technology.research(forge,'armor'));step(21)
 var enemy=g.entity('Warrior',Vector2(750,750),1)
 assert(g.strike_damage(enemy,knight,23)==21)
 assert(g.technology.research(forge,'attack'));step(31);assert(g.base_attack(knight)==29)
 assert(not g.technology.research(forge,'attack'))
 var factory=g.economy.place('Workshop',Vector2(800,480),[worker]);assert(factory!=null)
 step(25);assert(factory.progress>=1)
 g.buildings.append(g.entity('House1',Vector2(650,1000)))
 assert(not g.train('Warrior',factory));assert(g.train('Catapult',factory))
 var barracks=g.entity('Barracks',Vector2(600,900));g.buildings.append(barracks)
 assert(g.train('Spearman',barracks));step(22)
 assert(g.units.any(func(u):return u.kind=='Catapult'))
 var spear=g.units.filter(func(u):return u.kind=='Spearman')[0]
 assert(g.strike_damage(spear,enemy,g.base_attack(spear))==33)
 # Isolate a real siege shot, including splash, friendly exclusion and minimum range.
 g.units.clear();g.buildings.clear();g.shots.clear();g.technology.reset();g.nav_dirty=true
 var cat=g.entity('Catapult',Vector2(500,800));cat.mode='stop';g.units.append(cat)
 var target=g.entity('House1',Vector2(800,800),1);g.buildings.append(target)
 var friend=g.entity('Pawn',Vector2(745,815));friend.mode='stop';g.units.append(friend)
 var victim=g.entity('Pawn',Vector2(745,780),1);victim.mode='stop';g.units.append(victim)
 g.fog.update();assert(g.can_attack(cat,target));g.fire(cat,target,g.base_attack(cat));assert(g.shots.size()==1)
 step(2)
 assert(target.hp==260 and victim.hp==46 and friend.hp==70)
 cat.p=Vector2(700,800);assert(not g.can_attack(cat,target))
 g.reset();assert(g.technology.levels[0].attack==0 and g.technology.levels[0].armor==0)
 print('EXPANSION PASS: construction, prices, research timers/caps, team isolation, retroactive upgrades, training, siege splash, friendly exclusion, minimum range, restart')
 quit()
