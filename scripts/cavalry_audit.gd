extends SceneTree
var g
func _initialize():call_deferred('run')
func step(seconds):
 for i in range(int(seconds*60)):g._process(1.0/60)
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false;g.resources.clear();g.gold=1000;g.wood=1000
 var b=g.entity('Barracks',Vector2(620,500));g.buildings.append(b);g.nav_dirty=true
 var money=g.gold;assert(not g.train('Cavalry',b) and g.gold==money)
 var forge=g.entity('Smith',Vector2(800,500));forge.progress=0.5;g.buildings.append(forge)
 assert(not g.train('Cavalry',b));forge.progress=1
 assert(not g.train('Cavalry',b),'Two-pop unit cannot fit one free slot')
 g.buildings.append(g.entity('House1',Vector2(600,1000)))
 assert(g.train('Cavalry',b));assert(g.population()==6 and g.gold==money-125)
 assert(g.economy.cancel(b,0));assert(g.population()==4 and g.gold==money)
 assert(g.train('Cavalry',b));step(14)
 var knight=g.units.filter(func(u):return u.kind=='Cavalry')[0]
 assert(g.population()==6 and knight.max==190 and g.base_attack(knight)==28)
 assert(g.move_speed(knight)==140 and g.armor_value(knight)==2)
 var spear=g.entity('Spearman',Vector2(800,800),1)
 assert(g.strike_damage(spear,knight,18)==34)
 g.technology.levels[0].attack=1;g.technology.levels[0].armor=1
 assert(g.base_attack(knight)==31 and g.armor_value(knight)==4)
 assert(g.strike_damage(spear,knight,18)==32)
 # A pure cavalry formation travels quickly and stops without residual stepping.
 g.units=[knight];g.buildings.clear();g.nav_dirty=true
 knight.p=Vector2(400,900);g.issue_order([knight],Vector2(850,900),null,'move');step(2)
 assert(knight.p.x>570,'Mounted formation must be faster than infantry')
 step(7);var settled=knight.p;var stride=knight.stride;step(2)
 assert(knight.p.distance_to(settled)<0.1 and not knight.moving and knight.stride==stride)
 # Larger enemy body clips a fast rider without tunnelling.
 var foe=g.entity('Warrior',knight.p+Vector2(60,0),1);g.units.append(foe)
 g.blocking.move(knight,foe.p+Vector2(40,0),false)
 assert(knight.p.distance_to(foe.p)>=29.9)
 g.units=[knight];knight.p=Vector2(400,950)
 var foot=g.entity('Warrior',Vector2(460,950));g.units.append(foot)
 g.issue_order([knight,foot],Vector2(850,1000),null,'move');step(15)
 var positions=[knight.p,foot.p];step(2)
 assert(knight.p.distance_to(positions[0])<0.1 and foot.p.distance_to(positions[1])<0.1,'Mixed formation settles without pushing')
 var sheet=Image.load_from_file('res://assets/knights/cavalry-motion.png');assert(sheet.get_pixel(0,0).a<0.05)
 assert(g.art.motions.Blue_Cavalry.walk.size()==6 and g.icon_hud.icons.has('Cavalry'))
 print('CAVALRY PASS: prerequisite, price/refund, 2-pop reservation, training, upgrades, spear counter, speed, settled animation, collision and art')
 quit()
