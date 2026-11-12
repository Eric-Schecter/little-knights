extends RefCounted
# CC0 Kenney RPG samples; local cache, bounded voices and visual-knowledge gating.
const ROOT='res://assets/audio/kenney-rpg/'
const BANK={
 'select':['handleSmallLeather','handleSmallLeather2'],
 'train':['@ready'],
 'complete':['@complete'],
 'collapse':['@collapse'],
 'death':['@death'],
 'command':['@command'],
 'step':['footstep00','footstep01','footstep02','footstep03','footstep04','footstep05'],
 'swing':['knifeSlice','knifeSlice2'],
 'bolt':['@bolt'],
 'tower_cannon':['@tower_cannon_v2'],'tower_cannon_hit':['@tower_cannon_hit_v2'],
 'tower_rapid':['@tower_rapid'],'tower_heavy':['@tower_heavy'],'tower_watch':['@tower_watch'],'tower_heavy_hit':['@tower_heavy_hit'],'tower_watch_hit':['@tower_watch_hit'],
 'hit':['@hit'],
 'metal':['@metal'],
 'wood':['chop'],
 'mine':['@mine'],
 'deliver':['handleCoins','handleCoins2'],
 'build':['chop']}
const LEVELS={'tower_cannon':-4.0,'tower_cannon_hit':-9.0,'tower_rapid':-10.0,'tower_heavy':-8.0,'tower_watch':-10.0,'tower_heavy_hit':-13.0,'tower_watch_hit':-14.0,'select':-16.0,'train':-9.0,'complete':-9.0,'collapse':-13.0,'death':-14.0,'command':-9.0,'step':-28.0,'swing':-16.0,'bolt':-14.0,'hit':-14.0,'metal':-15.0,'wood':-22.0,'mine':-22.0,'deliver':-20.0,'build':-23.0}
const GAPS={'tower_cannon':0.25,'tower_cannon_hit':0.15,'tower_rapid':0.10,'tower_heavy':0.25,'tower_watch':0.2,'tower_heavy_hit':0.12,'tower_watch_hit':0.15,'select':0.12,'train':0.4,'complete':0.4,'collapse':0.3,'death':0.18,'command':0.18,'step':0.16,'swing':0.12,'bolt':0.12,'hit':0.10,'metal':0.14,'wood':0.22,'mine':0.38,'deliver':0.25,'build':0.25}
var g
var streams={}
var voices=[]
var cooldown={}
var counts={}
var notifications=[]
var notification_voice
var duck=0.0
var rng=RandomNumberGenerator.new()
func _init(game):
 g=game;rng.seed=927
 for list in BANK.values():
  for name in list:
   if streams.has(name):continue
   var stream
   if name.begins_with('@'):stream=load('res://assets/audio/knights-mix/'+name.substr(1)+'.wav')
   else:stream=load(ROOT+name+'.ogg')
   assert(stream!=null,'Missing audio sample '+name)
   streams[name]=stream
 if DisplayServer.get_name()!='headless':
  notification_voice=AudioStreamPlayer.new();g.add_child(notification_voice)
  for i in range(12):
   var voice=AudioStreamPlayer.new();g.add_child(voice);voices.append(voice)
func reset():
 cooldown.clear();counts.clear();notifications.clear();duck=0.0
 if notification_voice!=null:notification_voice.stop()
 for voice in voices:voice.stop()
func tick(dt):
 for key in cooldown:cooldown[key]=maxf(0,cooldown[key]-dt)
 if notification_voice!=null:
  notification_voice.stream_paused=g.paused
  if not g.paused and not notification_voice.playing and not notifications.is_empty():
   var event=notifications.pop_front()
   notification_voice.stream=streams[BANK[event][0]]
   notification_voice.volume_db=LEVELS[event];notification_voice.play();duck=0.75
 if not g.paused:duck=maxf(0.0,duck-dt)
 for voice in voices:
  if voice.has_meta('base_db'):voice.volume_db=voice.get_meta('base_db')-(7.0 if duck>0 else 0.0)
 for voice in voices:voice.stream_paused=g.paused
func audible(p):
 if p==Vector2.INF:return true
 return g.fog.sees(0,p) and Rect2(g.cam+Vector2(0,72),Vector2(1440,660)).grow(40).has_point(p)
func play(kind,p=Vector2.INF):
 if not BANK.has(kind) or g.paused or not audible(p):return false
 # Own completion/production events queue on a dedicated voice: never dropped by combat.
 if kind in ['train','complete'] and p==Vector2.INF:
  counts[kind]=counts.get(kind,0)+1
  if notification_voice!=null:notifications.append(kind)
  return true
 if cooldown.get(kind,0)>0:return false
 var voice=null
 # Reserve two voices for acknowledgements and major lifecycle events.
 var important=kind in ['command','train','complete','collapse','death']
 var cannon=kind in ['tower_cannon','tower_cannon_hit']
 var pool=voices.slice(10,12) if cannon else (voices.slice(0,10) if important else voices.slice(0,8))
 for candidate in pool:
  if not candidate.playing:voice=candidate;break
 if voice==null and kind=='tower_cannon' and not pool.is_empty():
  voice=pool[0] if pool[0].get_meta('started',-1.0)<=pool[1].get_meta('started',-1.0) else pool[1]
  voice.stop()
 if not voices.is_empty() and voice==null:return false
 cooldown[kind]=GAPS[kind];counts[kind]=counts.get(kind,0)+1
 if voice==null:return true # headless tests still verify event gating
 var list=BANK[kind];var name=list[rng.randi_range(0,list.size()-1)]
 voice.stream=streams[name]
 var attenuation=0.0 if p==Vector2.INF else clampf(p.distance_to(g.cam+Vector2(720,400))/1000.0,0,1)*5.0
 voice.set_meta("base_db",LEVELS[kind]-attenuation)
 voice.volume_db=LEVELS[kind]-attenuation-(7.0 if duck>0 else 0.0)
 voice.pitch_scale=rng.randf_range(0.88,0.96) if kind in ['mine','metal','hit','collapse'] else rng.randf_range(0.97,1.03)
 voice.set_meta('started',g.time);voice.play();return true
