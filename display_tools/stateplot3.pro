;;+
;NOT FINIHED!
; NAME:
;	
;
; PURPOSE:
;	produce a PostScript (tm) plot of a loop model
;	state vector. Same as stateplot but no log-log scaling
;	
;
; CATEGORY:
;	Loop display tools
;
; CALLING SEQUENCE:
;       stateplot3,loop, fname=fname, screen=screen, verbose=verbose, $
;	            LINESTYLE=LINESTYLE, VRANGE=VRANGE
;
; INPUTS:
;	x: Array of steps on the surface grid
;       state: loop state structure
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	FNAME: Name of PostScript (tm) file
;       SCREEN: Output display to screen instead of PS file
;       LINESTYLE; Line style of loop
;       VRANGE;  Range of velocity values
 ;
; OUTPUTS:
;	NONE
;
; OPTIONAL OUTPUTS:
;	NONE
;
; COMMON BLOCKS:
;	NONE
;
; SIDE EFFECTS:
;	None found
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	stateplot2, loop.s, loop.state, fname=fname, 
;                   /SCREEN, /VERBOSE, $
;                   LINESTYLE=0
;	
;
;Modified by Henry (Trae) Winter III 4/15/2003
;	2003-APR-09 HDWIII added LINESTYLE keyword
;       2006-***-*** HDWIII replaced statements to calculate values 
;                    with new functions to do the same job     
;-
pro stateplot3, loop, fname=fname, screen=screen, verbose=verbose, $
                LINESTYLE=LINESTYLE, VRANGE=VRANGE, WINDOW=WINDOW,$
                XRANGE=XRANGE,TRANGE=TRANGE, DRANGE=DRANGE,PRANGE=PRANGE ,$
                CS=CS, MACH=MACH, FONT=FONT,XSIZE=XSIZE, YSIZE=YSIZE ,$
                CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK,$
                PLOT_LINE=PLOT_LINE, TITLE=TITLE, LOG=LOG,$
                THICK=THICK, PSYMTHICK=PSYMTHICK, LINE_THICK=LINE_THICK
                
 
