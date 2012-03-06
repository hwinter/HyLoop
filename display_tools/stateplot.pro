;+
; NAME:
;	
;
; PURPOSE:
;	produce a PostScript (tm) plot of a loop model
;	state vector.
;	
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:	
;-


pro stateplot, x, state, fname=fname, screen=screen, verbose=verbose
;-
 
compile_opt strictarr

kB = 1.38e-16 ;Boltzmann constant (erg/K)
mp = 1.67e-24 ;proton mass (g)
gamma = 5.0/3.0 ;ratio of specific heats, Cp/Cv
gs = 2.74e4 ;solar surface gravity

N = n_elements(state.e) ;figure out grid size
x_alt = [2*x[0]-x[1],(x[0:N-3]+x[1:N-2])/2.0,2*x[N-2]-x[N-3]]
	;x on the volume element grid (like e, n_e)
midpt = max(x_alt)/2.0 ;find midpoint along loop
T = state.e/(3.0*state.n_e*kB)



if not keyword_set(screen) then begin
	prev_display = !d.name
	set_plot,'ps'
	if n_elements(fname) eq 0 then fname = 'stateplot.ps'
	device, filename=fname
endif
if  keyword_set(screen) then begin
    
    window, !d.window,TITLE=!COMPUTER+' Stateplot'

end

b=0.07 & c=0.03 & d=0.12 ;plot margins (relative to graphics window size)

tstring = 'Elapsed time = '+string(state.time,format='(f9.2)')+' s'
erase
xyouts, 1, 1, tstring, /device,charsize=1
plot, x,state.v, $
	;yrange=[-2e7,2e7], $
	position=[0+d,0+b,0.5-c,0.5-c], $
	ytitle='velocity (cm/s)', xtitle='x (cm)', $
	charsize=1.0, psym=3,/noerase
plot_io, x_alt,0.666666*state.e, $
	position=[0+d,0.5+c,0.5-c,1-c], $
	ytitle='P (dyn/cm^2)',/noerase, $
	charsize=1.0, psym=3
plot_oo, x_alt,T, $
	xrange=[1e5,max(x_alt)], $;yrange=[3e3,2e7],/ystyle, $
	position=[0.5+d,0+b,1-c,0.5-c], $
	ytitle='T (K)',/noerase, xtitle='x(cm)', $
	charsize=1.0, psym=3
oplot, max(x_alt)+min(x_alt)-x_alt,T, psym=3, color=128
oplot, [midpt,midpt],[min(T)/10,max(T)*10],linestyle=2
	;show loop midpoint location
plot_oo, x_alt,state.n_e, $
;plot, x_alt, state.n_e,$
	xrange=[1e5,max(x_alt)], $
	position=[0.5+d,0.5+c,1-c,1-c], $
	ytitle='n_e (cm^-3)',/noerase, $
	charsize=1.0, psym=3
oplot, max(x_alt)+min(x_alt)-x_alt,state.n_e,psym=3,color=128
oplot, [midpt,midpt],[min(state.n_e)/10,max(state.n_e)*10],linestyle=2
	;show loop midpoint location
if keyword_set(verbose) then begin
	print,'Temperature range (K):         ',minmax(T)
	print,'Pressure range (dyne cm^-2):   ',minmax(state.e)*0.66666
	print,'Electron density range (cm^-3):',minmax(state.n_e)
	print,'Velocity range (cm s^-1):      ',minmax(state.v)
endif
if not keyword_set(screen) then begin
	device, /close
	set_plot, prev_display
endif

end
