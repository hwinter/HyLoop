

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
pro plot_avg_temp2, loop, fname=fname, screen=screen, verbose=verbose, $
                   LINESTYLE=LINESTYLE, WINDOW=WINDOW,$
                   XRANGE=XRANGE,TRANGE=TRANGE,$
                   FONT=FONT,XSIZE=XSIZE, YSIZE=YSIZE ,$
                   CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK,$
                   PLOT_LINE=PLOT_LINE, TITLE=TITLE, LOG=LOG,$
                   THICK=THICK, gpp=gpp, No_time=no_time
                
 
compile_opt strictarr
color=1
n_loops=n_elements(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;figure out grid size
N = n_elements(loop[0].state.v) 
if not keyword_set(FONT) then begin
    if keyword_set(SCREEN) THEN FONT=-1 else FONT=0
endif
if not keyword_set(TITLE) THEN TITLE='AVG Temperature Plot'
if not keyword_set(XRANGE) then BEGIN
    if not keyword_set(LOG) then $
      XRANGE=[min(loop[0].s_alt), max(loop[0].s_alt)] $
             else XRANGE=[min(loop[0].s)+1., max(loop[0].s)]
endif

if not keyword_set(CHARSIZE) then CHARSIZE =1.1
if not keyword_set(CHARTHICK) then CHARTHICK=1.1
if not keyword_set(THICK) then THICK=1.5

TYTITLE='T (K)'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;set the old colors
tvlct,old_r, old_g, old_b, /GET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the new colors: 0 results in black, 1 in red, 2 in green, 
; and 3 in blue
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
colors=[1,2,3]
if keyword_set(Eps) or  keyword_set(PS) then $
  colors=[colors, 4] else  colors=[colors, 255]
;Linestyles

n_colors=n_elements(colors)


color_array=colors[0]
if keyword_set(PSYM) then psym_array=psym[0]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;find midpoint along loop[0]
midpt = max(loop[0].s_alt)/2.0 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
T=get_loops_avg_temp(loop,STD_DEV=std_t)

if not keyword_set(TRANGE) then $
  TRANGE=[min(T-std_t)*.9, max(T-std_t)*1.1]

tstring = 'Elapsed time = '+string(loop[0].state.time,format='(f9.2)')+' s'
;erase
;print,keyword_set(screen)
if keyword_set(LINESTYLE) ne -1 then LINESTYLE=0
;extra=gang_plot_pos(2,2,0)


i=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;Plot the Temperature
plot, loop[0].s_alt,T, $
      xtitle='s (cm)', $
      LINESTYLE=LINESTYLE,  $
      XRANGE=XRANGE, YRANGE=TRANGE, $
      XS=1, FONT=FONT,  $
      ystyle=1,  $
      XGRID=1, YGRID=1, XTICKLEN=1, YTICKLEN=1,$
      XTICKLAYOUT=2,$
      /NODATA    , XLOG=LOG , YLOG=LOG ,$
      THICK=thick*thick_factor,$
      _extra=gpp                       ;
;Plot the loop center
;oplot, [midpt,midpt],[0,1d15], LINESTYLE=5
;for i=0ul,n_loops-1ul do begin
    if keyword_set(PLOT_LINE) then $
      oplot, loop[0].s_alt,T,COLOR=fsc_color('red'), $
             LINESTYLE=LINESTYLE,THICK=thick*thick_factor  $
      else $
      oplot, loop[0].s_alt,T, psym=psym, $
             SYMSIZE=SYMSIZE*thick_factor, COLOR=fsc_color('red')
    t_minus_error=T-std_T
    
    t_plus_error=T+std_T
    
    index=where(t_minus_error ge min(trange) and $
               t_plus_error le max(trange))

    if index[0] ne -1 then begin
        t_minus_error=t_minus_error[index]
        t_plus_error=t_plus_error[index]
        s_alt=loop[0].s_alt[index]
    endif else  s_alt=loop[0].s_alt
    ERRPLOT, s_alt,t_minus_error ,t_plus_error , $
             COLOR=fsc_color('red'),  $
             XRANGE=XRANGE, YRANGE=TRANGE, $
             ystyle=1, XS=1 
END;