compile_opt strictarr
color=1
n_loops=n_elements(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;figure out grid size
N = n_elements(loop[0].state.v) 
if not keyword_set(FONT) then begin
    if keyword_set(SCREEN) THEN FONT=-1 else FONT=0
endif
if not keyword_set(TITLE) THEN TITLE='HD plot'
if not keyword_set(XRANGE) then BEGIN
    if not keyword_set(LOG) then $
      XRANGE=[min(loop[0].s_alt), max(loop[0].s_alt)] $
             else XRANGE=[min(loop[0].s)+1., max(loop[0].s)]
endif
if keyword_set(CS) or  keyword_set(MACH) then BEGIN
    CS=get_loop_sound_speed(loop[0], /S_GRID)
    if n_loops gt 1 then $
      for i=1ul, n_loops-1ul do cs=[[cs], [get_loop_sound_speed(loop[i], /S_GRID)]]
    VYTITLE='Mach #' 
endif ELSE BEGIN 
        CS=1d0+dblarr(N, n_loops)
        VYTITLE='Velocity (cm s!E-1!N)'
    ENDELSE
if not keyword_set(CHARSIZE) then CHARSIZE_IN =1.1 else $
  CHARSIZE_IN=CHARSIZE

if not keyword_set(CHARTHICK) then CHARTHICK_IN =1.1 else $
  CHARTHICK_IN=CHARTHICK
if not keyword_set(THICK) then THICK=1.5
if not keyword_set(PSYMTHICK) then SYMSIZE=1.5 else $
  SYMSIZE=PSYMTHICK
if not keyword_set(LINE_THICK) then LTHICK=1.5 else $
  LTHICK=LINE_THICK

PYTITLE='P (dyn cm!E-2!N)'
TYTITLE='T (K)'
DYTITLE='n!Be!N (cm!E-3!N)'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
colors=[1,2,3]
if keyword_set(Eps) or  keyword_set(PS) then $
  colors=[colors, 4] else  colors=[colors, 255]
;Linestyles
lines=[0,2,3,4,5]
n_colors=n_elements(colors)
n_lines=n_elements(lines)

color_array=colors[0]
lines_array=lines[0]
if keyword_set(PSYM) then psym_array=psym[0]

for i=1, n_loops-1 do begin
    color_array=[color_array,colors[i mod n_colors]]
    lines_array=[lines_array, lines[fix(i/n_colors)]]
    if keyword_set(PSYM) then $
      psym_array=[psym_array, PSYM[fix(i/n_colors)]]
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;find midpoint along loop[0]
midpt = max(loop[0].s_alt)/2.0 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the temperature 
T=get_loop_temp(loop)
;Calculate the pressure
p=get_loop_pressure(loop)  
if not keyword_set(TRANGE) then $
  TRANGE=[min(T)*.9, max(T)*1.1]
if not keyword_set(PRANGE) then $
  PRANGE=[min(P)*.9, max(P)*1.1]
if not keyword_set(DRANGE) then $
  DRANGE=[min(loop.state.n_e)*.9,$
          max(loop.state.n_e)*1.1]
if not keyword_set(VRANGE) then $
  VRANGE=[min(loop.state.v/cs)*.9,$
          max(loop.state.v/cs)*1.1]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the old colors
tvlct,old_r, old_g, old_b, /GET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the new colors: 0 results in black, 1 in red, 2 in green, 
; and 3 in blue
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

if not keyword_set(screen) then begin
	prev_display = !d.name
	set_plot,'ps'
	if n_elements(fname) eq 0 then fname = 'stateplot.ps'
         FONT=0
         device, /COLOR, FILE=fname, /LANDSCAPE
         SYMSIZE=.1
         ;The PS device won't plot psm=1!  What a jip!
         PSYM=2
         LTHICK=LTHICK*4
         SYMSIZE=SYMSIZE*4
         charsize_in=charsize_in
         CHARTHICK_IN=CHARTHICK_IN
         
    endif ELSE BEGIN
        PSYM=3
        symsize=7
        FONT=-1
        if !d.name eq 'X' then begin 
            device, WINDOW_STATE=WS
            if max(ws) ne 0 then old_win=!d.window
        endif
        
        case 1 of 
            (not keyword_set(WINDOW)) and (!d.name eq 'X'):
            (!d.name eq 'X' and  keyword_set(WINDOW)):begin
                if ws[window] eq 1 then wset, window $
                else window, WINDOW,TITLE=!computer+' State Plot' 
            end
            (!d.name eq 'X' and not  keyword_set(WINDOW)): $
              window,TITLE=!computer+' State Plot'
            else:
        endcase
                             
    endelse


tstring = 'Elapsed time = '+string(loop[0].state.time,format='(f9.2)')+' s'
erase
;print,keyword_set(screen)
if keyword_set(LINESTYLE) ne -1 then LINESTYLE=0
extra=gang_plot_pos(2,2,0)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the Pressure    
plot, loop[0].s_alt,p[*,0], $
      ytitle=PYTITLE, $
      LINESTYLE=LINESTYLE,  $
      XRANGE=XRANGE, XS=1, FONT=FONT,  $
      /YLOG, _EXTRA=extra,  $
      XGRID=1, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
      /NODATA, XLOG=LOG,$
      CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN

;Plot the loop center
;oplot, [midpt,midpt], $
;       [0,max(P)*15]
for i=0ul, n_loops-1ul  do begin
    if keyword_set(PLOT_LINE) then $
      oplot,  loop[i].s_alt,p[*,0],COLOR=color_array[i],$
              LINESTYLE=LINESTYLE, thick=LTHICK $
      else $
      oplot,  loop[i].s_alt,p[*,i], $
              psym=PSYM, SYMSIZE=SYMSIZE, COLOR=color_array[i]
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the Electron Density	
plot_io, loop[0].s_alt,loop[0].state.n_e, $
         LINESTYLE=LINESTYLE ,  $
         XRANGE=XRANGE, YRANGE=DRANGE, XS=1,  $
         FONT=FONT, _EXTRA=gang_plot_pos(2,2,1),  $
         ystyle=21,  $
         XGRID=1, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
         /NODATA, XLOG=LOG,$
         CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN

;Plot the loop center
;oplot, [midpt,midpt],[0,1d30], LINESTYLE=5

for i=0ul,  n_loops-1ul do begin
if keyword_set(PLOT_LINE) then $
  oplot,   loop[i].s_alt,loop[i].state.n_e,COLOR=color_array[i], $
           LINESTYLE=LINESTYLE, thick=LTHICK $
  else $
  oplot,   loop[i].s_alt,loop[i].state.n_e, psym=PSYM, $
           SYMSIZE=SYMSIZE, COLOR=color_array[i]
endfor

axis, /yaxis,  yrange=drange,/ys,ytitle=DYTITLE, $
      FONT=FONT, YGRID=1, XTICKLEN=1, YTICKLEN=1 ,$
        CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the Velocity
plot, loop[0].s,loop[0].state.v/CS, $
      yrange=VRANGE,YSTYLE=8, $
      ytitle=VYTITLE, xtitle='s (cm)', $ 
      LINESTYLE=LINESTYLE,$
      XRANGE=XRANGE, XS=1, FONT=FONT,  $
      _EXTRA=gang_plot_pos(2,2,2),  $
      XGRID=1, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
      XTICKLAYOUT=2,YTICKS=4, $
      /NODATA, XLOG=LOG ,$
      CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN ;, YLOG=LOG   

;Plot the loop center
;oplot, [midpt,midpt],[-1d32,1d32], LINESTYLE=5

for i=0ul,n_loops-1ul do begin
    if keyword_set(PLOT_LINE) then $
      oplot, loop[i].s , loop[i].state.v/cs[*,i],COLOR=color_array[i] , $
             LINESTYLE=LINESTYLE, thick=1.5 $
      else $
      oplot, loop[i].s, loop[i].state.v/cs[*,i], psym=psym,$
             SYMSIZE=SYMSIZE, COLOR=color_array[i]  
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;Plot the Temperature
t=get_loop_temp(loop)
pmm, t
pmm, TRANGE
plot, loop[0].s_alt,T[*,0], $
      xtitle='s (cm)', $
      LINESTYLE=LINESTYLE,  $
      XRANGE=XRANGE, YRANGE=TRANGE, $
      XS=1, FONT=FONT, _EXTRA=gang_plot_pos(2,2,3),  $
      ystyle=21,  $
      XGRID=1, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
      XTICKLAYOUT=2,$
      /NODATA    , XLOG=LOG , YLOG=LOG   ,$
      CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN ;
;Plot the loop center
;oplot, [midpt,midpt],[0,1d15], LINESTYLE=5
for i=0ul,n_loops-1ul do begin
    if keyword_set(PLOT_LINE) then $
      oplot, loop[i].s_alt,T[*,i],COLOR=color_array[i], $
             LINESTYLE=LINESTYLE, thick=LTHICK $
      else $
      oplot, loop[i].s_alt,T[*,i], psym=psym, SYMSIZE=SYMSIZE, COLOR=color_array[i]
    
    axis, /yaxis,  yrange=TRANGE,/ys,ytitle=TyTITLE, $
          FONT=FONT, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
        CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xyouts, extra.position[2],extra.position[3]*1.01, tstring,$
        FONT=FONT,/NORMAL,$
        CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN
xyouts, extra.position[0],extra.position[3]*1.01, $
        title,/NORMAL,FONT=FONT,$
        CHARSIZE=CHARSIZE_IN, CHARTHICK=CHARTHICK_IN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set(verbose) then begin
	print,'Temperature range (K):         ',minmax(T)
	print,'Pressure range (dyne cm^-2):   ',minmax(loop.state.e)*0.66666
	print,'Electron density range (cm^-3):',minmax(loop.state.n_e)
	print,'Velocity range (cm s^-1):      ',minmax(loop.state.v)
endif
if not keyword_set(screen) then begin
	device, /CLOSE
	set_plot, prev_display
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset to the old colors
tvlct,old_r, old_g, old_b
if size(old_win, /TYPE) ne 0 then wset, old_win

END;Of stateplot3.pro







