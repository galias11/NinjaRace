extends TextureRect

var val=0

var touch_index = -1
var minXY
var maxXY
var isVertical

var joystick

func _ready():
	set_process_input(true)
	joystick=get_node("Joystick")
	minXY=Vector2(0,floor((float(get_size().y))/2.0))
	maxXY=Vector2(get_size().x-1,floor((float(get_size().y))/2.0))
	
func _input(ev):
	if is_visible() and (ev is InputEventScreenTouch or ev is InputEventScreenDrag):
			
		if ev is InputEventScreenTouch:
			if ev.pressed:
				var p = get_pos()
				var sz = get_size()
				#check if touch was inside control
				if (ev.position.x>=p.x) and (ev.position.x<p.x+sz.x) and (ev.position.y>=p.y) and (ev.position.y<p.y+sz.y):
					#save touch index to track "DRAG" events
					touch_index = ev.index
					ev.position.x=clamp(ev.position.x-p.x,minXY.x,maxXY.x)
					ev.position.y=clamp(ev.position.y-p.y,minXY.y,maxXY.y)
					set_val(ev)
			else: #release
				if touch_index == ev.index:
					touch_index=-1
					reset_val(ev)
						
		if ev is InputEventScreenDrag:
			var p = get_pos()
			var sz = get_size()
			if (ev.index == touch_index): #allow drag outside of control
				ev.position.x=clamp(ev.position.x-p.x,minXY.x,maxXY.x)
				ev.position.y=clamp(ev.position.y-p.y,minXY.y,maxXY.y)
				set_val(ev)
				
#reset joystick to center (on touch release)
func reset_val(ev):
	ev.position.x=(maxXY.x-minXY.x+1)/2+minXY.x
	ev.position.y=(maxXY.y-minXY.y+1)/2+minXY.y
	set_val(ev)

#set value based on control-relative event coordinates (also suitable for mouse coords)
func set_val(ev):
	if isVertical:
		val = clamp((ev.position.y-(get_size().y/2.0))/(get_size().y/-2.0),-1,1)
	else:
		val = clamp((ev.position.x-(get_size().x/2.0))/(get_size().x/-2.0),-1,1)
	#move joystick control
	joystick.set_pos(Vector2(ev.position.x-(joystick.get_size().x/2),ev.position.y-(joystick.get_size().y/2)))