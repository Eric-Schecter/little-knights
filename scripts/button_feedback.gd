extends RefCounted
static func attach(button):
 if not button is Button or button.has_meta('feedback_ready'):return
 button.set_meta('feedback_ready',true)
 var normal=button.get_theme_stylebox('normal')
 if not normal is StyleBoxFlat:return
 var hover=normal.duplicate()
 hover.bg_color=normal.bg_color.lightened(0.18)
 hover.border_color=Color('#e6c78e')
 hover.shadow_color=Color(0.86,0.68,0.33,0.16);hover.shadow_size=5
 var pressed=normal.duplicate()
 pressed.bg_color=normal.bg_color.darkened(0.24)
 pressed.border_color=Color('#cfac6c')
 pressed.shadow_color=Color(0,0,0,0.30);pressed.shadow_size=2
 var focus=normal.duplicate()
 focus.bg_color=Color.TRANSPARENT;focus.border_color=Color('#f0d49b')
 focus.set_border_width_all(2)
 button.add_theme_stylebox_override('hover',hover)
 button.add_theme_stylebox_override('pressed',pressed)
 button.add_theme_stylebox_override('hover_pressed',pressed)
 button.add_theme_stylebox_override('focus',focus)
 button.add_theme_color_override('font_hover_color',Color('#fff4d8'))
 button.add_theme_color_override('font_pressed_color',Color('#dfc894'))
 button.mouse_entered.connect(func():animate(button,Color(1.08,1.06,1.02) if not button.disabled else Color.WHITE))
 button.mouse_exited.connect(func():animate(button,Color.WHITE))
 button.button_down.connect(func():animate(button,Color(0.90,0.90,0.86),0.045))
 button.button_up.connect(func():animate(button,Color.WHITE,0.10))
static func animate(button,color,duration=0.12):
 var old=(button.get_meta('feedback_tween') if button.has_meta('feedback_tween') else null)
 if old!=null and old.is_valid():old.kill()
 var tween=button.create_tween()
 tween.tween_property(button,'self_modulate',color,duration)
 button.set_meta('feedback_tween',tween)
