
function rotate_loop	
	;Simple test program.
compile_opt hidden
swin = !d.window
a = WIDGET_BASE(/COLUMN, TITLE='Arcball Test')
; Setting the managed attribute indicates our intention to put this app
; under the control of XMANAGER, and prevents our draw widgets from
; becoming candidates for becoming the default window on WSET, -1. XMANAGER
; sets this, but doing it here prevents our own WSETs at startup from
; having that problem.
WIDGET_CONTROL, /MANAGED, a

b = CW_ARCBALL(a, LABEL='Rotate loop', size=256, /UPDATE)
c = WIDGET_BUTTON(a, value='Done')
WIDGET_CONTROL, a, /REALIZE
tek_color
WIDGET_CONTROL, b, SET_VALUE=1	;Draw first ball
wset, swin
XMANAGER, 'Arcball', a;, /NO_BLOCK		;Manage it
WIDGET_CONTROL,b,gET_VALUE=matrix

return,matrix
end
