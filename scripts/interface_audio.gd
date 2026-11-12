extends Node
var g
var music=[]
var click:AudioStreamPlayer
var current=-1
var transition:Tween
func _init(game):g=game
func _ready():
 for name in ['menu','match']:
  var player=AudioStreamPlayer.new()
  var stream=load('res://assets/audio/music/'+name+'.ogg')
  assert(stream!=null)
  stream.loop=true;player.stream=stream;player.volume_db=-60;add_child(player);music.append(player)
 click=AudioStreamPlayer.new();click.stream=load('res://assets/audio/kenney-rpg/handleSmallLeather.ogg');click.volume_db=-8;add_child(click)
 attach_tree(g)
 get_tree().node_added.connect(watch_node)
func watch_node(node):
 if node is BaseButton:call_deferred('attach_button',node)
func attach_tree(node):
 if node is BaseButton:attach_button(node)
 for child in node.get_children():attach_tree(child)
func attach_button(button):
 if is_instance_valid(button):preload('res://scripts/button_feedback.gd').attach(button)
 if is_instance_valid(button) and not button.pressed.is_connected(play_click):button.pressed.connect(play_click)
func play_click():click.play()
func _process(_dt):
 var desired=0 if g.start_menu!=null and g.start_menu.is_open() else 1
 if desired!=current:
  if transition!=null:transition.kill()
  current=desired
  music[current].volume_db=-60;music[current].play()
  transition=create_tween().set_parallel(true)
  transition.tween_property(music[current],'volume_db',-9.0 if current==0 else -15.0,1.5)
  var old=music[1-current]
  transition.tween_property(old,'volume_db',-60.0,1.5)
  transition.chain().tween_callback(old.stop)
